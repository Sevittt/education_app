# Yagona profil va bot tuzatishlari: deploy tartibi

Ikki repo: ilova (`b-v22`) va bot (`sudqollanma_bot`, branch `fix/role-xp-rules`,
worktree `D:\dasturlar\sudqollanma_bot-xp-fix`). Tartib muhim — har qadamdan keyin tekshiring.

## Holat (2026-11-12)

- [x] 1. Functions deploy: `createTelegramLinkCode` yaratildi, qolgan 9 ta funksiya yangilandi.
- [x] 2. Bot: `main` push (`61215de`), Cloud Build SUCCESS, revision `sudqollanmabot-00042-g5j` Ready, startup loglari toza.
- [x] 3. Migratsiya `--apply`: 9 profil → `tg_<id>`, 4 test natijasi, 15 daraja; takror sinov — 0 oʻzgarish.
- [x] 4. Ilova versiyasini chiqarish (Web `1.1.0+2` → `https://educationapp-4780a.web.app`), keyin `firebase deploy --only firestore:rules` (ikkala bazaga ham chiqarildi). *(Android APK uchun lokal mashinada JDK/`JAVA_HOME` oʻrnatilmagan.)*

## 0. Tayyorgarlik

1. Ikkala repodagi oʻzgarishlarni commit qiling.
2. Bot testlari: `python -m unittest discover -s tests -t .` (aiogram va firebase-admin oʻrnatilgan muhitda).

## 1. Server funksiyalari (ilova reposi)

```bash
cd functions && npm test && cd .. && firebase deploy --only functions
```

`createTelegramLinkCode` qoʻshiladi. Shu bilan 1-paketdagi `awardXp` va `updateStreak` ham deploy boʻladi —
ular yangi qoidalardan oldin chiqishi kerak (eski ilova ishlashda davom etadi).

## 2. Bot (Cloud Run)

Deploy avtomatik: Cloud Build trigger GitHub `Sevittt/sudqollanma_bot` reposining `main` branchiga
push'da image yigʻadi (tag = commit SHA) va `sudqollanmabot` xizmatini yangilaydi (`europe-west4`,
mavjud env va secret'lar saqlanadi). Qoʻlda `gcloud builds submit` / `gcloud run deploy` kerak emas.

1. Lokal `main` ni GitHub bilan tenglashtiring: `git pull` (lokalda `c937485`, GitHub'da `61181b4`).
2. `fix/role-xp-rules` ni `main` ga birlashtiring va testlarni ishga tushiring.
3. `main` ni push qiling — **bu production deploy**.
4. Build tugashini kuting va yangi revision Ready boʻlganini tekshiring:

```bash
gcloud builds list --project educationapp-4780a --limit 3 --format="table(createTime,status,substitutions.SHORT_SHA)"
gcloud run services describe sudqollanmabot --region europe-west4 --project educationapp-4780a --format="value(status.latestReadyRevisionName)"
```

Image GitHub'dan yigʻiladi: `.env`, `serviceAccountKey.json`, `data/` unga tushmaydi; bot Firestore'ga
xizmat hisobi (ADC) bilan ulanadi. Deploydan oldingi holat: revision `sudqollanmabot-00041-m5z`, commit `61181b4`.

Tekshiruv:
- `/start` — eski foydalanuvchi profili topiladi (eski yozuvlar hali avto-ID da).
- Test yechish: 70% dan past — XP berilmaydi; oʻtganda +20; aynan shu testni qayta yechish — «avval olingan».
- `/profile`, `/stats` — daraja nomi bilan chiqadi, xato yoʻq.
- Loglar: `gcloud run services logs read sudqollanmabot --region europe-west4 --project educationapp-4780a --limit 30`.

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

`BOT_TOKEN` va `GEMINI_API_KEY` Cloud Run'da allaqachon Secret Manager orqali beriladi.
Botning `.agent/skills/gcloud/SKILL.md` dagi qoʻlda deploy buyrugʻi ularni ochiq env sifatida
beradi — undan foydalanmang (avtomatik deploy secret'larni saqlaydi).
