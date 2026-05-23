import * as admin from "firebase-admin";

export interface AppNotificationPayload {
  title: string;
  body: string;
  type: string;
  targetAudience: string;
  relatedContentType?: string;
  relatedContentId?: string;
}

export async function createAppNotification(
  payload: AppNotificationPayload
): Promise<string> {
  const ref = await admin.firestore().collection("app_notifications").add({
    ...payload,
    sentAt: admin.firestore.Timestamp.now(),
    readBy: [],
  });
  return ref.id;
}
