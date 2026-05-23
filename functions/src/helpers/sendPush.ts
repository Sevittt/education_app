import * as admin from "firebase-admin";

export interface SendPushOptions {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

async function sendPushToToken(opts: SendPushOptions): Promise<boolean> {
  try {
    await admin.messaging().send({
      token: opts.token,
      notification: { title: opts.title, body: opts.body },
      data: opts.data ?? {},
      android: {
        notification: {
          channelId: "sud_qollanma_high",
          sound: "default",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        priority: "high",
      },
      webpush: {
        notification: {
          title: opts.title,
          body: opts.body,
          icon: "/icons/Icon-192.png",
        },
      },
    });
    return true;
  } catch (err: unknown) {
    const code =
      err && typeof err === "object" && "code" in err
        ? (err as { code: string }).code
        : "";
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token"
    ) {
      return false;
    }
    console.error("FCM send error:", err);
    return false;
  }
}

export async function sendPushToUsers(
  users: { uid: string; token: string }[],
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<void> {
  const db = admin.firestore();
  await Promise.allSettled(
    users.map(async ({ uid, token }) => {
      const success = await sendPushToToken({ token, title, body, data });
      if (!success) {
        await db
          .collection("users")
          .doc(uid)
          .update({ fcmToken: admin.firestore.FieldValue.delete() });
      }
    })
  );
}
