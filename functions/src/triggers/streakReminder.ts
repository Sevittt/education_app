import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { sendPushToUsers } from "../helpers/sendPush";
import { createAppNotification } from "../helpers/createAppNotification";
import { getMessage, getLang, MESSAGES } from "../config/messages";

export const dailyStreakReminder = onSchedule(
  { schedule: "0 13 * * *", timeZone: "UTC", region: "us-central1" },
  async () => {
    const db = admin.firestore();
    const now = new Date();

    const twoDaysAgo = new Date(now);
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
    twoDaysAgo.setHours(0, 0, 0, 0);

    const threeDaysAgo = new Date(now);
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    threeDaysAgo.setHours(0, 0, 0, 0);

    const usersSnap = await db
      .collection("users")
      .where("fcmToken", "!=", null)
      .get();

    const atRisk: { uid: string; token: string; streak: number; lang: string }[] = [];
    const lost: { uid: string; token: string; lang: string }[] = [];

    for (const doc of usersSnap.docs) {
      const data = doc.data();
      const token = data["fcmToken"] as string | undefined;
      if (!token) continue;

      const notificationsEnabled = data["notificationsEnabled"] as boolean | undefined;
      if (notificationsEnabled === false) continue;

      const lastLoginRaw = data["lastLoginDate"];
      if (!lastLoginRaw) continue;

      const lastLogin: Date =
        lastLoginRaw instanceof admin.firestore.Timestamp
          ? lastLoginRaw.toDate()
          : new Date(lastLoginRaw as string);

      const lastMidnight = new Date(lastLogin);
      lastMidnight.setHours(0, 0, 0, 0);

      const streak = (data["currentStreak"] as number) ?? 0;
      const lang = (data["preferredLanguage"] as string) ?? "uz";

      if (lastMidnight <= threeDaysAgo) {
        lost.push({ uid: doc.id, token, lang });
      } else if (lastMidnight <= twoDaysAgo) {
        atRisk.push({ uid: doc.id, token, streak, lang });
      }
    }

    for (const u of atRisk) {
      const msg = getMessage("streakAtRisk", getLang(u.lang), {
        streak: String(u.streak),
      });
      await sendPushToUsers(
        [{ uid: u.uid, token: u.token }],
        msg.title,
        msg.body,
        { type: "reminder" }
      );
    }

    if (atRisk.length > 0) {
      await createAppNotification({
        title: MESSAGES.streakAtRisk.uz.title,
        body: MESSAGES.streakAtRisk.uz.body.replace("{streak}", "?"),
        type: "reminder",
        targetAudience: "all",
      });
    }

    for (const u of lost) {
      const msg = getMessage("streakLost", getLang(u.lang));
      await sendPushToUsers(
        [{ uid: u.uid, token: u.token }],
        msg.title,
        msg.body,
        { type: "reminder" }
      );
    }

    console.log(
      `Streak reminders sent: ${atRisk.length} at-risk, ${lost.length} lost`
    );
  }
);
