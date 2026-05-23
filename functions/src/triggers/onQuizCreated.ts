import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { sendPushToUsers } from "../helpers/sendPush";
import { createAppNotification } from "../helpers/createAppNotification";
import { getMessage, getLang } from "../config/messages";

export const onQuizCreated = onDocumentCreated(
  { document: "quizzes/{quizId}", region: "us-central1" },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const quizName = (data["title"] ?? data["name"] ?? "Yangi test") as string;
    const quizId = event.params.quizId;

    const snap = await admin
      .firestore()
      .collection("users")
      .where("fcmToken", "!=", null)
      .get();

    const users = snap.docs
      .filter((d) => d.data()["notificationsEnabled"] !== false)
      .map((d) => ({
        uid: d.id,
        token: d.data()["fcmToken"] as string,
        lang: (d.data()["preferredLanguage"] as string) ?? "uz",
      }))
      .filter((u) => !!u.token);

    for (const u of users) {
      const msg = getMessage("newQuiz", getLang(u.lang), { name: quizName });
      await sendPushToUsers([{ uid: u.uid, token: u.token }], msg.title, msg.body, {
        type: "newContent",
        relatedContentType: "quiz",
        relatedContentId: quizId,
      });
    }

    await createAppNotification({
      title: getMessage("newQuiz", "uz", { name: quizName }).title,
      body: getMessage("newQuiz", "uz", { name: quizName }).body,
      type: "newContent",
      targetAudience: "all",
      relatedContentType: "quiz",
      relatedContentId: quizId,
    });
  }
);
