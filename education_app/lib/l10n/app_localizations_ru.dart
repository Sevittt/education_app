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
  String get languageEnglish => 'Английский (США)';

  @override
  String get languageUzbek => 'Узбекский (Узбекистан)';

  @override
  String get languageRussian => 'Русский (Россия)';

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
  String couldNotLaunchUrl(Object url, Object urlString) {
    return 'Could not launch $urlString';
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
  String get dateAddedLabel => 'Добавлен';

  @override
  String get launchingUrlMessage => 'Запуск URL';

  @override
  String get descriptionLabel => 'Описание';

  @override
  String get resourceUpdatedSuccess => 'Ресурс успешно обновлен!';

  @override
  String resourceUpdatedError(String error) {
    return 'Ошибка обновления ресурса: $error';
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
  String get quizNotFound => 'Викторина не найдена.';

  @override
  String get failedToLoadQuiz => 'Не удалось загрузить викторину';

  @override
  String question(Object number) {
    return 'Вопрос $number';
  }

  @override
  String totalQuestions(Object total) {
    return 'из $total';
  }

  @override
  String get submitQuiz => 'Отправить викторину';

  @override
  String get nextQuestion => 'Следующий вопрос';

  @override
  String get quizResults => 'Результаты викторины';

  @override
  String get quizCompletionMessage => 'Вы завершили викторину!';

  @override
  String get yourScore => 'Ваш счет:';

  @override
  String get done => 'Готово';

  @override
  String get failedToSaveAttempt => 'Не удалось сохранить вашу попытку';

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
  String failedToDeleteNews(String error, Object newsTitle, Object xato) {
    return 'Не удалось удалить \"$newsTitle\": $error';
  }

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
  String failedToDeleteResource(String error, Object resourceTitle, Object xato) {
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
  String failedToDeleteQuiz(String error, Object quizTitle, Object xato) {
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
}
