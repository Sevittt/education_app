export type Lang = "uz" | "ru" | "en";

export interface PushMessage {
  title: string;
  body: string;
}

export type MessageKey =
  | "streakAtRisk"
  | "streakLost"
  | "newSystem"
  | "updatedSystem"
  | "newNews"
  | "newQuiz"
  | "courseReminder";

export const MESSAGES: Record<MessageKey, Record<Lang, PushMessage>> = {
  streakAtRisk: {
    uz: {
      title: "🔥 Seriyangiz xavf ostida!",
      body: "Bugun kiring va {streak} kunlik seriyangizni saqlang!",
    },
    ru: {
      title: "🔥 Ваша серия под угрозой!",
      body: "Войдите сегодня и сохраните серию {streak} дней!",
    },
    en: {
      title: "🔥 Your streak is at risk!",
      body: "Log in today to keep your {streak}-day streak alive!",
    },
  },
  streakLost: {
    uz: {
      title: "💔 Seriyangiz uzildi",
      body: "Xafa bo'lmang! Yangi seriyani boshlash uchun bugun kiring.",
    },
    ru: {
      title: "💔 Серия прервана",
      body: "Не расстраивайтесь! Войдите сегодня, чтобы начать новую серию.",
    },
    en: {
      title: "💔 Your streak ended",
      body: "Don't give up! Log in today to start a new streak.",
    },
  },
  newSystem: {
    uz: {
      title: "📋 Yangi tizim qo'shildi",
      body: '"{name}" tizimi platformaga qo\'shildi.',
    },
    ru: {
      title: "📋 Добавлена новая система",
      body: 'Система "{name}" добавлена на платформу.',
    },
    en: {
      title: "📋 New system added",
      body: 'The system "{name}" has been added to the platform.',
    },
  },
  updatedSystem: {
    uz: {
      title: "🔄 Tizim yangilandi",
      body: '"{name}" tizimida yangilanishlar mavjud.',
    },
    ru: {
      title: "🔄 Система обновлена",
      body: 'В системе "{name}" есть обновления.',
    },
    en: {
      title: "🔄 System updated",
      body: 'Updates are available for the system "{name}".',
    },
  },
  newNews: {
    uz: {
      title: "📰 Yangi xabar",
      body: '"{title}" — o\'qish uchun bosing.',
    },
    ru: {
      title: "📰 Новость",
      body: '"{title}" — нажмите для чтения.',
    },
    en: {
      title: "📰 New article",
      body: '"{title}" — tap to read.',
    },
  },
  newQuiz: {
    uz: {
      title: "🧠 Yangi test mavjud!",
      body: '"{name}" testi siz uchun tayyorlandi. Sinab ko\'ring!',
    },
    ru: {
      title: "🧠 Доступен новый тест!",
      body: 'Тест "{name}" готов для вас. Попробуйте!',
    },
    en: {
      title: "🧠 New quiz available!",
      body: 'The quiz "{name}" is ready for you. Give it a try!',
    },
  },
  courseReminder: {
    uz: {
      title: "📚 Kursni tugatishni unutmang!",
      body: '"{course}" kursida davom eting. Bilimlaringizni mustahkamlang!',
    },
    ru: {
      title: "📚 Не забудьте завершить курс!",
      body: 'Продолжите курс "{course}". Закрепите свои знания!',
    },
    en: {
      title: "📚 Continue your course!",
      body: 'Keep going with "{course}". Strengthen your knowledge!',
    },
  },
};

export function getMessage(
  key: MessageKey,
  lang: Lang,
  substitutions: Record<string, string> = {}
): PushMessage {
  const msg = MESSAGES[key][lang];
  let title = msg.title;
  let body = msg.body;
  for (const [k, v] of Object.entries(substitutions)) {
    title = title.replace(`{${k}}`, v);
    body = body.replace(`{${k}}`, v);
  }
  return { title, body };
}

export function getLang(userLang: string | undefined): Lang {
  if (userLang === "ru" || userLang === "en") return userLang;
  return "uz";
}
