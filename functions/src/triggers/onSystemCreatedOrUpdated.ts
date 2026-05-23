import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { sendPushToUsers } from "../helpers/sendPush";
import { createAppNotification } from "../helpers/createAppNotification";
import { getMessage, getLang } from "../config/messages";

async function getUsersWithTokens(): Promise<
  { uid: string; token: string; lang: string }[]
> {
  const snap = await admin
    .firestore()
    .collection("users")
    .where("fcmToken", "!=", null)
    .get();

  return snap.docs
    .filter((d) => d.data()["notificationsEnabled"] !== false)
    .map((d) => ({
      uid: d.id,
      token: d.data()["fcmToken"] as string,
      lang: (d.data()["preferredLanguage"] as string) ?? "uz",
    }))
    .filter((u) => !!u.token);
}

export const onSystemCreated = onDocumentCreated(
  { document: "systems/{systemId}", region: "us-central1" },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const systemName = (data["name"] ?? data["title"] ?? "Yangi tizim") as string;
    const systemId = event.params.systemId;
    const users = await getUsersWithTokens();

    for (const u of users) {
      const msg = getMessage("newSystem", getLang(u.lang), { name: systemName });
      await sendPushToUsers([{ uid: u.uid, token: u.token }], msg.title, msg.body, {
        type: "newContent",
        relatedContentType: "system",
        relatedContentId: systemId,
      });
    }

    await createAppNotification({
      title: getMessage("newSystem", "uz", { name: systemName }).title,
      body: getMessage("newSystem", "uz", { name: systemName }).body,
      type: "newContent",
      targetAudience: "all",
      relatedContentType: "system",
      relatedContentId: systemId,
    });
  }
);

export const onSystemUpdated = onDocumentUpdated(
  { document: "systems/{systemId}", region: "us-central1" },
  async (event) => {
    const after = event.data?.after.data();
    const before = event.data?.before.data();
    if (!after || !before) return;

    const significantFields = ["name", "title", "content", "status", "description"];
    const hasChange = significantFields.some(
      (f) => JSON.stringify(before[f]) !== JSON.stringify(after[f])
    );
    if (!hasChange) return;

    const systemName = (after["name"] ?? after["title"] ?? "Tizim") as string;
    const systemId = event.params.systemId;
    const users = await getUsersWithTokens();

    for (const u of users) {
      const msg = getMessage("updatedSystem", getLang(u.lang), { name: systemName });
      await sendPushToUsers([{ uid: u.uid, token: u.token }], msg.title, msg.body, {
        type: "update",
        relatedContentType: "system",
        relatedContentId: systemId,
      });
    }

    await createAppNotification({
      title: getMessage("updatedSystem", "uz", { name: systemName }).title,
      body: getMessage("updatedSystem", "uz", { name: systemName }).body,
      type: "update",
      targetAudience: "all",
      relatedContentType: "system",
      relatedContentId: systemId,
    });
  }
);
