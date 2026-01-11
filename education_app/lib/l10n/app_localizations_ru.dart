// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Справочник Судьи';

  @override
  String get openInYoutube => 'Открыть в YouTube';

  @override
  String get watchOnYoutube => 'Смотреть в YouTube';

  @override
  String get loginWelcomeTitle => 'Добро пожаловать!';

  @override
  String get loginWelcomeSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get bottomNavHome => 'Главная';

  @override
  String get bottomNavResources => 'Руководства';

  @override
  String get bottomNavCommunity => 'Обсуждение';

  @override
  String get bottomNavProfile => 'Профиль';

  @override
  String get resourcesScreenTitle => 'Руководства и обучающие материалы';

  @override
  String get roleXodim => 'Сотрудник';

  @override
  String get roleEkspert => 'Эксперт';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get registrationTitle => 'Создать учётную запись';

  @override
  String get registrationSubtitle => 'Присоединяйтесь к профессиональному сообществу!';

  @override
  String get registrationFullNameLabel => 'ФИО';

  @override
  String get registrationFullNameError => 'Пожалуйста, введите своё полное имя';

  @override
  String get registrationRoleLabel => 'Ваша роль';

  @override
  String get registrationRoleError => 'Выберите роль';

  @override
  String get registrationRoleXodim => 'Обычный сотрудник';

  @override
  String get registrationRoleEkspert => 'Эксперт (создатель руководства)';

  @override
  String get registrationPasswordLabel => 'Пароль';

  @override
  String get registrationPasswordError => 'Пароль должен быть не менее 6 символов';

  @override
  String get registrationConfirmPasswordLabel => 'Подтвердить пароль';

  @override
  String get registrationConfirmPasswordError => 'Пароли не совпали';

  @override
  String get registrationSignUpButton => 'Зарегистрироваться';

  @override
  String get registrationSwitchToLogin => 'У вас есть учётная запись? Войти';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageUzbek => 'Узбекский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageSystemDefault => 'Системный язык';

  @override
  String get settingsScreenTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsReceiveNotifications => 'Получать уведомления';

  @override
  String get settingsReceiveNotificationsSubtitle => 'Получайте обновления о новых ресурсах и обсуждениях';

  @override
  String get settingsAllowLocation => 'Разрешить доступ к местоположению';

  @override
  String get settingsAllowLocationSubtitle => 'Для функций, требующих вашего местоположения (если есть)';

  @override
  String get settingsChangePassword => 'Изменить пароль';

  @override
  String get settingsHelpCenter => 'Центр помощи';

  @override
  String get settingsAboutApp => 'О Справочнике Судьи';

  @override
  String get settingsAppLegalese => '© 2025 Проект Справочник Судьи';

  @override
  String get settingsAppDescription => 'Мобильная платформа для повышения профессиональной компетентности работников суда.';

  @override
  String get errorPrefix => 'Ошибка: ';

  @override
  String get days => 'дней';

  @override
  String get resourcesNoResourcesFound => 'Ресурсы не найдены.';

  @override
  String get loginButtonText => 'Войти';

  @override
  String get signUpButtonText => 'Зарегистрироваться';

  @override
  String get logoutButtonText => 'Выйти';

  @override
  String get logoutConfirmTitle => 'Вы уверены, что хотите выйти?';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get homeDashboardTitle => 'Панель управления';

  @override
  String get communityScreenTitle => 'Сообщество';

  @override
  String get profileScreenTitle => 'Профиль';

  @override
  String get editProfileButtonText => 'Редактировать профиль';

  @override
  String get guestUser => 'Гость';

  @override
  String get updateYourInformation => 'Обновите вашу информацию';

  @override
  String get loginToEditProfile => 'Войдите, чтобы редактировать профиль';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get themeOptionsTitle => 'Опции темы';

  @override
  String get logoutConfirmMessage => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get logoutButton => 'Выйти';

  @override
  String get resourcesTitle => 'Ресурсы';

  @override
  String get resourcesSearchHint => 'Поиск ресурсов...';

  @override
  String get resourcesFilterByType => 'Фильтровать по типу';

  @override
  String get resourcesAllTypes => 'Все типы';

  @override
  String get resourcesNoResourcesMatch => 'Ресурсы, соответствующие вашим критериям, не найдены.';

  @override
  String get resourcesTryAdjusting => 'Попробуйте изменить поиск или фильтр.';

  @override
  String get resourcesCreateButton => 'Создать';

  @override
  String get resourceAddedSuccess => 'Ресурс успешно добавлен!';

  @override
  String resourceAddedError(String error) {
    return 'Ошибка при добавлении ресурса: $error';
  }

  @override
  String get createResourceScreenTitle => 'Создать Новый Ресурс';

  @override
  String get createResourceFormWillBeHere => 'Форма создания ресурса будет здесь.';

  @override
  String get saveButtonText => 'Сохранить';

  @override
  String get createResourceTitleLabel => 'Название';

  @override
  String get createResourceDescriptionLabel => 'Описание';

  @override
  String get createResourceAuthorLabel => 'Автор';

  @override
  String get createResourceTypeLabel => 'Тип ресурса';

  @override
  String get createResourceUrlLabel => 'URL (Optional)';

  @override
  String couldNotLaunchUrl(Object url) {
    return 'Could not launch $url';
  }

  @override
  String createResourceValidationEmpty(Object fieldName) {
    return 'Пожалуйста, введите $fieldName';
  }

  @override
  String createResourceValidationSelect(Object fieldName) {
    return 'Пожалуйста, выберите $fieldName';
  }

  @override
  String get createResourceValidationInvalidUrl => 'Введите действительный URL-адрес';

  @override
  String get editButtonTooltip => 'Редактировать ресурс';

  @override
  String get editResourceScreenTitle => 'Редактировать ресурс';

  @override
  String get resourceTypeLabel => 'Тип';

  @override
  String get editTopicScreenTitle => 'Редактировать тему обсуждения';

  @override
  String get authorLabel => 'Автор';

  @override
  String get dateAddedLabel => 'Добавлено';

  @override
  String get launchingUrlMessage => 'Запуск URL...';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get resourceUpdatedSuccess => 'Ресурс успешно обновлен!';

  @override
  String resourceUpdatedError(String error) {
    return 'Ошибка при обновлении ресурса: $error';
  }

  @override
  String get deleteResourceConfirmTitle => 'Подтвердите удаление';

  @override
  String get deleteResourceConfirmMessage => 'Вы уверены, что хотите удалить этот ресурс? Это действие не может быть отменено.';

  @override
  String get cancelButtonText => 'Отмена';

  @override
  String get deleteButtonText => 'Удалить';

  @override
  String resourceDeletedSuccess(Object resourceTitle) {
    return 'Ресурс \"$resourceTitle\" успешно удален.';
  }

  @override
  String resourceDeletedError(Object error) {
    return 'Ошибка удаления ресурса: $error';
  }

  @override
  String get deleteButtonTooltip => 'Удалить ресурс';

  @override
  String get createANewQuiz => 'Создать новую викторину';

  @override
  String get quizTitle => 'Название викторины';

  @override
  String get quizDescription => 'Описание';

  @override
  String get saveAndAddQuestions => 'Сохранить и добавить вопросы';

  @override
  String get failedToCreateQuiz => 'Не удалось создать викторину';

  @override
  String get addQuestions => 'Добавить вопросы';

  @override
  String get finish => 'ЗАВЕРШИТЬ';

  @override
  String get questionText => 'Текст вопроса';

  @override
  String get pleaseEnterAQuestion => 'Пожалуйста, введите вопрос';

  @override
  String get questionType => 'Тип вопроса';

  @override
  String get multipleChoice => 'Множественный выбор';

  @override
  String get trueFalse => 'Верно/Неверно';

  @override
  String get pleaseSelectCorrectAnswer => 'Пожалуйста, выберите правильный ответ.';

  @override
  String option(Object number) {
    return 'Вариант $number';
  }

  @override
  String get pleaseEnterAnOption => 'Пожалуйста, введите вариант';

  @override
  String get addQuestion => 'Добавить вопрос';

  @override
  String get questionAddedSuccessfully => 'Вопрос успешно добавлен!';

  @override
  String get failedToAddQuestion => 'Не удалось добавить вопрос';

  @override
  String get noQuestionsAddedYet => 'Вопросы еще не добавлены.';

  @override
  String get correctAnswer => 'Правильный ответ';

  @override
  String get quiz => 'Викторина';

  @override
  String get quizNotFound => 'Тест не найден';

  @override
  String get failedToLoadQuiz => 'Не удалось загрузить тест';

  @override
  String question(String index) {
    return 'Вопрос $index';
  }

  @override
  String totalQuestions(String total) {
    return 'Всего: $total';
  }

  @override
  String get submitQuiz => 'Завершить';

  @override
  String get nextQuestion => 'Следующий вопрос';

  @override
  String get quizResults => 'Результаты теста';

  @override
  String get quizCompletionMessage => 'Вы завершили викторину!';

  @override
  String get yourScore => 'Ваш результат';

  @override
  String get done => 'Готово';

  @override
  String get failedToSaveAttempt => 'Ошибка при сохранении результата';

  @override
  String get myQuizHistory => 'Моя история викторин';

  @override
  String get noQuizAttempts => 'Вы еще не проходили ни одной викторины.';

  @override
  String get score => 'Счет';

  @override
  String get role => 'Роль';

  @override
  String get loading => 'Загрузка...';

  @override
  String get relatedQuizzesTitle => 'Похожие тесты';

  @override
  String get noQuizzesAvailable => 'Пока нет доступных тестов для этого ресурса';

  @override
  String get errorLoadingQuizzes => 'Ошибка загрузки тестов';

  @override
  String invalidUrlFormat(Object url) {
    return 'Неверный формат URL: $url';
  }

  @override
  String errorLaunchingUrl(Object error) {
    return 'Ошибка запуска URL: $error';
  }

  @override
  String createResourceValidationMinLength(Object fieldName, Object length) {
    return '$fieldName должно быть не менее $length символов в длину';
  }

  @override
  String createResourceValidationMaxLength(Object fieldName, Object length) {
    return '$fieldName не может превышать $length символов';
  }

  @override
  String get titleMinLength => 'Заголовок должен быть не менее 5 символов в длину';

  @override
  String get titleMaxLength => 'Заголовок не может превышать 100 символов';

  @override
  String get createTopicScreenTitle => 'Начать новое обсуждение';

  @override
  String get createTopicTitleLabel => 'Заголовок темы';

  @override
  String get createTopicContentLabel => 'Содержимое обсуждения';

  @override
  String get createTopicButtonText => 'Создать тему обсуждения';

  @override
  String get mustBeLoggedInToCreateTopic => 'Чтобы создать тему, вам необходимо войти в систему.';

  @override
  String get topicCreatedSuccess => 'Тема создана успешно!';

  @override
  String failedToCreateTopic(String error, String xato) {
    return 'Не удалось создать тему: $error';
  }

  @override
  String createTopicValidationEmpty(Object fieldName) {
    return '$fieldName не может быть пустым.';
  }

  @override
  String createTopicValidationMinLength(Object fieldName, Object length) {
    return '$fieldName должно быть не менее $length символов в длину.';
  }

  @override
  String createTopicValidationMaxLength(Object fieldName, Object length) {
    return '$fieldName не может превышать $length символов в длину.';
  }

  @override
  String get errorLoadingData => 'Произошла ошибка при загрузке ресурсов. Повторите попытку.';

  @override
  String failedToUpdateTopic(String error, String xato) {
    return 'Ошибка обновления темы: $error';
  }

  @override
  String get topicUpdatedSuccess => 'Тема успешно обновлена!';

  @override
  String get noDiscussionsYet => 'Пока нет обсуждений.';

  @override
  String get beTheFirstToStartConversation => 'Начните разговор первым!';

  @override
  String get mustBeLoggedInToCreateResource => 'Вы должны войти в систему, чтобы создать ресурс.';

  @override
  String get profileIncompleteToCreateResource => 'Информация вашего профиля неполная. Пожалуйста, обновите свое имя в вашем профиле.';

  @override
  String get profileIncompleteToCreateTopic => 'Имя вашего профиля не установлено. Пожалуйста, обновите свой профиль.';

  @override
  String get commentCannotBeEmpty => 'Комментарий не может быть пустым.';

  @override
  String get mustBeLoggedInToComment => 'Вы должны войти в систему, чтобы оставить комментарий.';

  @override
  String get commentAddedSuccessfully => 'Комментарий успешно добавлен!';

  @override
  String failedToAddComment(String error, String xato) {
    return 'Не удалось добавить комментарий: $error';
  }

  @override
  String postedBy(Object authorName) {
    return 'Опубликовано $authorName';
  }

  @override
  String onDate(Object date) {
    return 'в $date';
  }

  @override
  String get repliesTitle => 'Ответы';

  @override
  String errorLoadingComments(Object error) {
    return 'Ошибка загрузки комментариев: $error';
  }

  @override
  String get noRepliesYet => 'Пока нет ответов. Станьте первым, кто оставит комментарий!';

  @override
  String get writeAReplyHint => 'Напишите ответ...';

  @override
  String get sendCommentTooltip => 'Отправить комментарий';

  @override
  String welcomeBack(Object userName) {
    return 'С возвращением, $userName!';
  }

  @override
  String get readyToLearnSomethingNew => 'Готовы узнать что-то новое сегодня?';

  @override
  String get quickAccessTitle => 'Быстрый доступ';

  @override
  String get communityTitle => 'Сообщество';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get latestNewsTitle => 'Последние новости';

  @override
  String get sourceLabel => 'Источник';

  @override
  String get quizzesTitle => 'Тестовые задания';

  @override
  String get urlCannotBeEmpty => 'URL не может быть пустым';

  @override
  String errorLoadingNews(Object error) {
    return 'Ошибка загрузки новостей: $error';
  }

  @override
  String get noNewsAvailable => 'В данный момент новостей нет.';

  @override
  String get adminPanelTitle => 'Панель администратора';

  @override
  String get manageNewsTitle => 'Управление новостями';

  @override
  String get manageNewsSubtitle => 'Добавление, редактирование или удаление новостных статей';

  @override
  String get manageUsersTitle => 'Управление пользователями';

  @override
  String get manageUsersSubtitle => 'Просмотр пользователей и управление ролями (в будущем)';

  @override
  String get manageResourcesTitle => 'Управление ресурсами';

  @override
  String get manageResourcesSubtitle => 'Управление всеми учебными ресурсами (в будущем)';

  @override
  String get confirmDeleteTitle => 'Подтвердить удаление';

  @override
  String confirmDeleteNewsMessage(Object newsTitle) {
    return 'Вы уверены, что хотите удалить \"$newsTitle\"?';
  }

  @override
  String newsDeletedSuccess(Object newsTitle) {
    return '\"$newsTitle\" успешно удален.';
  }

  @override
  String failedToDeleteNews(String error, Object newsTitle) {
    return 'Не удалось удалить \"$newsTitle\": $error';
  }

  @override
  String get faqTitle => 'FAQ';

  @override
  String get searchHelp => 'Поиск справки...';

  @override
  String get allCategories => 'Все категории';

  @override
  String get helpfulFeedback => 'Была ли эта статья полезной?';

  @override
  String get noArticlesFound => 'Статьи не найдены.';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get changePasswordTitle => 'Изменить пароль';

  @override
  String get helpCenterTitle => 'Центр помощи';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get passwordUpdatedSuccess => 'Пароль успешно обновлен';

  @override
  String get errorWrongPassword => 'Неверный текущий пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get passwordMismatch => 'Пароли не совпадают';

  @override
  String get save => 'Сохранить';

  @override
  String get addNewsTooltip => 'Добавить новую новостную статью';

  @override
  String get editNewsTooltip => 'Редактировать новость';

  @override
  String get deleteNewsTooltip => 'Удалить новость';

  @override
  String get addNewsButton => 'Добавить новость';

  @override
  String get noNewsAvailableManager => 'Нет новостных статей. Добавьте одну!';

  @override
  String get editNewsTitle => 'Редактировать новость';

  @override
  String get addNewsTitle => 'Добавить новостную статью';

  @override
  String get saveNewsTooltip => 'Сохранить новость';

  @override
  String get newsTitleLabel => 'Заголовок';

  @override
  String get pleaseEnterNewsTitle => 'Введите заголовок новости';

  @override
  String newsTitleMinLength(Object length) {
    return 'Заголовок новости должен быть не менее $length символов';
  }

  @override
  String get newsSourceLabel => 'Источник (например, название блога)';

  @override
  String get pleaseEnterNewsSource => 'Введите источник новостей';

  @override
  String get newsUrlLabel => 'URL статьи';

  @override
  String get pleaseEnterNewsUrl => 'Введите URL статьи';

  @override
  String get pleaseEnterValidNewsUrl => 'Введите действительный URL (начинающийся с http или https).';

  @override
  String get newsImageUrlLabel => 'URL изображения (необязательно)';

  @override
  String get pleaseEnterValidImageUrl => 'Введите действительный URL изображения (начинающийся с http или https) или оставьте поле пустым.';

  @override
  String get publicationDateLabel => 'Дата публикации';

  @override
  String get pleaseSelectPublicationDate => 'Выберите дату публикации.';

  @override
  String get noDateSelected => 'Дата не выбрана';

  @override
  String get selectDateTooltip => 'Выберите дату';

  @override
  String get updateNewsButton => 'Обновить новости';

  @override
  String get addNewsButtonForm => 'Добавить новостную статью';

  @override
  String newsUpdatedSuccess(Object newsTitle) {
    return '\"$newsTitle\" успешно обновлено.';
  }

  @override
  String newsAddedSuccess(Object newsTitle) {
    return '\"$newsTitle\" успешно добавлено.';
  }

  @override
  String failedToSaveNews(String error, Object xato) {
    return 'Не удалось сохранить новости: $error';
  }

  @override
  String errorLoadingUsers(Object error) {
    return 'Ошибка загрузки пользователей: $error';
  }

  @override
  String get noUsersFound => 'Пользователи не найдены.';

  @override
  String get noEmailProvided => 'Адрес электронной почты не указан';

  @override
  String get roleLabel => 'Роль';

  @override
  String get registeredOnLabel => 'Зарегистрирован';

  @override
  String get manageUsersSubtitleNow => 'Просмотр и поиск зарегистрированных пользователей';

  @override
  String get manageResourcesSubtitleNow => 'Просмотр, редактирование или удаление любого учебного ресурса';

  @override
  String confirmDeleteResourceMessage(Object resourceTitle) {
    return 'Вы уверены, что хотите удалить ресурс \"$resourceTitle\"?';
  }

  @override
  String failedToDeleteResource(String error, Object resourceTitle) {
    return 'Не удалось удалить ресурс \"$resourceTitle\": $error';
  }

  @override
  String errorLoadingResources(Object error) {
    return 'Ошибка загрузки ресурсов: $error';
  }

  @override
  String get noResourcesFoundManager => 'Ресурсы в системе не найдены.';

  @override
  String get editResourceTooltip => 'Изменить ресурс';

  @override
  String get deleteResourceTooltip => 'Удалить ресурс';

  @override
  String get manageQuizzesTitle => 'Управление тестами';

  @override
  String get addQuizTooltip => 'Добавить новый тест';

  @override
  String errorLoadingQuizzesAdmin(Object error) {
    return 'Ошибка загрузки тестов: $error';
  }

  @override
  String get noQuizzesFoundManager => 'Тестов не найдено. Добавьте один!';

  @override
  String confirmDeleteQuizMessage(Object quizTitle) {
    return 'Вы уверены, что хотите удалить тест \"$quizTitle\" и все его вопросы? Это действие нельзя отменить.';
  }

  @override
  String quizDeletedSuccess(Object quizTitle) {
    return 'Тест \"$quizTitle\" и его вопросы успешно удалены.';
  }

  @override
  String failedToDeleteQuiz(String error, Object quizTitle) {
    return 'Не удалось удалить тест \"$quizTitle\": $error';
  }

  @override
  String get editDetailsButton => 'Изменить сведения';

  @override
  String get manageQuestionsButton => 'Вопросы';

  @override
  String get deleteQuizTooltip => 'Удалить тест и Вопросы';

  @override
  String get addQuizButton => 'Добавить тест';

  @override
  String get manageQuizzesSubtitle => 'Контролировать все тесты и их вопросы';

  @override
  String get registrationEmailError => 'Введите действительный адрес электронной почты';

  @override
  String get dashboardXodimTitle => 'Моя активность';

  @override
  String get dashboardEkspertTitle => 'Мой вклад';

  @override
  String get dashboardAdminTitle => 'Обзор системы';

  @override
  String get seeAllButton => 'Посмотреть все';

  @override
  String get noGuidesAuthored => 'Вы еще не создали ни одного руководства.';

  @override
  String get adminStatUsers => 'Пользователи';

  @override
  String get adminStatGuides => 'Руководства';

  @override
  String get adminStatQuizzes => 'Викторины';

  @override
  String get orDivider => 'ИЛИ';

  @override
  String get signInWithGoogle => 'Войти через Google';

  @override
  String get themeSystemDefault => 'Системный';

  @override
  String get themeLight => 'Светлая тема';

  @override
  String get themeDark => 'Темная тема';

  @override
  String get bioOptionalLabel => 'Био (необязательно)';

  @override
  String get profilePictureUrlLabel => 'URL изображения профиля (необязательно)';

  @override
  String get levelBeginner => 'Новичок';

  @override
  String get levelIntermediate => 'Средний';

  @override
  String get levelAdvanced => 'Продвинутый';

  @override
  String get levelExpert => 'Эксперт';

  @override
  String get totalPoints => 'Всего очков';

  @override
  String get nextLevel => 'Следующий уровень';

  @override
  String pointsToNextLevel(Object points) {
    return '$points XP до следующего уровня';
  }

  @override
  String get manageArticlesTitle => 'Статьи';

  @override
  String get manageArticlesSubtitle => 'Управление базой знаний';

  @override
  String get manageVideosTitle => 'Видео';

  @override
  String get manageVideosSubtitle => 'Управление видеоуроками';

  @override
  String get manageSystemsTitle => 'Системы';

  @override
  String get manageSystemsSubtitle => 'Управление справочником систем';

  @override
  String get manageFaqTitle => 'FAQ';

  @override
  String get manageFaqSubtitle => 'Управление частыми вопросами';

  @override
  String get manageNotificationsTitle => 'Уведомления';

  @override
  String get manageNotificationsSubtitle => 'Отправить уведомления';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String topicDeletedSuccess(Object topicTitle) {
    return 'Тема \"$topicTitle\" успешно удалена.';
  }

  @override
  String failedToDeleteTopic(Object error) {
    return 'Не удалось удалить тему: $error';
  }

  @override
  String deleteTopicConfirmMessage(Object topicTitle) {
    return 'Вы уверены, что хотите удалить тему \"$topicTitle\"?';
  }

  @override
  String get editTopicTooltip => 'Редактировать тему';

  @override
  String get deleteTopicConfirmTitle => 'Удалить тему';

  @override
  String get commentPlural => 'Комментарии';

  @override
  String get commentSingular => 'Комментарий';

  @override
  String get deleteTopicTooltip => 'Удалить тему';

  @override
  String get faqCategoryLogin => 'Проблемы со входом';

  @override
  String get faqCategoryPassword => 'Проблемы с паролем';

  @override
  String get faqCategoryUpload => 'Загрузка файлов';

  @override
  String get faqCategoryAccess => 'Права доступа';

  @override
  String get faqCategoryGeneral => 'Общие вопросы';

  @override
  String get faqCategoryTechnical => 'Технические проблемы';

  @override
  String confirmDeleteArticleMessage(Object articleTitle) {
    return 'Вы уверены, что хотите удалить статью \"$articleTitle\"?';
  }

  @override
  String get addArticleTitle => 'Новая статья';

  @override
  String get editArticleTitle => 'Редактировать статью';

  @override
  String get categoryLabel => 'Категория';

  @override
  String get contentLabel => 'Содержание (Markdown)';

  @override
  String get tagsLabel => 'Теги (через запятую)';

  @override
  String get tagsHint => 'например: суд, закон, кодекс';

  @override
  String get noPdfSelected => 'PDF файл не выбран';

  @override
  String get uploadPdfTooltip => 'Загрузить PDF';

  @override
  String currentFileLabel(Object url) {
    return 'Текущий файл: $url';
  }

  @override
  String get existingPdfFile => 'Существующий PDF файл';

  @override
  String get articleSavedSuccess => 'Статья сохранена';

  @override
  String get titleRequired => 'Требуется заголовок';

  @override
  String get contentRequired => 'Требуется содержание';

  @override
  String confirmDeleteVideoMessage(Object videoTitle) {
    return 'Вы уверены, что хотите удалить видео \"$videoTitle\"?';
  }

  @override
  String get videoDeletedSuccess => 'Видео удалено';

  @override
  String get noVideosFound => 'Видео не найдено';

  @override
  String get addVideoTitle => 'Новое видео';

  @override
  String get editVideoTitle => 'Редактировать видео';

  @override
  String get videoSavedSuccess => 'Видео сохранено';

  @override
  String get youtubeIdLabel => 'YouTube ID';

  @override
  String get youtubeIdHint => 'например: dQw4w9WgXcQ';

  @override
  String get youtubeIdRequired => 'Требуется YouTube ID';

  @override
  String get systemOptionalLabel => 'Система (необязательно)';

  @override
  String get notSelectedLabel => 'Не выбрано';

  @override
  String get durationLabel => 'Длительность (секунды)';

  @override
  String get durationHint => 'например: 600';

  @override
  String get durationRequired => 'Требуется длительность';

  @override
  String get videoTagsHint => 'например: вход, ошибка, настройки';

  @override
  String get descriptionRequired => 'Требуется описание';

  @override
  String confirmDeleteSystemMessage(Object systemName) {
    return 'Вы уверены, что хотите удалить систему \"$systemName\"?';
  }

  @override
  String get systemDeletedSuccess => 'Система удалена';

  @override
  String get noSystemsFound => 'Системы не найдены';

  @override
  String get addSystemTitle => 'Новая система';

  @override
  String get editSystemTitle => 'Редактировать систему';

  @override
  String get systemSavedSuccess => 'Система сохранена';

  @override
  String get shortNameLabel => 'Короткое название';

  @override
  String get shortNameHint => 'например: e-SUD';

  @override
  String get nameRequired => 'Требуется название';

  @override
  String get fullNameLabel => 'Полное название';

  @override
  String get fullNameRequired => 'Требуется полное название';

  @override
  String get websiteUrlLabel => 'URL веб-сайта';

  @override
  String get urlRequired => 'Требуется URL';

  @override
  String get logoUrlLabel => 'URL логотипа';

  @override
  String get logoUrlRequired => 'Требуется URL логотипа';

  @override
  String get statusLabel => 'Статус';

  @override
  String get loginGuideIdLabel => 'ID руководства по входу (необязательно)';

  @override
  String get videoGuideIdLabel => 'ID видеоруководства (необязательно)';

  @override
  String confirmDeleteFaqMessage(Object question) {
    return 'Вы уверены, что хотите удалить вопрос \"$question\"?';
  }

  @override
  String get faqDeletedSuccess => 'Вопрос удален';

  @override
  String get noFaqsFound => 'Вопросы не найдены';

  @override
  String get addFaqTitle => 'Новый вопрос';

  @override
  String get editFaqTitle => 'Редактировать вопрос';

  @override
  String get faqSavedSuccess => 'Вопрос сохранен';

  @override
  String get questionLabel => 'Вопрос';

  @override
  String get questionRequired => 'Требуется вопрос';

  @override
  String get answerLabel => 'Ответ (Markdown)';

  @override
  String get answerRequired => 'Требуется ответ';

  @override
  String get add => 'Добавить';

  @override
  String get titleLabel => 'Заголовок';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get search => 'Поиск...';

  @override
  String get fieldRequired => 'Поле обязательно для заполнения';

  @override
  String get confirmDelete => 'Вы уверены, что хотите удалить?';

  @override
  String get successSaved => 'Успешно сохранено';

  @override
  String get successDeleted => 'Успешно удалено';

  @override
  String get notificationManagementTitle => 'Управление уведомлениями';

  @override
  String get notificationHistoryTitle => 'История уведомлений';

  @override
  String get notificationHistoryPlaceholder => 'Здесь будет отображаться история отправленных уведомлений (скоро).';

  @override
  String get sendNewNotificationButton => 'Отправить новое уведомление';

  @override
  String get sendNotificationTitle => 'Отправить уведомление';

  @override
  String get notificationSentSuccess => 'Уведомление отправлено';

  @override
  String get notificationTitleLabel => 'Заголовок';

  @override
  String get notificationTitleRequired => 'Требуется заголовок';

  @override
  String get notificationBodyLabel => 'Текст сообщения';

  @override
  String get notificationBodyRequired => 'Требуется текст сообщения';

  @override
  String get notificationTypeLabel => 'Тип уведомления';

  @override
  String get targetAudienceLabel => 'Аудитория';

  @override
  String get resourceTabArticles => 'Статьи';

  @override
  String get resourceTabVideos => 'Видео';

  @override
  String get resourceTabFiles => 'Файлы';

  @override
  String get filesTabTitle => 'Файлы';

  @override
  String get systemsDirectoryTitle => 'Справочник Судебных Систем';

  @override
  String get bookmarkSaveTooltip => 'Сохранить';

  @override
  String get bookmarkRemoveTooltip => 'Удалить из сохраненных';

  @override
  String get resourceTypeOther => 'Другое';

  @override
  String get openFile => 'Открыть файл';

  @override
  String get fileSize => 'Размер файла';

  @override
  String get selectFile => 'Выбрать файл';

  @override
  String get upload => 'Загрузить';

  @override
  String get processing => 'Обработка...';

  @override
  String get urlLabel => 'Ссылка (URL)';

  @override
  String get resourceTypePDF => 'PDF Руководство';

  @override
  String get resourceTypeVideo => 'Видеоурок';

  @override
  String get resourceTypeLink => 'Веб-ссылка';

  @override
  String get onlySaved => 'Только сохраненные';

  @override
  String get searchArticlesPlaceholder => 'Поиск статей...';

  @override
  String get filterAll => 'Все';

  @override
  String get noResultsFound => 'Результатов не найдено';

  @override
  String get noArticlesAvailable => 'Статьи недоступны';

  @override
  String get noVideosAvailable => 'Видео недоступны';

  @override
  String get actionCreateDiscussion => 'Создать обсуждение';

  @override
  String get actionCreateResource => 'Создать ресурс';

  @override
  String get actionCreateQuiz => 'Создать тест';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get loginRequired => 'Требуется вход';

  @override
  String get markAllAsReadTooltip => 'Отметить все как прочитанные';

  @override
  String get allNotificationsReadMessage => 'Все уведомления отмечены как прочитанные';

  @override
  String get noNotifications => 'Нет уведомлений';

  @override
  String get closeAction => 'Закрыть';

  @override
  String get leaderboardTitle => 'Таблица лидеров';

  @override
  String pointsEarned(int points) {
    return 'Вы заработали $points XP!';
  }

  @override
  String levelUp(String level) {
    return 'Поздравляем! Новый уровень: $level';
  }

  @override
  String get rank => 'Место';

  @override
  String get quizHistoryTitle => 'История викторин';

  @override
  String get seeAll => 'Показать все';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get thisWeek => 'На этой неделе';

  @override
  String get older => 'Старые результаты';

  @override
  String get contactSupport => 'Поддержка';

  @override
  String get landingTitle => 'Профессиональная Платформа';

  @override
  String get landingSubtitle => 'Повышайте свои правовые знания. В любое время.';

  @override
  String get landingLogin => 'Войти';

  @override
  String get landingRegister => 'Регистрация';

  @override
  String get featureKnowledgeBase => 'База Знаний';

  @override
  String get featureKnowledgeBaseDesc => 'Доступ к обширной библиотеке правовых ресурсов.';

  @override
  String get featureVideoTutorials => 'Видеоуроки';

  @override
  String get featureVideoTutorialsDesc => 'Учитесь по видео-руководствам от экспертов.';

  @override
  String get featureGamification => 'Геймификация';

  @override
  String get featureGamificationDesc => 'Зарабатывайте XP, значки и соревнуйтесь в рейтинге.';

  @override
  String get analyticsTitle => 'Аналитика Обучения (xAPI)';

  @override
  String get analyticsSubtitle => 'Учебные Записи';

  @override
  String get totalRecords => 'Всего Записей';

  @override
  String get realTime => 'В реальном времени';

  @override
  String get activityDistribution => 'Распределение Активности';

  @override
  String get recentActivityFeed => 'Лента Недавней Активности';

  @override
  String get noRecords => 'Учебные записи пока не найдены.';

  @override
  String get unknownUser => 'Неизвестный Пользователь';

  @override
  String get unknownObject => 'Неизвестный Объект';

  @override
  String get justNow => 'Только что';

  @override
  String get quizzes => 'Викторины';

  @override
  String get simulations => 'Симуляции';

  @override
  String get catNewEmployees => 'Новые сотрудники';

  @override
  String get catIctSpecialists => 'ИКТ специалисты';

  @override
  String get catSystems => 'Системы';

  @override
  String get catAuth => 'Аутентификация';

  @override
  String get catGeneral => 'Общее';

  @override
  String get rankBeginner => 'Начинающий';

  @override
  String get rankIntermediate => 'Средний уровень';

  @override
  String get rankAdvanced => 'Продвинутый';

  @override
  String get sysCatPrimary => 'Основные системы';

  @override
  String get sysCatSecondary => 'Дополнительные системы';

  @override
  String get sysCatSupport => 'Системы поддержки';

  @override
  String get sysStatusActive => 'Активно';

  @override
  String get sysStatusMaintenance => 'Техподдержка';

  @override
  String get sysStatusInactive => 'Неактивно';

  @override
  String videoViews(int count) {
    return '$count просмотров';
  }

  @override
  String get videoAuthorSubtitle => 'Автор';

  @override
  String get videoDescriptionTitle => 'Описание';

  @override
  String get sysStatusDeprecated => 'Устарело';

  @override
  String get sysStatusOffline => 'Отключено';

  @override
  String get systemsDirectoryAll => 'Все';

  @override
  String systemsDirectoryError(String error) {
    return 'Произошла ошибка: $error';
  }

  @override
  String get systemsDirectoryEmpty => 'Системы отсутствуют';

  @override
  String get backToKnowledgeBase => 'Вернуться к руководствам';

  @override
  String get quizSuccessMessage => 'Отличный результат!';

  @override
  String get quizFailureMessage => 'Попробуйте еще раз!';

  @override
  String get speedBonus => 'СКОРОСТНОЙ БОНУС';

  @override
  String get levelSpecialist => 'Специалист';

  @override
  String get levelMaster => 'Мастер';
}
