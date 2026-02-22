// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Sud Qo\'llanmasi';

  @override
  String get openInYoutube => 'YouTube orqali ochish';

  @override
  String get watchOnYoutube => 'YouTube da ko\'rish';

  @override
  String get loginWelcomeTitle => 'Xush kelibsiz!';

  @override
  String get loginWelcomeSubtitle => 'Davom etish uchun kiring';

  @override
  String get bottomNavHome => 'Bosh Sahifa';

  @override
  String get bottomNavResources => 'Qo\'llanmalar';

  @override
  String get bottomNavCommunity => 'Munozara';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get resourcesScreenTitle => 'Qo\'llanmalar va Yo\'riqnomalar';

  @override
  String get roleXodim => 'Xodim';

  @override
  String get roleEkspert => 'Ekspert';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get registrationTitle => 'Hisob Yaratish';

  @override
  String get registrationSubtitle => 'Professional hamjamiyatga qo\'shiling!';

  @override
  String get registrationFullNameLabel => 'To\'liq Ism (F.I.Sh.)';

  @override
  String get registrationFullNameError =>
      'Iltimos, to\'liq ismingizni kiriting';

  @override
  String get registrationRoleLabel => 'Sizning Rolingiz';

  @override
  String get registrationRoleError => 'Iltimos, rolni tanlang';

  @override
  String get registrationRoleXodim => 'Oddiy Xodim';

  @override
  String get registrationRoleEkspert => 'Ekspert (Qo\'llanma yaratuvchi)';

  @override
  String get registrationPasswordLabel => 'Parol';

  @override
  String get registrationPasswordError =>
      'Parol kamida 6 belgidan iborat bo\'lishi kerak';

  @override
  String get registrationConfirmPasswordLabel => 'Parolni tasdiqlang';

  @override
  String get registrationConfirmPasswordError => 'Parollar mos kelmadi';

  @override
  String get registrationSignUpButton => 'Ro\'yxatdan o\'tish';

  @override
  String get registrationSwitchToLogin => 'Hisobingiz bormi? Kirish';

  @override
  String get languageEnglish => 'Ingliz tili';

  @override
  String get languageUzbek => 'O\'zbek tili';

  @override
  String get languageRussian => 'Rus tili';

  @override
  String get languageSystemDefault => 'Tizim tili';

  @override
  String get settingsScreenTitle => 'Sozlamalar';

  @override
  String get settingsLanguage => 'Til';

  @override
  String get settingsReceiveNotifications => 'Bildirishnomalarni qabul qilish';

  @override
  String get settingsReceiveNotificationsSubtitle =>
      'Yangi manbalar va muhokamalar haqida yangilanishlarni oling';

  @override
  String get settingsAllowLocation => 'Joylashuvga ruxsat berish';

  @override
  String get settingsAllowLocationSubtitle =>
      'Joylashuvingizni talab qiladigan funksiyalar uchun (agar mavjud bo\'lsa)';

  @override
  String get settingsChangePassword => 'Parolni o\'zgartirish';

  @override
  String get settingsHelpCenter => 'Yordam markazi';

  @override
  String get settingsAboutApp => 'Sud Qo\'llanmasi haqida';

  @override
  String get settingsAppLegalese => '© 2025 Sud Qo\'llanmasi Loyihasi';

  @override
  String get settingsAppDescription =>
      'Sud xodimlarining kasbiy kompetentligi uchun mobil platforma.';

  @override
  String get errorPrefix => 'Xatolik: ';

  @override
  String get days => 'kun';

  @override
  String get resourcesNoResourcesFound => 'Resurslar topilmadi.';

  @override
  String get loginButtonText => 'Kirish';

  @override
  String get signUpButtonText => 'Ro\'yxatdan o\'tish';

  @override
  String get logoutButtonText => 'Chiqish';

  @override
  String get logoutConfirmTitle => 'Chiqishga ishonchingiz komilmi?';

  @override
  String get emailLabel => 'Elektron pochta';

  @override
  String get passwordLabel => 'Parol';

  @override
  String get homeDashboardTitle => 'Boshqaruv paneli';

  @override
  String get communityScreenTitle => 'Hamjamiyat';

  @override
  String get profileScreenTitle => 'Profil';

  @override
  String get editProfileButtonText => 'Profilni tahrirlash';

  @override
  String get guestUser => 'Mehmon foydalanuvchi';

  @override
  String get updateYourInformation => 'Ma\'lumotlaringizni yangilang';

  @override
  String get loginToEditProfile => 'Profilni tahrirlash uchun tizimga kiring';

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get themeOptionsTitle => 'Mavzu variantlari';

  @override
  String get logoutConfirmMessage => 'Chiqishni xohlaysizmi?';

  @override
  String get cancelButton => 'Bekor qilish';

  @override
  String get logoutButton => 'Chiqish';

  @override
  String get resourcesTitle => 'Resurslar';

  @override
  String get resourcesSearchHint => 'Resurslarni qidirish...';

  @override
  String get resourcesFilterByType => 'Tur bo\'yicha filtrlash';

  @override
  String get resourcesAllTypes => 'Barcha turlar';

  @override
  String get resourcesNoResourcesMatch =>
      'Sizning mezonlaringizga mos resurslar topilmadi.';

  @override
  String get resourcesTryAdjusting =>
      'Qidiruv yoki filtringizni o\'zgartirib ko\'ring.';

  @override
  String get resourcesCreateButton => 'Yaratish';

  @override
  String get resourceAddedSuccess => 'Resurs muvaffaqiyatli qo\'shildi!';

  @override
  String resourceAddedError(String error) {
    return 'Resurs qo\'shishda xatolik: $error';
  }

  @override
  String get createResourceScreenTitle => 'Yangi Resurs Yaratish';

  @override
  String get createResourceFormWillBeHere =>
      'Resurs yaratish shakli shu yerda bo\'ladi.';

  @override
  String get saveButtonText => 'Saqlash';

  @override
  String get createResourceTitleLabel => 'Sarlavha';

  @override
  String get createResourceDescriptionLabel => 'Tavsifi';

  @override
  String get createResourceAuthorLabel => 'Muallif';

  @override
  String get createResourceTypeLabel => 'Resurs Turi';

  @override
  String get createResourceUrlLabel => 'URL (Optional)';

  @override
  String couldNotLaunchUrl(Object url) {
    return 'Could not launch $url';
  }

  @override
  String createResourceValidationEmpty(Object fieldName) {
    return 'Iltimos kiriting $fieldName';
  }

  @override
  String createResourceValidationSelect(Object fieldName) {
    return 'Iltimos tanlang $fieldName';
  }

  @override
  String get createResourceValidationInvalidUrl =>
      'Yaroqli URL manzilini kiriting';

  @override
  String get editButtonTooltip => 'Resurs o\'zgartirish';

  @override
  String get editResourceScreenTitle => 'Resurs o\'zgartirish';

  @override
  String get resourceTypeLabel => 'Turi';

  @override
  String get editTopicScreenTitle => 'Munozara Mavzusini Tahrirlash';

  @override
  String get authorLabel => 'Muallif';

  @override
  String get dateAddedLabel => 'Qo\'shilgan';

  @override
  String get launchingUrlMessage => 'URL ishga tushirilmoqda';

  @override
  String get descriptionLabel => 'Tavsifi';

  @override
  String get resourceUpdatedSuccess => 'Resurs muvaffaqiyatli yangilandi!';

  @override
  String resourceUpdatedError(String error) {
    return 'Resursni yangilashda xatolik yuz berdi: $error';
  }

  @override
  String get deleteResourceConfirmTitle => 'Oʻchirishni tasdiqlang';

  @override
  String get deleteResourceConfirmMessage =>
      'Haqiqatan ham bu manbani oʻchirib tashlamoqchimisiz? Bu amalni ortga qaytarib bo\'lmaydi.';

  @override
  String get cancelButtonText => 'Bekor qilish';

  @override
  String get deleteButtonText => 'Oʻchirish';

  @override
  String resourceDeletedSuccess(Object resourceTitle) {
    return '\"$resourceTitle\" resursi muvaffaqiyatli o\'chirildi.';
  }

  @override
  String resourceDeletedError(Object error) {
    return 'Resursni o\'chirishda xatolik yuz berdi: $error';
  }

  @override
  String get deleteButtonTooltip => 'Resursni o\'chirish';

  @override
  String get createANewQuiz => 'Yangi viktorina yaratish';

  @override
  String get quizTitle => 'Viktorina nomi';

  @override
  String get quizDescription => 'Tavsif';

  @override
  String get saveAndAddQuestions => 'Saqlash va savollar qo\'shish';

  @override
  String get failedToCreateQuiz => 'Viktorina yaratib bo\'lmadi';

  @override
  String get addQuestions => 'Savollar qo\'shish';

  @override
  String get finish => 'TUGATISH';

  @override
  String get questionText => 'Savol matni';

  @override
  String get pleaseEnterAQuestion => 'Iltimos, savol kiriting';

  @override
  String get questionType => 'Savol turi';

  @override
  String get multipleChoice => 'Bir nechta tanlov';

  @override
  String get trueFalse => 'To\'g\'ri/Noto\'g\'ri';

  @override
  String get pleaseSelectCorrectAnswer => 'Iltimos, to\'g\'ri javobni tanlang.';

  @override
  String option(Object number) {
    return 'Variant $number';
  }

  @override
  String get pleaseEnterAnOption => 'Iltimos, variantni kiriting';

  @override
  String get addQuestion => 'Savol qo\'shish';

  @override
  String get questionAddedSuccessfully => 'Savol muvaffaqiyatli qo\'shildi!';

  @override
  String get failedToAddQuestion => 'Savol qo\'shib bo\'lmadi';

  @override
  String get noQuestionsAddedYet => 'Hozircha savollar qo\'shilmagan.';

  @override
  String get correctAnswer => 'To\'g\'ri javob';

  @override
  String get quiz => 'Viktorina';

  @override
  String get quizNotFound => 'Viktorina topilmadi';

  @override
  String get failedToLoadQuiz => 'Viktorinani yuklab bo\'lmadi';

  @override
  String question(String index) {
    return 'Savol $index';
  }

  @override
  String totalQuestions(String total) {
    return 'Jami: $total';
  }

  @override
  String get submitQuiz => 'Yakunlash';

  @override
  String get nextQuestion => 'Keyingi savol';

  @override
  String get quizResults => 'Viktorina natijalari';

  @override
  String get quizCompletionMessage => 'Siz viktorinani yakunladingiz!';

  @override
  String get yourScore => 'Sizning natijangiz';

  @override
  String get done => 'Bajarildi';

  @override
  String get failedToSaveAttempt => 'Natijani saqlashda xatolik';

  @override
  String get myQuizHistory => 'Mening Viktorina Tarixim';

  @override
  String get noQuizAttempts =>
      'Siz hali hech qanday viktorinada qatnashmadingiz.';

  @override
  String get score => 'Bal';

  @override
  String get role => 'Rol';

  @override
  String get loading => 'Yuklanmoqda...';

  @override
  String get relatedQuizzesTitle => 'Tegishli testlar';

  @override
  String get noQuizzesAvailable =>
      'Bu resurs uchun hozircha hech qanday test mavjud emas.';

  @override
  String get errorLoadingQuizzes => 'Viktorinalarni yuklashda xatolik';

  @override
  String invalidUrlFormat(Object url) {
    return 'URL formati noto\'g\'ri: $url';
  }

  @override
  String errorLaunchingUrl(Object error) {
    return 'URLni ishga tushirishda xatolik yuz berdi: $error';
  }

  @override
  String createResourceValidationMinLength(Object fieldName, Object length) {
    return '$fieldName kamida $length belgidan iborat bo\'lishi kerak';
  }

  @override
  String createResourceValidationMaxLength(Object fieldName, Object length) {
    return '$fieldName $length belgidan oshmasligi kerak';
  }

  @override
  String get titleMinLength =>
      'Sarlavha kamida 5 ta belgidan iborat bo\'lishi kerak';

  @override
  String get titleMaxLength => 'Sarlavha 100 belgidan oshmasligi kerak';

  @override
  String get createTopicScreenTitle => 'Yangi muhokamani boshlash';

  @override
  String get createTopicTitleLabel => 'Mavzu nomi';

  @override
  String get createTopicContentLabel => 'Muhokama mazmuni';

  @override
  String get createTopicButtonText => 'Muhokama mavzusini yaratish';

  @override
  String get mustBeLoggedInToCreateTopic =>
      'Mavzu yaratish uchun tizimga kirgan bo\'lishingiz kerak.';

  @override
  String get topicCreatedSuccess => 'Mavzu muvaffaqiyatli yaratildi!';

  @override
  String failedToCreateTopic(String error, String xato) {
    return 'Mavzu yaratib bo\'lmadi: $error';
  }

  @override
  String createTopicValidationEmpty(Object fieldName) {
    return '$fieldName bo\'sh bo\'lishi mumkin emas.';
  }

  @override
  String createTopicValidationMinLength(Object fieldName, Object length) {
    return '$fieldName kamida $length belgidan iborat bo\'lishi kerak.';
  }

  @override
  String createTopicValidationMaxLength(Object fieldName, Object length) {
    return '$fieldName $length belgidan oshmasligi kerak.';
  }

  @override
  String get errorLoadingData =>
      'Resurslarni yuklashda xatolik yuz berdi. Qayta urinib ko\'ring.';

  @override
  String failedToUpdateTopic(String error, String xato) {
    return 'Mavzuni yangilashda xatolik yuz berdi: $error';
  }

  @override
  String get topicUpdatedSuccess => 'Mavzu muvaffaqiyatli yangilandi!';

  @override
  String get noDiscussionsYet => 'Hali muhokamalar yo\'q.';

  @override
  String get beTheFirstToStartConversation =>
      'Birinchi bo\'lib suhbatni boshlang!';

  @override
  String get mustBeLoggedInToCreateResource =>
      'Resurs yaratish uchun tizimga kirgan bo\'lishingiz kerak.';

  @override
  String get profileIncompleteToCreateResource =>
      'Profilingiz haqidagi ma\'lumotlar to\'liq emas. Iltimos, profilingizda ismingizni yangilang.';

  @override
  String get profileIncompleteToCreateTopic =>
      'Profilingiz nomi belgilanmagan. Iltimos, profilingizni yangilang.';

  @override
  String get commentCannotBeEmpty => 'Izoh bo\'sh bo\'lishi mumkin emas.';

  @override
  String get mustBeLoggedInToComment =>
      'Izoh berish uchun tizimga kirgan bo\'lishingiz kerak.';

  @override
  String get commentAddedSuccessfully => 'Izoh muvaffaqiyatli qo\'shildi!';

  @override
  String failedToAddComment(String error, String xato) {
    return 'Izoh qo\'shib bo\'lmadi: $error';
  }

  @override
  String postedBy(Object authorName) {
    return 'Muallif: $authorName';
  }

  @override
  String onDate(Object date) {
    return 'kun $date';
  }

  @override
  String get repliesTitle => 'Javoblar';

  @override
  String errorLoadingComments(Object error) {
    return 'Izohlarni yuklashda xatolik yuz berdi: $error';
  }

  @override
  String get noRepliesYet =>
      'Hali javob yo\'q. Birinchi bo\'lib fikr bildiring!';

  @override
  String get writeAReplyHint => 'Javob yozing...';

  @override
  String get sendCommentTooltip => 'Izoh yuborish';

  @override
  String welcomeBack(Object userName) {
    return 'Qaytib xush kelibsiz, $userName!';
  }

  @override
  String get readyToLearnSomethingNew =>
      'Bugun yangi narsalarni o\'rganishga tayyormisiz?';

  @override
  String get quickAccessTitle => 'Tez kirish';

  @override
  String get communityTitle => 'Hamjamiyat';

  @override
  String get profileTitle => 'Profil';

  @override
  String get latestNewsTitle => 'So\'nggi yangiliklar';

  @override
  String get sourceLabel => 'Manba';

  @override
  String get quizzesTitle => 'Viktorinalar';

  @override
  String get urlCannotBeEmpty => 'URL bo\'sh bo\'lishi mumkin emas';

  @override
  String errorLoadingNews(Object error) {
    return 'Yangiliklarni yuklashda xatolik yuz berdi: $error';
  }

  @override
  String get noNewsAvailable => 'Hozirda hech qanday yangilik mavjud emas.';

  @override
  String get adminPanelTitle => 'Admin paneli';

  @override
  String get manageNewsTitle => 'Yangiliklar Boshqaruvi';

  @override
  String get manageNewsSubtitle =>
      'Yangilik maqolalarini qo\'shish, tahrirlash yoki o\'chirish';

  @override
  String get manageUsersTitle => 'Foydalanuvchilarni boshqarish';

  @override
  String get manageUsersSubtitle =>
      'Foydalanuvchilarni ko\'rish va rollarni boshqarish (kelajakda)';

  @override
  String get manageResourcesTitle => 'Resurslarni boshqarish';

  @override
  String get manageResourcesSubtitle =>
      'Barcha o\'quv resurslarini nazorat qilish (kelajakda)';

  @override
  String get confirmDeleteTitle => 'O\'chirishni tasdiqlang';

  @override
  String confirmDeleteNewsMessage(Object newsTitle) {
    return 'Siz \"$newsTitle\"ni o\'chirib tashlamoqchimisiz?';
  }

  @override
  String newsDeletedSuccess(Object newsTitle) {
    return '\"$newsTitle\" muvaffaqiyatli o\'chirildi.';
  }

  @override
  String failedToDeleteNews(String error, Object newsTitle) {
    return '\"$newsTitle\" o\'chirilmadi: $error';
  }

  @override
  String get faqTitle => 'Ko\'p so\'raladigan savollar';

  @override
  String get searchHelp => 'Yordam izlash...';

  @override
  String get allCategories => 'Barcha toifalar';

  @override
  String get helpfulFeedback => 'Bu foydali bo\'ldimi?';

  @override
  String get noArticlesFound => 'Savollar topilmadi';

  @override
  String get settingsNotifications => 'Xabarnomalar';

  @override
  String get changePasswordTitle => 'Parolni o\'zgartirish';

  @override
  String get helpCenterTitle => 'Yordam markazi';

  @override
  String get settingsAbout => 'Ilova haqida';

  @override
  String get passwordUpdatedSuccess => 'Parol muvaffaqiyatli yangilandi';

  @override
  String get errorWrongPassword => 'Joriy parol noto\'g\'ri';

  @override
  String get currentPassword => 'Joriy parol';

  @override
  String get newPassword => 'Yangi parol';

  @override
  String get confirmPassword => 'Parolni tasdiqlang';

  @override
  String get passwordMismatch => 'Parollar mos kelmadi';

  @override
  String get save => 'Saqlash';

  @override
  String get addNewsTooltip => 'Yangi maqola qo\'shish';

  @override
  String get editNewsTooltip => 'Yangilikni tahrirlash';

  @override
  String get deleteNewsTooltip => 'Yangilikni o\'chirish';

  @override
  String get addNewsButton => 'Yangilik qo\'shish';

  @override
  String get noNewsAvailableManager =>
      'Hech qanday yangilik maqolasi topilmadi. Bittasini qo\'shing!';

  @override
  String get editNewsTitle => 'Yangilikni tahrirlash';

  @override
  String get addNewsTitle => 'Yangilik maqolasini qo\'shish';

  @override
  String get saveNewsTooltip => 'Yangilikni saqlash';

  @override
  String get newsTitleLabel => 'Sarlavha';

  @override
  String get pleaseEnterNewsTitle => 'Iltimos, yangilik sarlavhasini kiriting.';

  @override
  String newsTitleMinLength(Object length) {
    return 'Yangiliklar nomi kamida $length belgidan iborat bo\'lishi kerak.';
  }

  @override
  String get newsSourceLabel => 'Manba (masalan, Blog nomi)';

  @override
  String get pleaseEnterNewsSource =>
      'Iltimos, yangiliklar manbasini kiriting.';

  @override
  String get newsUrlLabel => 'Maqola URL manzili';

  @override
  String get pleaseEnterNewsUrl => 'Maqola URL manzilini kiriting.';

  @override
  String get pleaseEnterValidNewsUrl =>
      'Iltimos, to\'g\'ri URL manzilini kiriting (http yoki https bilan boshlanadi).';

  @override
  String get newsImageUrlLabel => 'Rasm URL manzili (ixtiyoriy)';

  @override
  String get pleaseEnterValidImageUrl =>
      'Iltimos, haqiqiy rasm URL manzilini kiriting (http yoki https bilan boshlanadi) yoki bo\'sh qoldiring.';

  @override
  String get publicationDateLabel => 'Nashr qilingan sana';

  @override
  String get pleaseSelectPublicationDate => 'Iltimos, nashr sanasini tanlang.';

  @override
  String get noDateSelected => 'Sana tanlanmagan';

  @override
  String get selectDateTooltip => 'Sanani tanlang';

  @override
  String get updateNewsButton => 'Yangiliklarni yangilash';

  @override
  String get addNewsButtonForm => 'Yangilik maqolasini qo\'shish';

  @override
  String newsUpdatedSuccess(Object newsTitle) {
    return '\"$newsTitle\" muvaffaqiyatli yangilandi.';
  }

  @override
  String newsAddedSuccess(Object newsTitle) {
    return '\"$newsTitle\" muvaffaqiyatli qo\'shildi.';
  }

  @override
  String failedToSaveNews(String error, Object xato) {
    return 'Yangilikni saqlab bo\'lmadi: $error';
  }

  @override
  String errorLoadingUsers(Object error) {
    return 'Foydalanuvchilarni yuklashda xatolik yuz berdi: $error';
  }

  @override
  String get noUsersFound => 'Hech qanday foydalanuvchi topilmadi.';

  @override
  String get noEmailProvided => 'E-pochta taqdim etilmaydi';

  @override
  String get roleLabel => 'Rol';

  @override
  String get registeredOnLabel => 'Ro\'yxatdan o\'tgan';

  @override
  String get manageUsersSubtitleNow =>
      'Ro\'yxatdan o\'tgan foydalanuvchilarni ko\'rish va qidirish';

  @override
  String get manageResourcesSubtitleNow =>
      'Har qanday o\'quv manbasini ko\'rish, tahrirlash yoki o\'chirish';

  @override
  String confirmDeleteResourceMessage(Object resourceTitle) {
    return 'Siz \"$resourceTitle\" manbasini o\'chirib tashlamoqchimisiz?';
  }

  @override
  String failedToDeleteResource(String error, Object resourceTitle) {
    return '\"$resourceTitle\" manbasini o\'chirib bo\'lmadi: $error';
  }

  @override
  String errorLoadingResources(Object error) {
    return 'Resurslarni yuklashda xatolik yuz berdi: $error';
  }

  @override
  String get noResourcesFoundManager => 'Tizimda hech qanday manba topilmadi.';

  @override
  String get editResourceTooltip => 'Resursni tahrirlash';

  @override
  String get deleteResourceTooltip => 'Resursni o\'chirish';

  @override
  String get manageQuizzesTitle => 'Viktorinalarni boshqarish';

  @override
  String get addQuizTooltip => 'Yangi test qo\'shish';

  @override
  String errorLoadingQuizzesAdmin(Object error) {
    return 'Viktorinalarni yuklashda xatolik yuz berdi: $error';
  }

  @override
  String get noQuizzesFoundManager =>
      'Hech qanday test topilmadi. Bittasini qo\'shing!';

  @override
  String confirmDeleteQuizMessage(Object quizTitle) {
    return 'Siz \"$quizTitle\" testini va uning barcha savollarini o\'chirib tashlamoqchimisiz? Bu amalni ortga qaytarib bo\'lmaydi.';
  }

  @override
  String quizDeletedSuccess(Object quizTitle) {
    return '\"$quizTitle\" testi va uning savollari muvaffaqiyatli o\'chirildi.';
  }

  @override
  String failedToDeleteQuiz(String error, Object quizTitle) {
    return '\"$quizTitle\" testini o\'chirib bo\'lmadi: $error';
  }

  @override
  String get editDetailsButton => 'Tafsilotlarni tahrirlash';

  @override
  String get manageQuestionsButton => 'Savollar';

  @override
  String get deleteQuizTooltip => 'Viktorina va savollarni o\'chirish';

  @override
  String get addQuizButton => 'Viktorina qo\'shish';

  @override
  String get manageQuizzesSubtitle =>
      'Barcha testlar va ularning savollarini nazorat qilish';

  @override
  String get registrationEmailError =>
      'Yaroqli elektron pochta manzilini kiriting';

  @override
  String get dashboardXodimTitle => 'Mening Faoliyatim';

  @override
  String get dashboardEkspertTitle => 'Mening Hissam';

  @override
  String get dashboardAdminTitle => 'Tizim Holati';

  @override
  String get seeAllButton => 'Barchasini ko\'rish';

  @override
  String get noGuidesAuthored =>
      'Siz hali hech qanday qo\'llanma yaratmadingiz.';

  @override
  String get adminStatUsers => 'Foydalanuvchilar';

  @override
  String get adminStatGuides => 'Qo\'llanmalar';

  @override
  String get adminStatQuizzes => 'Viktorinalar';

  @override
  String get orDivider => 'YOKI';

  @override
  String get signInWithGoogle => 'Google bilan kirish';

  @override
  String get themeSystemDefault => 'Tizim tili';

  @override
  String get themeLight => 'Yorug\' rejim';

  @override
  String get themeDark => 'Tungi rejim';

  @override
  String get bioOptionalLabel => 'Bio (Ixtiyoriy)';

  @override
  String get profilePictureUrlLabel => 'Profil rasmi URL manzili (Ixtiyoriy)';

  @override
  String get levelBeginner => 'Boshlang\'ich';

  @override
  String get levelIntermediate => 'O\'rta';

  @override
  String get levelAdvanced => 'Ilg\'or';

  @override
  String get levelExpert => 'Ekspert';

  @override
  String get totalPoints => 'Jami ballar';

  @override
  String get nextLevel => 'Keyingi daraja';

  @override
  String pointsToNextLevel(Object points) {
    return 'Keyingi darajaga $points XP';
  }

  @override
  String get manageArticlesTitle => 'Maqolalar Boshqaruvi';

  @override
  String get manageArticlesSubtitle => 'Bilimlar bazasini boshqarish';

  @override
  String get manageVideosTitle => 'Video Darsliklar Boshqaruvi';

  @override
  String get manageVideosSubtitle => 'Video darsliklarni boshqarish';

  @override
  String get manageSystemsTitle => 'Tizimlar Boshqaruvi';

  @override
  String get manageSystemsSubtitle => 'Tizimlar ma\'lumotnomasini boshqarish';

  @override
  String get manageFaqTitle => 'TSS';

  @override
  String get manageFaqSubtitle => 'TSSni boshqarish';

  @override
  String get manageNotificationsTitle => 'Bildirishnomalar';

  @override
  String get manageNotificationsSubtitle => 'Bildirishnomalarni yuborish';

  @override
  String get selectLanguage => 'Tilni tanlang';

  @override
  String topicDeletedSuccess(Object topicTitle) {
    return '\"$topicTitle\" muvaffaqiyatli o\'chirildi.';
  }

  @override
  String failedToDeleteTopic(Object error) {
    return 'Mavzuni o\'chirib bo\'lmadi: $error';
  }

  @override
  String deleteTopicConfirmMessage(Object topicTitle) {
    return 'Siz \"$topicTitle\" mavzusini o\'chirib tashlamoqchimisiz?';
  }

  @override
  String get editTopicTooltip => 'Mavzuni tahrirlash';

  @override
  String get deleteTopicConfirmTitle => 'Mavzuni o\'chirish';

  @override
  String get commentPlural => 'Izohlar';

  @override
  String get commentSingular => 'Izoh';

  @override
  String get deleteTopicTooltip => 'Mavzuni o\'chirish';

  @override
  String get faqCategoryLogin => 'Kirish muammolari';

  @override
  String get faqCategoryPassword => 'Parol muammolari';

  @override
  String get faqCategoryUpload => 'Fayl yuklash';

  @override
  String get faqCategoryAccess => 'Kirish huquqlari';

  @override
  String get faqCategoryGeneral => 'Umumiy savollar';

  @override
  String get faqCategoryTechnical => 'Texnik muammolar';

  @override
  String confirmDeleteArticleMessage(Object articleTitle) {
    return 'Siz \"$articleTitle\" maqolasini o\'chirib tashlamoqchimisiz?';
  }

  @override
  String get addArticleTitle => 'Yangi Maqola';

  @override
  String get editArticleTitle => 'Maqolani Tahrirlash';

  @override
  String get categoryLabel => 'Kategoriya';

  @override
  String get articleCategoryGeneral => 'Umumiy';

  @override
  String get articleCategoryProcedure => 'Protsedura';

  @override
  String get articleCategoryLaw => 'Qonunchilik';

  @override
  String get articleCategoryFaq => 'Ko\'p so\'raladigan';

  @override
  String get contentLabel => 'Mazmuni (Markdown)';

  @override
  String get tagsLabel => 'Teglar (vergul bilan ajrating)';

  @override
  String get tagsHint => 'masalan: sud, qonun, kodeks';

  @override
  String get noPdfSelected => 'PDF fayl tanlanmagan';

  @override
  String get uploadPdfTooltip => 'PDF yuklash';

  @override
  String currentFileLabel(Object url) {
    return 'Joriy fayl: $url';
  }

  @override
  String get existingPdfFile => 'Mavjud PDF fayl';

  @override
  String get articleSavedSuccess => 'Maqola saqlandi';

  @override
  String get titleRequired => 'Sarlavha kiritilishi shart';

  @override
  String get contentRequired => 'Mazmun kiritilishi shart';

  @override
  String confirmDeleteVideoMessage(Object videoTitle) {
    return 'Siz \"$videoTitle\" videosini o\'chirib tashlamoqchimisiz?';
  }

  @override
  String get videoDeletedSuccess => 'Video o\'chirildi';

  @override
  String get noVideosFound => 'Videolar yo\'q';

  @override
  String get addVideoTitle => 'Yangi Video';

  @override
  String get editVideoTitle => 'Videoni Tahrirlash';

  @override
  String get videoSavedSuccess => 'Video saqlandi';

  @override
  String get youtubeIdLabel => 'YouTube ID';

  @override
  String get youtubeIdHint => 'Masalan: dQw4w9WgXcQ';

  @override
  String get youtubeIdRequired => 'YouTube ID kiritilishi shart';

  @override
  String get systemOptionalLabel => 'Tizim (ixtiyoriy)';

  @override
  String get notSelectedLabel => 'Tanlanmagan';

  @override
  String get durationLabel => 'Davomiyligi (soniya)';

  @override
  String get durationHint => 'Masalan: 600';

  @override
  String get durationRequired => 'Davomiylik kiritilishi shart';

  @override
  String get videoTagsHint => 'masalan: login, xatolik, sozlash';

  @override
  String get descriptionRequired => 'Tavsif kiritilishi shart';

  @override
  String confirmDeleteSystemMessage(Object systemName) {
    return 'Siz \"$systemName\" tizimini o\'chirib tashlamoqchimisiz?';
  }

  @override
  String get systemDeletedSuccess => 'Tizim o\'chirildi';

  @override
  String get noSystemsFound => 'Tizimlar yo\'q';

  @override
  String get addSystemTitle => 'Yangi Tizim';

  @override
  String get editSystemTitle => 'Tizimni Tahrirlash';

  @override
  String get systemSavedSuccess => 'Tizim saqlandi';

  @override
  String get shortNameLabel => 'Qisqa nomi';

  @override
  String get shortNameHint => 'Masalan: e-SUD';

  @override
  String get nameRequired => 'Nom kiritilishi shart';

  @override
  String get fullNameLabel => 'To\'liq nomi';

  @override
  String get fullNameRequired => 'To\'liq nom kiritilishi shart';

  @override
  String get websiteUrlLabel => 'Veb-sayt manzili';

  @override
  String get urlRequired => 'URL kiritilishi shart';

  @override
  String get logoUrlLabel => 'Logo URL';

  @override
  String get logoUrlRequired => 'Logo URL kiritilishi shart';

  @override
  String get statusLabel => 'Holati';

  @override
  String get loginGuideIdLabel => 'Kirish qo\'llanmasi ID (ixtiyoriy)';

  @override
  String get videoGuideIdLabel => 'Video qo\'llanma ID (ixtiyoriy)';

  @override
  String confirmDeleteFaqMessage(Object question) {
    return 'Siz \"$question\" savolini o\'chirib tashlamoqchimisiz?';
  }

  @override
  String get faqDeletedSuccess => 'Savol o\'chirildi';

  @override
  String get noFaqsFound => 'Savollar yo\'q';

  @override
  String get addFaqTitle => 'Yangi Savol';

  @override
  String get editFaqTitle => 'Savolni Tahrirlash';

  @override
  String get faqSavedSuccess => 'Savol saqlandi';

  @override
  String get questionLabel => 'Savol';

  @override
  String get questionRequired => 'Savol kiritilishi shart';

  @override
  String get answerLabel => 'Javob (Markdown)';

  @override
  String get answerRequired => 'Javob kiritilishi shart';

  @override
  String get add => 'Qo\'shish';

  @override
  String get titleLabel => 'Sarlavha';

  @override
  String get edit => 'Tahrirlash';

  @override
  String get delete => 'O\'chirish';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get search => 'Qidirish...';

  @override
  String get fieldRequired => 'Maydon to\'ldirilishi shart';

  @override
  String get confirmDelete => 'Haqiqatan ham o\'chirmoqchimisiz?';

  @override
  String get successSaved => 'Muvaffaqiyatli saqlandi';

  @override
  String get successDeleted => 'Muvaffaqiyatli o\'chirildi';

  @override
  String get notificationManagementTitle => 'Xabarnomalar Boshqaruvi';

  @override
  String get notificationHistoryTitle => 'Xabarnomalar Tarixi';

  @override
  String get notificationHistoryPlaceholder =>
      'Bu yerda yuborilgan xabarnomalar tarixi ko\'rinadi (tez orada).';

  @override
  String get sendNewNotificationButton => 'Yangi Xabarnoma Yuborish';

  @override
  String get sendNotificationTitle => 'Xabarnoma Yuborish';

  @override
  String get notificationSentSuccess => 'Xabarnoma yuborildi';

  @override
  String get notificationTitleLabel => 'Sarlavha';

  @override
  String get notificationTitleRequired => 'Sarlavha kiritilishi shart';

  @override
  String get notificationBodyLabel => 'Xabar matni';

  @override
  String get notificationBodyRequired => 'Matn kiritilishi shart';

  @override
  String get notificationTypeLabel => 'Xabarnoma turi';

  @override
  String get targetAudienceLabel => 'Auditoriya';

  @override
  String get resourceTabArticles => 'Maqolalar';

  @override
  String get resourceTabVideos => 'Videolar';

  @override
  String get resourceTabFiles => 'Fayllar';

  @override
  String get filesTabTitle => 'Fayllar';

  @override
  String get systemsDirectoryTitle => 'Sud Axborot Tizimlari';

  @override
  String get bookmarkSaveTooltip => 'Saqlash';

  @override
  String get bookmarkRemoveTooltip => 'Olib tashlash';

  @override
  String get resourceTypeOther => 'Boshqalar';

  @override
  String get openFile => 'Faylni ochish';

  @override
  String get fileSize => 'Fayl hajmi';

  @override
  String get selectFile => 'Fayl tanlang';

  @override
  String get upload => 'Yuklash';

  @override
  String get processing => 'Bajarilmoqda...';

  @override
  String get urlLabel => 'Havola (URL)';

  @override
  String get resourceTypePDF => 'PDF Qo\'llanma';

  @override
  String get resourceTypeVideo => 'Video Darslik';

  @override
  String get resourceTypeLink => 'Veb Havola';

  @override
  String get onlySaved => 'Faqat saqlanganlar';

  @override
  String get searchArticlesPlaceholder => 'Maqolalarni qidirish...';

  @override
  String get filterAll => 'Barchasi';

  @override
  String get noResultsFound => 'Hech narsa topilmadi';

  @override
  String get noArticlesAvailable => 'Maqolalar mavjud emas';

  @override
  String get noVideosAvailable => 'Videolar mavjud emas';

  @override
  String get actionCreateDiscussion => 'Muhokama yaratish';

  @override
  String get actionCreateResource => 'Resurs yaratish';

  @override
  String get actionCreateQuiz => 'Test yaratish';

  @override
  String get notificationsTitle => 'Xabarnomalar';

  @override
  String get loginRequired => 'Tizimga kirish kerak';

  @override
  String get markAllAsReadTooltip => 'Hammasini o\'qilgan deb belgilash';

  @override
  String get allNotificationsReadMessage =>
      'Barcha xabarnomalar o\'qilgan deb belgilandi';

  @override
  String get noNotifications => 'Xabarnomalar yo\'q';

  @override
  String get closeAction => 'Yopish';

  @override
  String get leaderboardTitle => 'Liderlar Jadvali';

  @override
  String pointsEarned(int points) {
    return 'Siz $points XP oldingiz!';
  }

  @override
  String levelUp(String level) {
    return 'Tabriklaymiz! Yangi daraja: $level';
  }

  @override
  String get rank => 'O\'rin';

  @override
  String get quizHistoryTitle => 'Viktorina Tarixi';

  @override
  String get seeAll => 'Barchasini ko\'rish';

  @override
  String get today => 'Bugun';

  @override
  String get yesterday => 'Kecha';

  @override
  String get thisWeek => 'Shu hafta';

  @override
  String get older => 'Eski natijalar';

  @override
  String get contactSupport => 'Qo\'llab-quvvatlash';

  @override
  String get landingTitle => 'Professional Platforma';

  @override
  String get landingSubtitle =>
      'Huquqiy bilimingizni oshiring. Istalgan vaqtda.';

  @override
  String get landingLogin => 'Kirish';

  @override
  String get landingRegister => 'Ro\'yxatdan o\'tish';

  @override
  String get featureKnowledgeBase => 'Bilimlar Bazasi';

  @override
  String get featureKnowledgeBaseDesc =>
      'Keng ko\'lamli huquqiy resurslar va hujjatlar kutubxonasi.';

  @override
  String get featureVideoTutorials => 'Video Darsliklar';

  @override
  String get featureVideoTutorialsDesc =>
      'Mutaxassislar tomonidan tayyorlangan video qo\'llanmalar.';

  @override
  String get featureGamification => 'Gamifikatsiya';

  @override
  String get featureGamificationDesc =>
      'XP va nishonlar yig\'ing, reytingda bellashing.';

  @override
  String get analyticsTitle => 'O\'quv Tahlili (xAPI)';

  @override
  String get analyticsSubtitle => 'O\'quv Yozuvlari';

  @override
  String get totalRecords => 'Jami Yozuvlar';

  @override
  String get realTime => 'Real vaqtda';

  @override
  String get activityDistribution => 'Faoliyat Taqsimoti';

  @override
  String get recentActivityFeed => 'So\'nggi Faoliyatlar';

  @override
  String get noRecords => 'Hozircha o\'quv yozuvlari topilmadi.';

  @override
  String get unknownUser => 'Noma\'lum Foydalanuvchi';

  @override
  String get unknownObject => 'Noma\'lum Obyekt';

  @override
  String get justNow => 'Hozirgina';

  @override
  String get quizzes => 'Viktorinalar';

  @override
  String get simulations => 'Simulyatsiyalar';

  @override
  String get catNewEmployees => 'Yangi Xodimlar';

  @override
  String get catIctSpecialists => 'AKT Mutaxassislari';

  @override
  String get catSystems => 'Tizimlar';

  @override
  String get catAuth => 'Kirish/Login';

  @override
  String get catGeneral => 'Umumiy';

  @override
  String get rankBeginner => 'Boshlang\'ich';

  @override
  String get rankIntermediate => 'O\'rta Daraja';

  @override
  String get rankAdvanced => 'Ilg\'or';

  @override
  String get sysCatPrimary => 'Asosiy Tizimlar';

  @override
  String get sysCatSecondary => 'Qo\'shimcha Tizimlar';

  @override
  String get sysCatSupport => 'Yordam Tizimlari';

  @override
  String get sysStatusActive => 'Faol';

  @override
  String get sysStatusMaintenance => 'Ta\'mirlashda';

  @override
  String get sysStatusInactive => 'Nofaol';

  @override
  String videoViews(int count) {
    return '$count ko\'rishlar';
  }

  @override
  String get videoAuthorSubtitle => 'Muallif';

  @override
  String get videoDescriptionTitle => 'Tavsif';

  @override
  String get sysStatusDeprecated => 'Eski Versiya';

  @override
  String get sysStatusOffline => 'O\'chirilgan';

  @override
  String get systemsDirectoryAll => 'Barchasi';

  @override
  String systemsDirectoryError(String error) {
    return 'Xatolik yuz berdi: $error';
  }

  @override
  String get systemsDirectoryEmpty => 'Tizimlar mavjud emas';

  @override
  String get backToKnowledgeBase => 'Qo\'llanmalarga qaytish';

  @override
  String get quizSuccessMessage => 'Ajoyib natija!';

  @override
  String get quizFailureMessage => 'Yana bir bor urinib ko\'ring!';

  @override
  String get speedBonus => 'TEZKOR BONUS';

  @override
  String get levelSpecialist => 'Mutaxassis';

  @override
  String get levelMaster => 'Usta (Master)';

  @override
  String get errorCouldNotOpenLink => 'Havolani ochib bo\'lmadi';

  @override
  String get errorResourceNotFound => 'Qo\'llanma topilmadi';

  @override
  String get errorVideoNotFound => 'Video topilmadi';

  @override
  String get errorPdfOpen => 'PDF faylni ochib bo\'lmadi';

  @override
  String get errorTelegramOpen => 'Telegram havolasini ochib bo\'lmadi';

  @override
  String errorGeneric(Object error) {
    return 'Xatolik yuz berdi: $error';
  }

  @override
  String get labelTrue => 'To\'g\'ri';

  @override
  String get labelFalse => 'Noto\'g\'ri';

  @override
  String get labelPass => 'O\'TDI';

  @override
  String get labelFail => 'YIQILDI';

  @override
  String get labelPdfAvailable => 'PDF mavjud';

  @override
  String get actionOk => 'OK';

  @override
  String get actionGoBack => 'Orqaga qaytish';

  @override
  String get searchNoResults => 'Hech narsa topilmadi';
}
