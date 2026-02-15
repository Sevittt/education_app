Siz yuborgan fayllar (ayniqsa StackOverflow va Google hujjatlari) shuni ko'rsatadiki, App Check noto'g'ri qilinsa, haqiqiy foydalanuvchilar bloklanib qolishi yoki "403 Forbidden" xatosi chiqishi mumkin.

Keling, buni xavfsiz va bosqichma-bosqich amalga oshiramiz.

1-qadam: Kutubxonani o'rnatish
Terminalda quyidagi buyruqni bering (yoki pubspec.yaml ga qo'shing):

Bash
flutter pub add firebase_app_check
2-qadam: Dasturga App Checkni tanishtirish (main.dart)
Sizning loyihangizda main.dart fayli mavjud. Biz Firebase.initializeApp() dan so'ng darhol App Checkni faollashtirishimiz kerak.

Sizning lib/main.dart faylingizni quyidagicha o'zgartirishni tavsiya qilaman:

Dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // Import qo'shildi
import 'package:flutter/foundation.dart'; // kReleaseMode uchun
import 'package:flutter/material.dart';
// ... boshqa importlar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- APP CHECK INTEGRATSIYASI BOSHLANDI ---
  await FirebaseAppCheck.instance.activate(
    // Android uchun Play Integrity (Eng ishonchlisi)
    // Agar eskiroq qurilmalar bo'lsa, safetyNet ham ishlatish mumkin, lekin u eskirmoqda.
    androidProvider: kReleaseMode 
        ? AndroidProvider.playIntegrity 
        : AndroidProvider.debug, // Debug paytida "Debug Token" ishlatish
    
    // iOS uchun App Attest (Apple yangi standarti)
    // Agar iOS 14 dan past bo'lsa, deviceCheck ga o'tadi
    appleProvider: kReleaseMode 
        ? AppleProvider.appAttest 
        : AppleProvider.debug,

    // Web uchun reCAPTCHA v3 (Enterprise tavsiya etiladi)
    webProvider: ReCaptchaV3Provider('SIZNING-RECAPTCHA-SITE-KEY-INGIZ'), 
  );
  // --- APP CHECK INTEGRATSIYASI TUGADI ---

  runApp(const MyApp());
}
3-qadam: Firebase Console sozlamalari (Eng muhim qismi)
Kod yozishning o'zi yetarli emas. Firebase konsolida "eshiklar"ni ochishimiz kerak.

Firebase Consolega kiring -> Build -> App Check.

Get Started tugmasini bosing.

Apps tabida ilovalaringizni ro'yxatdan o'tkazing:

Android uchun:

Loyihangizni tanlang.

Play Integrityni tanlang.

Sizdan SHA-256 so'raydi. Buni olish uchun terminalda:

Windows: gradlew signingReport

Mac/Linux: ./gradlew signingReport buyrug'ini android papkasi ichida ishga tushirib, SHA-256 kodini olib, konsolga joylang.

Eslatma: Agar ilova Google Playga yuklangan bo'lsa, Google Play Console'dan "App Signing Key" SHA-256 sini olishingiz shart.

iOS uchun:

Apple Developer hisobingizdan Team ID ni kiriting.

Xcode'da Signing & Capabilities bo'limida App Attest imkoniyatini yoqing.

4-qadam: Debug (Sinov) jarayoni uchun Token
Rivojlanish (Development) paytida emulyator yoki o'z telefoningizda ishlaganda App Check sizni bloklamasligi uchun Debug Token kerak.

Ilovani emulyatorda ishga tushiring (flutter run).

Konsolda (Terminalda) shunga o'xshash yozuv chiqadi: Enter this debug secret into the allow list in the Firebase Console for your project: XXXXX-XXXXX-XXXXX-XXXXX

Ushbu kodni nusxalab oling.

Firebase Console -> App Check -> Apps -> Ilovangiz yonidagi menyu -> Manage debug tokens.

Kodni u yerga joylang va nom bering (masalan: "Mening Kompyuterim").

5-qadam: "Enforcement" (Majburlash) bo'yicha ogohlantirish
Siz yuklagan fayllarda ("Monitor App Check request metrics") aytilganidek: DARHOL ENFORCEMENTNI YOQMANG!

Avval kodni yuklang va foydalanuvchilarga tarqating.

Firebase Console -> App Check -> APIs bo'limiga o'ting.

U yerda "Verified requests" (Tasdiqlangan so'rovlar) foizi oshishini kuting.

Faqat 90-100% foydalanuvchilar yangi versiyaga o'tgandan keyingina "Enforce" tugmasini bosib, himoyani to'liq yoqasiz. Aks holda, eski versiyadagi foydalanuvchilar ilovadan foydalana olmay qoladi.