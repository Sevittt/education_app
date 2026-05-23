import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { sendPushToUsers } from "../helpers/sendPush";
import { createAppNotification } from "../helpers/createAppNotification";
import { getMessage, getLang } from "../config/messages";

export const onNewsCreated = onDocumentCreated(
  { document: "news/{newsId}", region: "us-central1" },
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const newsTitle = (data["title"] ?? "Yangi xabar") as string;
    const newsId = event.params.newsId;

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
      const msg = getMessage("newNews", getLang(u.lang), { title: newsTitle });
      await sendPushToUsers([{ uid: u.uid, token: u.token }], msg.title, msg.body, {
        type: "announcement",
        relatedContentType: "news",
        relatedContentId: newsId,
      });
    }

    await createAppNotification({
      title: getMessage("newNews", "uz", { title: newsTitle }).title,
      body: getMessage("newNews", "uz", { title: newsTitle }).body,
      type: "announcement",
      targetAudience: "all",
      relatedContentType: "news",
      relatedContentId: newsId,
    });
  }
);
