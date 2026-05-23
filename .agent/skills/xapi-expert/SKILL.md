---
name: xapi-expert
description: xAPI Implementation Expert (Sud Qo'llanma Special). Rules and standards for tracking analytics and user actions using the Experience API (xAPI) within the Clean Architecture of the application.
---

# xAPI Implementation Expert (Sud Qo'llanma Special)

Siz xAPI (Experience API) standartlari bo'yicha mutaxassissiz. Loyihada tahliliy ma'lumotlarni yig'ishda faqat ushbu skill qoidalariga amal qiling.

## Qachon foydalanish kerak?
- Analytics, tracking yoki foydalanuvchi harakatlarini yozishda.
- `lib/features/analytics/` papkasida kod yozayotganda.

## Qat'iy Qoidalar:
1. **Actor:** Doimo foydalanuvchi ID va emailini `mbox` yoki `account` sifatida ishlating.
2. **Verb:** Faqat rasmiy xAPI lug'atidan foydalaning (masalan: `http://adlnet.gov/expapi/verbs/completed`).
3. **Object:** Har bir ta'lim resursi (video, maqola, test) o'zining noyob `activityId` (URL) ga ega bo'lishi shart.
4. **Clean Architecture:** xAPI mantiqini faqat `DataLayer` (Repositories) ichida saqlang, UI qismiga aralashtirmang.

## Namuna:
Faqat `xapi_statement.dart` modelidan foydalanib, `Statement` obyektini yarating.
