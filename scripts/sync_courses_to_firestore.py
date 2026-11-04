"""
Sync the 5 official DARS courses into Firestore 'courses' collection.
"""
import sys, json, time
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, firestore

KEY_PATH = Path(r"d:\dasturlar\sudqollanma_bot\serviceAccountKey.json")

courses = [
    {
        "id": "course_dars_modul_1",
        "title": "1-Modul: Windows, MS Office va Ofis Texnikasi",
        "description": "Sud ish yurituvida Windows fayl tizimi (D:\\SUD_ISH_YURITUVI), hujjatlarni to'g'ri nomlash standarti, Word va Excel (jadvallar, avtosumma, filtrlar) hamda skaner/printer bilan ishlash ko'nikmalari.",
        "targetRole": ["judge", "assistant", "chancellery", "archive", "ict_specialist"],
        "difficulty": "beginner",
        "estimatedMinutes": 120,
        "isPublished": True,
        "order": 1,
        "authorId": "sud_qollanma_official",
        "hasCertificate": True,
        "certificateTitle": "Windows va Ofis Savodxonligi Sertifikati",
        "modules": [
            {
                "id": "m1_mod_1",
                "title": "1-Mavzu: Operatsion tizim (Windows) bilan ishlash",
                "description": "Fayllarni D: diskda xavfsiz papkalash va to'g'ri nomlash standarti.",
                "order": 1,
                "lessons": [
                    {
                        "id": "m1_l1",
                        "title": "Nega sud hujjatlarini Ish stolida (Desktop) saqlash xavfli?",
                        "type": "article",
                        "order": 1,
                        "isRequired": True,
                        "durationMinutes": 15,
                        "xpReward": 10
                    },
                    {
                        "id": "m1_l2",
                        "title": "Sud ish yurituvi papkalar standarti va qidiruvda 3 soniyada topish",
                        "type": "article",
                        "order": 2,
                        "isRequired": True,
                        "durationMinutes": 20,
                        "xpReward": 15
                    }
                ]
            },
            {
                "id": "m1_mod_2",
                "title": "2-Mavzu: Ofis dasturlari (MS Word, Excel, PDF)",
                "description": "Sud hujjatlarini formatlash, formulalar, avtosumma va PDF eksport.",
                "order": 2,
                "lessons": [
                    {
                        "id": "m1_l3",
                        "title": "Word: Sahifa hoshiyalari, qidirish va almashtirish (Ctrl+H)",
                        "type": "article",
                        "order": 1,
                        "isRequired": True,
                        "durationMinutes": 20,
                        "xpReward": 15
                    },
                    {
                        "id": "m1_l4",
                        "title": "Excel: Sud qarorlari va da'vo summasi bo'yicha avtosumma va filtr",
                        "type": "article",
                        "order": 2,
                        "isRequired": True,
                        "durationMinutes": 25,
                        "xpReward": 20
                    }
                ]
            }
        ]
    },
    {
        "id": "course_dars_modul_2",
        "title": "2-Modul: ERI, E-IMZO va Brauzer Sozlamalari",
        "description": "Elektron raqamli imzo (ERI) kalitlarini C:\\DSKEYS da saqlash, E-IMZO moduli ishlamay qolganda to'g'rilash, brauzer keshini tozalash va sertifikat muddatini nazorat qilish.",
        "targetRole": ["judge", "assistant", "chancellery", "ict_specialist"],
        "difficulty": "intermediate",
        "estimatedMinutes": 90,
        "isPublished": True,
        "order": 2,
        "authorId": "sud_qollanma_official",
        "hasCertificate": True,
        "certificateTitle": "ERI va E-IMZO Mutaxassisi Sertifikati",
        "modules": [
            {
                "id": "m2_mod_1",
                "title": "1-Mavzu: ERI kalitlari va C:\\DSKEYS standarti",
                "description": "ERI ning huquqiy kuchi, sudya va yordamchi hamkorligi.",
                "order": 1,
                "lessons": [
                    {
                        "id": "m2_l1",
                        "title": "ERI kalitlarining saqlanishi va C:\\DSKEYS papkasi",
                        "type": "article",
                        "order": 1,
                        "isRequired": True,
                        "durationMinutes": 15,
                        "xpReward": 15
                    }
                ]
            },
            {
                "id": "m2_mod_2",
                "title": "2-Mavzu: Kesh tozalash va E-IMZO muammolarini hal qilish",
                "description": "Brauzer keshini tozalash va E-IMZO ni qayta ishga tushirish.",
                "order": 2,
                "lessons": [
                    {
                        "id": "m2_l2",
                        "title": "E-IMZO ishlamay qolganda keshni tozalash va 3 qadamli yechim",
                        "type": "article",
                        "order": 1,
                        "isRequired": True,
                        "durationMinutes": 20,
                        "xpReward": 20
                    }
                ]
            }
        ]
    },
    {
        "id": "course_dars_modul_3",
        "title": "3-Modul: Sudda Axborot Xavfsizligi va Maxfiylik",
        "description": "Sud tizimida kiberxavfsizlik, fishing (aldamchi) xabarlarni aniqlash, begona fleshkalardan himoyalanish, murakkab parollar va shaxsiy ma'lumotlar maxfiyligi.",
        "targetRole": ["judge", "assistant", "chancellery", "archive", "ict_specialist"],
        "difficulty": "intermediate",
        "estimatedMinutes": 80,
        "isPublished": True,
        "order": 3,
        "authorId": "sud_qollanma_official",
        "hasCertificate": True,
        "certificateTitle": "Kiberxavfsizlik va Maxfiylik Sertifikati",
        "modules": [
            {
                "id": "m3_mod_1",
                "title": "1-Mavzu: Kiberxavfsizlik va Fishingdan himoya",
                "description": "Fishing elektron xatlarini aniqlash va begona USB fleshkalardan ehtiyot bo'lish.",
                "order": 1,
                "lessons": [
                    {
                        "id": "m3_l1",
                        "title": "Fishing hujumlarini aniqlash va xavfsiz pochta qoidalari",
                        "type": "article",
                        "order": 1,
                        "isRequired": True,
                        "durationMinutes": 20,
                        "xpReward": 20
                    }
                ]
            }
        ]
    },
    {
        "id": "course_dars_modul_4",
        "title": "4-Modul: Oliy Sud Axborot Tizimlari va EDO",
        "description": "my.sud.uz interaktiv portali, E-XSUD / JIB tizimlari, EDO ichki va idoralararo elektron hujjat aylanishi, topshiriqlar ijrosi monitoringi va davlat organlari bilan integratsiya.",
        "targetRole": ["judge", "assistant", "chancellery"],
        "difficulty": "advanced",
        "estimatedMinutes": 150,
        "isPublished": True,
        "order": 4,
        "authorId": "sud_qollanma_official",
        "hasCertificate": True,
        "certificateTitle": "Sud Axborot Tizimlari Mutaxassisi",
        "modules": [
            {
                "id": "m4_mod_1",
                "title": "1-Mavzu: EDO elektron hujjat aylanish tizimi",
                "description": "Kiruvchi xatlar, rezyolutsiyalar, javob xati tayyorlash va imzolash.",
                "order": 1,
                "lessons": [
                    {
                        "id": "m4_l1",
                        "title": "EDO: Kiruvchi xatlarni ro'yxatga olish va rezolyutsiya chiqarish",
                        "type": "article",
                        "order": 1,
                        "isRequired": True,
                        "durationMinutes": 25,
                        "xpReward": 25
                    },
                    {
                        "id": "m4_l2",
                        "title": "Video dars: ERI orqali EDO tizimiga kirish va imzolash",
                        "type": "video",
                        "order": 2,
                        "isRequired": True,
                        "durationMinutes": 15,
                        "xpReward": 20
                    }
                ]
            }
        ]
    },
    {
        "id": "course_dars_modul_5",
        "title": "5-Modul: VKA, Audio-Video va Huquqiy Bazalar",
        "description": "Masofaviy sud majlislarini Videokonferensaloqa (VKA) orqali olib borish, sud zallaridagi audio-video qayd etish tizimlari, Lex.uz va qonunchilik bazalaridan samarali foydalanish.",
        "targetRole": ["judge", "assistant", "chancellery"],
        "difficulty": "intermediate",
        "estimatedMinutes": 100,
        "isPublished": True,
        "order": 5,
        "authorId": "sud_qollanma_official",
        "hasCertificate": True,
        "certificateTitle": "VKA va Sud Texnologiyalari Sertifikati",
        "modules": [
            {
                "id": "m5_mod_1",
                "title": "1-Mavzu: Videokonferensaloqa (VKA) va audio-video yozuv",
                "description": "VKA sud majlisini boshqarish va audio-video tizimlarni sozlash.",
                "order": 1,
                "lessons": [
                    {
                        "id": "m5_l1",
                        "title": "Masofaviy sud majlislarini VKA tizimida o'tkazish tartibi",
                        "type": "article",
                        "order": 1,
                        "isRequired": True,
                        "durationMinutes": 20,
                        "xpReward": 20
                    }
                ]
            }
        ]
    }
]

def main():
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    cred = credentials.Certificate(str(KEY_PATH))
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print(f"Syncing {len(courses)} official DARS courses to Firestore 'courses' collection...")
    for c in courses:
        doc_id = c["id"]
        c_copy = dict(c)
        c_copy["createdAt"] = firestore.SERVER_TIMESTAMP
        c_copy["updatedAt"] = firestore.SERVER_TIMESTAMP
        db.collection("courses").document(doc_id).set(c_copy, merge=True)
        print(f" - Synced course: {c['title']} ({doc_id})")

    print("All 5 official DARS courses synced to Firestore successfully!")

if __name__ == "__main__":
    main()
