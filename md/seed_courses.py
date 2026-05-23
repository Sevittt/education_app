"""
seed_courses.py — Sud Qo'llanma Education App
Firestore'ga kurs (courses) ma'lumotlarini yuklash skripti.

Data Structure (Flutter CourseModel bilan mos):
  courses/{courseId}:
    title, description, thumbnailUrl?, targetRole[], difficulty,
    estimatedMinutes, isPublished, authorId, order, createdAt, updatedAt,
    modules[]:
      id, title, description, order,
      lessons[]:
        id, title, order, type (video|article|pdf|quiz), refId, estimatedMinutes?, isRequired

Usage:
  1. pip install firebase-admin
  2. serviceAccountKey.json faylini ushbu papkaga joylashtiring
  3. python seed_courses.py
"""

import uuid
import datetime
import firebase_admin
from firebase_admin import credentials, firestore

# ─── Firebase ulanish ─────────────────────────────────────────────────────────

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# ─── Yordamchi funksiya ───────────────────────────────────────────────────────

def new_id() -> str:
    """Yangi UUID generatsiya qiladi (kichik harflar, 20 belgi)."""
    return uuid.uuid4().hex[:20]


def lesson(title: str, lesson_type: str, ref_id: str, order: int,
           estimated_minutes: int = 10, is_required: bool = True) -> dict:
    """CourseLessonModel ga mos dict qaytaradi."""
    return {
        "id": new_id(),
        "title": title,
        "type": lesson_type,       # video | article | pdf | quiz
        "refId": ref_id,           # Firestore'dagi haqiqiy doc ID
        "order": order,
        "estimatedMinutes": estimated_minutes,
        "isRequired": is_required,
    }


def module(title: str, description: str, order: int, lessons: list) -> dict:
    """CourseModuleModel ga mos dict qaytaradi."""
    return {
        "id": new_id(),
        "title": title,
        "description": description,
        "order": order,
        "lessons": lessons,
    }


def course_doc(title: str, description: str, target_role: list,
               difficulty: str, estimated_minutes: int, order: int,
               modules: list, author_id: str = "system",
               thumbnail_url: str = None, is_published: bool = True) -> dict:
    """CourseModel.toJson() ga mos dict qaytaradi."""
    now = datetime.datetime.now(tz=datetime.timezone.utc)
    doc = {
        "title": title,
        "description": description,
        "targetRole": target_role,
        "difficulty": difficulty,           # beginner | intermediate | advanced
        "estimatedMinutes": estimated_minutes,
        "isPublished": is_published,
        "authorId": author_id,
        "order": order,
        "modules": modules,
        "createdAt": now,
        "updatedAt": now,
    }
    if thumbnail_url:
        doc["thumbnailUrl"] = thumbnail_url
    return doc


# ─── Kurs ma'lumotlari ────────────────────────────────────────────────────────

COURSES = [

    # ═══════════════════════════════════════════════════════════════
    # 1. E-SUD tizimi — Boshlang'ich
    # ═══════════════════════════════════════════════════════════════
    course_doc(
        title="E-SUD tizimiga kirish va asosiy amallar",
        description=(
            "Sudyalar va kotiblar uchun E-SUD elektron ish yuritish "
            "tizimining interfeysini o'rganish. Ish stoli, ish oynasi, "
            "hujjatlar ro'yxati va qidiruv funksiyalari."
        ),
        target_role=["judge", "clerk", "ict_specialist"],
        difficulty="beginner",
        estimated_minutes=90,
        order=1,
        modules=[
            module(
                title="E-SUD interfeysiga tanishuv",
                description="Tizimga kirish va asosiy navigatsiya",
                order=1,
                lessons=[
                    lesson("Tizimga kirish va parol o'zgartirish", "video",
                           "vid_esud_login_001", order=1, estimated_minutes=8),
                    lesson("Bosh sahifa va menyu tuzilishi", "video",
                           "vid_esud_dashboard_002", order=2, estimated_minutes=10),
                    lesson("Ish stoli sozlamalari", "article",
                           "art_esud_settings_001", order=3, estimated_minutes=7),
                ],
            ),
            module(
                title="Ish (case) yaratish va tahrirlash",
                description="Yangi ish ochish, ma'lumot kiritish va saqlash",
                order=2,
                lessons=[
                    lesson("Yangi ish yaratish: bosqichma-bosqich", "video",
                           "vid_esud_new_case_003", order=1, estimated_minutes=15),
                    lesson("Hujjatlar biriktirish va formatlash", "pdf",
                           "pdf_esud_attach_guide_001", order=2, estimated_minutes=12),
                    lesson("E-SUD bilimlar testi — 1-modul", "quiz",
                           "quiz_esud_module1_001", order=3, estimated_minutes=10),
                ],
            ),
            module(
                title="Qidiruv va filtrlar",
                description="Ish raqami, sana va holat bo'yicha qidiruv",
                order=3,
                lessons=[
                    lesson("Ish raqami bo'yicha tezkor qidiruv", "video",
                           "vid_esud_search_004", order=1, estimated_minutes=8),
                    lesson("Kengaytirilgan filtrlar", "article",
                           "art_esud_filter_002", order=2, estimated_minutes=6),
                    lesson("Qidiruv natijalarini eksport qilish", "video",
                           "vid_esud_export_005", order=3, estimated_minutes=7, is_required=False),
                ],
            ),
        ],
    ),

    # ═══════════════════════════════════════════════════════════════
    # 2. Axborot xavfsizligi — Barcha xodimlar uchun
    # ═══════════════════════════════════════════════════════════════
    course_doc(
        title="Axborot xavfsizligi asoslari",
        description=(
            "Sud xodimlari uchun shaxsiy ma'lumotlarni himoya qilish, "
            "fishing hujumlarini aniqlash, kuchli parol yaratish va "
            "ish qurilmalarini xavfsiz ishlatish bo'yicha amaliy kurs."
        ),
        target_role=["judge", "clerk", "ict_specialist", "admin"],
        difficulty="beginner",
        estimated_minutes=60,
        order=2,
        modules=[
            module(
                title="Parol va hisob xavfsizligi",
                description="Kuchli parol yaratish va boshqarish",
                order=1,
                lessons=[
                    lesson("Kuchli parol qanday yaratiladi?", "video",
                           "vid_sec_password_001", order=1, estimated_minutes=8),
                    lesson("Ikki faktorli autentifikatsiya (2FA)", "article",
                           "art_sec_2fa_001", order=2, estimated_minutes=10),
                    lesson("Parol menejerlar: amaliy ko'rsatma", "pdf",
                           "pdf_sec_passmanager_001", order=3, estimated_minutes=7),
                    lesson("Parol xavfsizligi testi", "quiz",
                           "quiz_sec_password_001", order=4, estimated_minutes=8),
                ],
            ),
            module(
                title="Fishing va sotsial muhandislik",
                description="Fishing hujumlarni aniqlash va oldini olish",
                order=2,
                lessons=[
                    lesson("Fishing elektron xatlarni aniqlash", "video",
                           "vid_sec_phishing_002", order=1, estimated_minutes=12),
                    lesson("Ijtimoiy tarmoqlarda xavfsizlik", "article",
                           "art_sec_social_002", order=2, estimated_minutes=8),
                    lesson("Fishing simulyatsiyasi testi", "quiz",
                           "quiz_sec_phishing_002", order=3, estimated_minutes=10),
                ],
            ),
        ],
    ),

    # ═══════════════════════════════════════════════════════════════
    # 3. E-XAT tizimi — Kotiblar uchun
    # ═══════════════════════════════════════════════════════════════
    course_doc(
        title="E-XAT: Elektron hujjat muomalasi",
        description=(
            "E-XAT tizimi orqali kiruvchi va chiquvchi xatlar bilan ishlash, "
            "elektron imzo qo'yish, hujjatlarni ro'yxatga olish va topshiriqlarni "
            "boshqarish bo'yicha to'liq amaliy kurs."
        ),
        target_role=["clerk", "admin"],
        difficulty="intermediate",
        estimated_minutes=120,
        order=3,
        modules=[
            module(
                title="E-XAT interfeysiga tanishuv",
                description="Kiruvchi va chiquvchi xatlar ro'yxatini ko'rish",
                order=1,
                lessons=[
                    lesson("E-XAT ga kirish va bosh sahifa", "video",
                           "vid_exat_intro_001", order=1, estimated_minutes=10),
                    lesson("Xatlar klassifikatsiyasi", "article",
                           "art_exat_classify_001", order=2, estimated_minutes=8),
                ],
            ),
            module(
                title="Xat yaratish va yuborish",
                description="Yangi xat tuzish, imzo qo'yish va yuborish",
                order=2,
                lessons=[
                    lesson("Kiruvchi xatni ro'yxatga olish", "video",
                           "vid_exat_register_002", order=1, estimated_minutes=15),
                    lesson("Chiquvchi xat yaratish va yuborish", "video",
                           "vid_exat_send_003", order=2, estimated_minutes=15),
                    lesson("Elektron imzo qo'yish (ERI)", "pdf",
                           "pdf_exat_esign_001", order=3, estimated_minutes=12),
                    lesson("E-XAT amaliy testi", "quiz",
                           "quiz_exat_module2_001", order=4, estimated_minutes=10),
                ],
            ),
            module(
                title="Topshiriqlar va nazorat",
                description="Topshiriq berish, bajarish muddatini kuzatish",
                order=3,
                lessons=[
                    lesson("Topshiriq yaratish va ijrochilarga belgilash", "video",
                           "vid_exat_tasks_004", order=1, estimated_minutes=12),
                    lesson("Muddati o'tgan topshiriqlarni kuzatish", "article",
                           "art_exat_deadline_002", order=2, estimated_minutes=8),
                    lesson("Hisobot shakllari", "pdf",
                           "pdf_exat_reports_002", order=3, estimated_minutes=10, is_required=False),
                ],
            ),
        ],
    ),

    # ═══════════════════════════════════════════════════════════════
    # 4. Kompyuter savodxonligi — Asosiy
    # ═══════════════════════════════════════════════════════════════
    course_doc(
        title="Kompyuter savodxonligi: amaliy asoslar",
        description=(
            "Windows va Office dasturlarini ishlatish, fayllarni boshqarish, "
            "internet xavfsizligi va ish unumdorligini oshirish bo'yicha "
            "amaliy kurs. Barcha xodimlar uchun tavsiya etiladi."
        ),
        target_role=["judge", "clerk", "ict_specialist", "admin"],
        difficulty="beginner",
        estimated_minutes=150,
        order=4,
        modules=[
            module(
                title="Windows OS — Asosiy amallar",
                description="Fayl tizimi, dasturlar va sozlamalar",
                order=1,
                lessons=[
                    lesson("Fayllar va papkalar bilan ishlash", "video",
                           "vid_win_files_001", order=1, estimated_minutes=12),
                    lesson("Windows qidiruvi va Vazifalar paneli", "video",
                           "vid_win_search_002", order=2, estimated_minutes=8),
                    lesson("Printer va qurilmalar ulash", "pdf",
                           "pdf_win_devices_001", order=3, estimated_minutes=10),
                ],
            ),
            module(
                title="Microsoft Word — Hujjat tayyorlash",
                description="Rasmiy hujjatlarni Word da tuzish va formatlash",
                order=2,
                lessons=[
                    lesson("Rasmiy xat shablonini yaratish", "video",
                           "vid_word_template_003", order=1, estimated_minutes=15),
                    lesson("Jadval va ro'yxatlar bilan ishlash", "video",
                           "vid_word_tables_004", order=2, estimated_minutes=12),
                    lesson("Hujjatni PDF sifatida saqlash", "article",
                           "art_word_pdf_001", order=3, estimated_minutes=5),
                    lesson("Word savodxonligi testi", "quiz",
                           "quiz_word_basics_001", order=4, estimated_minutes=8),
                ],
            ),
            module(
                title="Internet va elektron pochta",
                description="Brauzer, Gmail, va xavfsiz internet",
                order=3,
                lessons=[
                    lesson("Email yozish va biriktirish", "video",
                           "vid_email_send_005", order=1, estimated_minutes=10),
                    lesson("Xavfsiz browsing: nima qilish kerak?", "article",
                           "art_net_safe_001", order=2, estimated_minutes=8),
                    lesson("Umumiy savodxonlik testi", "quiz",
                           "quiz_computer_final_001", order=3, estimated_minutes=12),
                ],
            ),
        ],
    ),

    # ═══════════════════════════════════════════════════════════════
    # 5. ICT Mutaxassis — Tizim boshqaruvi (Yuqori daraja)
    # ═══════════════════════════════════════════════════════════════
    course_doc(
        title="Sud IT tizimlarini boshqarish (ICT mutaxassis)",
        description=(
            "Sud axborot tizimlari (E-SUD, E-XAT) administratorlari uchun: "
            "foydalanuvchilarni boshqarish, zaxira nusxa olish, tarmoq "
            "xavfsizligi va texnik nosozliklarni bartaraf etish."
        ),
        target_role=["ict_specialist"],
        difficulty="advanced",
        estimated_minutes=200,
        order=5,
        modules=[
            module(
                title="Foydalanuvchi va ruxsat boshqaruvi",
                description="Akkaunt yaratish, rol berish, bloklash",
                order=1,
                lessons=[
                    lesson("Active Directory orqali akkaunt yaratish", "video",
                           "vid_ict_ad_users_001", order=1, estimated_minutes=18),
                    lesson("Rol asosidagi kirish nazorati (RBAC)", "article",
                           "art_ict_rbac_001", order=2, estimated_minutes=15),
                    lesson("Audit jurnali va loglarda ishlash", "pdf",
                           "pdf_ict_audit_001", order=3, estimated_minutes=12),
                ],
            ),
            module(
                title="Tarmoq va infratuzilma xavfsizligi",
                description="Firewall, VPN va monitoring",
                order=2,
                lessons=[
                    lesson("Firewall sozlamalari: amaliy qo'llanma", "pdf",
                           "pdf_ict_firewall_002", order=1, estimated_minutes=20),
                    lesson("VPN ulanishni sozlash", "video",
                           "vid_ict_vpn_002", order=2, estimated_minutes=15),
                    lesson("Tarmoq monitoringi va ogohlantirish tizimi", "article",
                           "art_ict_monitor_002", order=3, estimated_minutes=12),
                    lesson("Tarmoq xavfsizligi testi", "quiz",
                           "quiz_ict_network_001", order=4, estimated_minutes=15),
                ],
            ),
            module(
                title="Zaxira nusxa va tiklash",
                description="Backup strategiyasi va disaster recovery",
                order=3,
                lessons=[
                    lesson("3-2-1 Backup qoidasi va amaliyoti", "video",
                           "vid_ict_backup_003", order=1, estimated_minutes=15),
                    lesson("Tiklash (restore) jarayonini tekshirish", "article",
                           "art_ict_restore_003", order=2, estimated_minutes=10),
                    lesson("ICT mutaxassis yakuniy testi", "quiz",
                           "quiz_ict_final_001", order=3, estimated_minutes=20),
                ],
            ),
        ],
    ),
]


# ─── Firestore ga yuklash ─────────────────────────────────────────────────────

def upload_courses(courses: list, dry_run: bool = False):
    """
    courses ro'yxatini Firestore 'courses' kolleksiyasiga yuklaydi.
    dry_run=True bo'lsa, ma'lumotlarni chiqaradi, lekin yuklamaydi.
    """
    print(f"\n{'='*60}")
    print(f"  Sud Qo'llanma — Kurslarni yuklash")
    print(f"  Jami kurslar: {len(courses)}")
    print(f"  Rejim: {'DRY RUN (yuklanmaydi)' if dry_run else 'PRODUCTION'}")
    print(f"{'='*60}\n")

    col_ref = db.collection("courses")

    for i, course_data in enumerate(courses, start=1):
        title = course_data.get("title", "Nomsiz kurs")
        total_lessons = sum(
            len(m.get("lessons", [])) for m in course_data.get("modules", [])
        )
        total_modules = len(course_data.get("modules", []))

        print(f"[{i}/{len(courses)}] '{title}'")
        print(f"          Modullar: {total_modules} | Darslar: {total_lessons} "
              f"| Daraja: {course_data['difficulty']} "
              f"| {course_data['estimatedMinutes']} daqiqa")

        if not dry_run:
            try:
                _ref, _doc = col_ref.add(course_data)
                print(f"          ✅ Yuklandi → ID: {_doc.id}\n")
            except Exception as e:
                print(f"          ❌ XATOLIK: {e}\n")
        else:
            print(f"          ⏭  Dry run — yuklanmadi\n")

    print(f"\n{'='*60}")
    print(f"  Jarayon yakunlandi!")
    print(f"{'='*60}\n")


# ─── Mavjud kurslarni o'chirish (ixtiyoriy) ──────────────────────────────────

def clear_courses(confirm: bool = False):
    """Firestore 'courses' kolleksiyasidagi barcha hujjatlarni o'chiradi."""
    if not confirm:
        print("⚠️  clear_courses() ni ishlatish uchun confirm=True deb bering!")
        return

    print("🗑  Mavjud kurslar o'chirilmoqda...")
    docs = db.collection("courses").stream()
    count = 0
    for doc in docs:
        doc.reference.delete()
        count += 1
    print(f"✅ {count} ta kurs o'chirildi.\n")


# ─── Entry Point ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Avval dry_run=True bilan tekshiring, keyin False ga o'zgartiring
    upload_courses(COURSES, dry_run=False)
