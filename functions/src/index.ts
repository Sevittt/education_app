import * as admin from "firebase-admin";

admin.initializeApp();

export { dailyStreakReminder } from "./triggers/streakReminder";
export { scheduledCourseReminder, testCourseReminder } from "./triggers/courseReminder";
export { onSystemCreated, onSystemUpdated } from "./triggers/onSystemCreatedOrUpdated";
export { onNewsCreated } from "./triggers/onNewsCreated";
export { onQuizCreated } from "./triggers/onQuizCreated";
