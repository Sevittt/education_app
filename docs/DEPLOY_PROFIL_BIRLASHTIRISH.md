# Yagona profil va bot tuzatishlari: deploy tartibi

Ikki repo: ilova (`b-v22`) va bot (`sudqollanma_bot`, branch `fix/role-xp-rules`,
worktree `D:\dasturlar\sudqollanma_bot-xp-fix`). Tartib muhim — har qadamdan keyin tekshiring.

## 0. Tayyorgarlik

1. Ikkala repodagi oʻzgarishlarni commit qiling.
2. Botda `fix/role-xp-rules` ni `main` ga birlashtiring. Lokal `main` GitHub'dagidan ajralgan
   (lokalda `c937485`, GitHub'da `61181b4`): avval `git pull`, keyin branch merge.
3. Bot testlari: `python -m unittest discover -s tests -t .` (aiogram va firebase-admin oʻrnatilgan muhitda).

## 1. Server funksiyalari (ilova reposi)

```bash
cd functions && npm test && cd .. && firebase deploy --only functions
```

`createTelegramLinkCode` qoʻshiladi. Shu bilan 1-paketdagi `awardXp` va `updateStreak` ham deploy boʻladi —
ular yangi qoidalardan oldin chiqishi kerak (eski ilova ishlashda davom etadi).

## 2. Bot (Cloud Run)

Botning asosiy papkasidan (`serviceAccountKey.json` va `.env` shu yerda), branch birlashtirilgandan keyin.
Buyruqlar: `.agent/skills/gcloud/SKILL.md`, «Stable Deploy» — avval `gcloud builds submit`, keyin `gcloud run deploy`.

Tekshiruv:
- `/start` — eski foydalanuvchi profili topiladi (eski yozuvlar hali avto-ID da).
- Test yechish: 70% dan past — XP berilmaydi; oʻtganda +20; aynan shu testni qayta yechish — «avval olingan».
- `/profile`, `/stats` — daraja nomi bilan chiqadi, xato yoʻq.
- Loglar: `gcloud run services logs read sudqollanmabot --region europe-west4 --limit 20`.

## 3. Profil migratsiyasi (bot deploydan KEYIN)

Eski bot `telegram_id` maydoni boʻyicha qidiradi; migratsiyadan keyin bir Telegram ID ikki
hujjatda boʻladi, shuning uchun bu qadam faqat yangi bot ishlayotganda bajariladi.

```bash
python scripts/migrate_profiles.py            # sinov: hech narsa yozmaydi
python scripts/migrate_profiles.py --apply    # yozish
python scripts/migrate_profiles.py            # takror sinov: hammasi 0 boʻlishi kerak
```

2026-11-11 dagi sinov natijasi: 9 ta eski bot profili → `tg_<id>`, 4 ta test natijasi qayta bogʻlanadi,
15 ta profilda daraja `levelBeginner` ga keltiriladi. Eski hujjatlar oʻchirilmaydi (`mergedInto` belgisi).

## 4. Ilova

Yangi versiyani chiqaring («Sozlamalar → Telegramʼni ulash»). Keyin, 1-paket rejasiga koʻra:

```bash
firebase deploy --only firestore:rules
```

Tekshiruv: ilovada «Telegramʼni ulash» → bot «✅ Telegram ilovadagi profilingizga ulandi» deydi →
ilovada band «Ulangan» boʻladi; botda test yechilsa, natija ilovadagi test tarixida koʻrinadi.

## Qaytarish

- Bot: oldingi Cloud Run revision'ga trafikni qaytarish (`gcloud run services update-traffic`).
- Migratsiya: eski hujjatlar saqlangan; `tg_*` hujjatlar `migratedFrom`, test natijalari
  `migratedFromUserId` maydonini oladi — shular boʻyicha teskari skript yozish mumkin.

## Eslatma

Deploy buyrugʻi `BOT_TOKEN` va `GEMINI_API_KEY` ni ochiq muhit oʻzgaruvchisi sifatida beradi.
Keyinchalik ularni Secret Manager'ga oʻtkazish tavsiya etiladi.
