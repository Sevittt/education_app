// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Teach&Learn';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get languageUzbek => 'Uzbek (Uzbekistan)';

  @override
  String get languageRussian => 'Russian (Russia)';

  @override
  String get languageSystemDefault => 'System Default';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsReceiveNotifications => 'Receive Notifications';

  @override
  String get settingsReceiveNotificationsSubtitle => 'Get updates about new resources and discussions';

  @override
  String get settingsAllowLocation => 'Allow Location Access';

  @override
  String get settingsAllowLocationSubtitle => 'For features requiring your location (if any)';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsHelpCenter => 'Help Center';

  @override
  String get settingsAboutApp => 'About Teach & Learn';

  @override
  String get settingsAppLegalese => '© 2025 Teach & Learn Project';

  @override
  String get settingsAppDescription => 'Bridging the IT skills gap through collaborative learning and resource sharing.';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get resourcesNoResourcesFound => 'No resources found.';

  @override
  String get loginButtonText => 'Login';

  @override
  String get signUpButtonText => 'Sign Up';

  @override
  String get logoutButtonText => 'Logout';

  @override
  String get logoutConfirmTitle => 'Are you sure to logout';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get homeDashboardTitle => 'Dashboard';

  @override
  String get communityScreenTitle => 'Community';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get editProfileButtonText => 'Edit Profile';

  @override
  String get guestUser => 'Guest';

  @override
  String get updateYourInformation => 'Update your information';

  @override
  String get loginToEditProfile => 'Log in to edit your profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeOptionsTitle => 'Theme Options';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get logoutButton => 'Log out';

  @override
  String get resourcesTitle => 'Resources';

  @override
  String get resourcesSearchHint => 'Search resources...';

  @override
  String get resourcesFilterByType => 'Filter by Type';

  @override
  String get resourcesAllTypes => 'All Types';

  @override
  String get resourcesNoResourcesMatch => 'No resources match your criteria.';

  @override
  String get resourcesTryAdjusting => 'Try adjusting your search or filter.';

  @override
  String get resourcesCreateButton => 'Create';

  @override
  String get resourceAddedSuccess => 'Resource added successfully!';

  @override
  String resourceAddedError(String error) {
    return 'Error adding resource: $error';
  }

  @override
  String get createResourceScreenTitle => 'Create New Resource';

  @override
  String get createResourceFormWillBeHere => 'Resource creation form will be here.';

  @override
  String get saveButtonText => 'Save Changes';

  @override
  String get createResourceTitleLabel => 'Title';

  @override
  String get createResourceDescriptionLabel => 'Description';

  @override
  String get createResourceAuthorLabel => 'Author';

  @override
  String get createResourceTypeLabel => 'Resource Type';

  @override
  String get createResourceUrlLabel => 'URL (Optional)';

  @override
  String couldNotLaunchUrl(Object url) {
    return 'Could not launch $url';
  }

  @override
  String createResourceValidationEmpty(Object fieldName) {
    return 'Please enter a $fieldName';
  }

  @override
  String createResourceValidationSelect(Object fieldName) {
    return 'Please select a $fieldName';
  }

  @override
  String get createResourceValidationInvalidUrl => 'Please enter a valid URL';

  @override
  String get editButtonTooltip => 'Edit Resource';

  @override
  String get editResourceScreenTitle => 'Edit Resource';

  @override
  String get resourceTypeLabel => 'Type';

  @override
  String get authorLabel => 'Author';

  @override
  String get dateAddedLabel => 'Added';

  @override
  String get launchingUrlMessage => 'Launching URL';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get resourceUpdatedSuccess => 'Resource updated successfully!';

  @override
  String resourceUpdatedError(String error) {
    return 'Error updating resource: $error';
  }

  @override
  String get deleteResourceConfirmTitle => 'Confirm Deletion';

  @override
  String get deleteResourceConfirmMessage => 'Are you sure you want to delete this resource? This action cannot be undone.';

  @override
  String get cancelButtonText => 'Cancel';

  @override
  String get deleteButtonText => 'Delete';

  @override
  String resourceDeletedSuccess(Object resourceTitle) {
    return 'Resource \"$resourceTitle\" deleted successfully.';
  }

  @override
  String resourceDeletedError(Object error) {
    return 'Error deleting resource: $error';
  }

  @override
  String get deleteButtonTooltip => 'Delete Resource';

  @override
  String get createANewQuiz => 'Create a New Quiz';

  @override
  String get quizTitle => 'Quiz Title';

  @override
  String get quizDescription => 'Description';

  @override
  String get saveAndAddQuestions => 'Save and Add Questions';

  @override
  String get failedToCreateQuiz => 'Failed to create quiz';

  @override
  String get addQuestions => 'Add Questions';

  @override
  String get finish => 'FINISH';

  @override
  String get questionText => 'Question Text';

  @override
  String get pleaseEnterAQuestion => 'Please enter a question';

  @override
  String get questionType => 'Question Type';

  @override
  String get multipleChoice => 'Multiple Choice';

  @override
  String get trueFalse => 'True/False';

  @override
  String get pleaseSelectCorrectAnswer => 'Please select a correct answer.';

  @override
  String option(Object number) {
    return 'Option $number';
  }

  @override
  String get pleaseEnterAnOption => 'Please enter an option';

  @override
  String get addQuestion => 'Add Question';

  @override
  String get questionAddedSuccessfully => 'Question added successfully!';

  @override
  String get failedToAddQuestion => 'Failed to add question';

  @override
  String get noQuestionsAddedYet => 'No questions added yet.';

  @override
  String get correctAnswer => 'Correct';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizNotFound => 'Quiz not found.';

  @override
  String get failedToLoadQuiz => 'Failed to load quiz';

  @override
  String question(Object number) {
    return 'Question $number';
  }

  @override
  String totalQuestions(Object total) {
    return 'of $total';
  }

  @override
  String get submitQuiz => 'Submit Quiz';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get quizResults => 'Quiz Results';

  @override
  String get quizCompletionMessage => 'You have completed the quiz!';

  @override
  String get yourScore => 'Your Score:';

  @override
  String get done => 'Done';

  @override
  String get failedToSaveAttempt => 'Failed to save your attempt';

  @override
  String get myQuizHistory => 'My Quiz History';

  @override
  String get noQuizAttempts => 'You haven\'t attempted any quizzes yet.';

  @override
  String get score => 'Score';

  @override
  String get role => 'Role';

  @override
  String get loading => 'Loading...';

  @override
  String get relatedQuizzesTitle => 'Related Quizzes';

  @override
  String get noQuizzesAvailable => 'No quizzes available for this resource yet.';

  @override
  String get errorLoadingQuizzes => 'Error loading quizzes';

  @override
  String invalidUrlFormat(Object url) {
    return 'Invalid URL format: $url';
  }

  @override
  String errorLaunchingUrl(Object error) {
    return 'Error launching URL: $error';
  }

  @override
  String createResourceValidationMinLength(Object fieldName, Object length) {
    return '$fieldName must be at least $length characters long';
  }

  @override
  String createResourceValidationMaxLength(Object fieldName, Object length) {
    return '$fieldName cannot exceed $length characters';
  }

  @override
  String get titleMinLength => 'Title must be at least 5 characters long';

  @override
  String get titleMaxLength => 'Title cannot exceed 100 characters';

  @override
  String get createTopicScreenTitle => 'Start New Discussion';

  @override
  String get createTopicTitleLabel => 'Topic Title';

  @override
  String get createTopicContentLabel => 'Discussion Content';

  @override
  String get createTopicButtonText => 'Create Discussion Topic';

  @override
  String get mustBeLoggedInToCreateTopic => 'You must be logged in to create a topic.';

  @override
  String get topicCreatedSuccess => 'Topic created successfully!';

  @override
  String failedToCreateTopic(Object error, Object xato) {
    return 'Failed to create topic: $error';
  }

  @override
  String createTopicValidationEmpty(Object fieldName) {
    return '$fieldName cannot be empty.';
  }

  @override
  String createTopicValidationMinLength(Object fieldName, Object length) {
    return '$fieldName must be at least $length characters long.';
  }

  @override
  String createTopicValidationMaxLength(Object fieldName, Object length) {
    return '$fieldName cannot exceed $length characters.';
  }

  @override
  String get errorLoadingData => 'An error occurred while loading resources. Please try again.';

  @override
  String failedToUpdateTopic(String error, Object xato) {
    return 'Error updating topic: $error';
  }

  @override
  String get topicUpdatedSuccess => 'Topic updated successfully!';

  @override
  String get noDiscussionsYet => 'No discussions yet.';

  @override
  String get beTheFirstToStartConversation => 'Be the first to start a conversation!';

  @override
  String get mustBeLoggedInToCreateResource => 'You must be logged in to create a resource.';

  @override
  String get profileIncompleteToCreateResource => 'Your profile information is incomplete. Please update your name in your profile.';

  @override
  String get profileIncompleteToCreateTopic => 'Your profile name is not set. Please update your profile.';

  @override
  String get commentCannotBeEmpty => 'Comment cannot be empty.';

  @override
  String get mustBeLoggedInToComment => 'You must be logged in to comment.';

  @override
  String get commentAddedSuccessfully => 'Comment added successfully!';

  @override
  String failedToAddComment(Object error, Object xato) {
    return 'Failed to add comment: $error';
  }

  @override
  String postedBy(Object authorName) {
    return 'Posted by $authorName';
  }

  @override
  String onDate(Object date) {
    return 'on $date';
  }

  @override
  String get repliesTitle => 'Replies';

  @override
  String errorLoadingComments(Object error) {
    return 'Error loading comments: $error';
  }

  @override
  String get noRepliesYet => 'No replies yet. Be the first to comment!';

  @override
  String get writeAReplyHint => 'Write a reply...';

  @override
  String get sendCommentTooltip => 'Send Comment';

  @override
  String welcomeBack(Object userName) {
    return 'Welcome back, $userName!';
  }

  @override
  String get readyToLearnSomethingNew => 'Ready to learn something new today?';

  @override
  String get quickAccessTitle => 'Quick Access';

  @override
  String get communityTitle => 'Community';

  @override
  String get profileTitle => 'Profile';

  @override
  String get latestNewsTitle => 'Latest News';

  @override
  String get sourceLabel => 'Source';

  @override
  String get quizzesTitle => 'Quizzes';

  @override
  String get urlCannotBeEmpty => 'URL cannot be empty';

  @override
  String errorLoadingNews(Object error) {
    return 'Error loading news: $error';
  }

  @override
  String get noNewsAvailable => 'No news available at the moment.';

  @override
  String get adminPanelTitle => 'Admin Panel';

  @override
  String get manageNewsTitle => 'Manage News';

  @override
  String get manageNewsSubtitle => 'Add, edit, or delete news articles';

  @override
  String get manageUsersTitle => 'Manage Users';

  @override
  String get manageUsersSubtitle => 'View users and manage roles (future)';

  @override
  String get manageResourcesTitle => 'Manage Resources';

  @override
  String get manageResourcesSubtitle => 'Oversee all learning resources (future)';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String confirmDeleteNewsMessage(Object newsTitle) {
    return 'Are you sure you want to delete \"$newsTitle\"?';
  }

  @override
  String newsDeletedSuccess(Object newsTitle) {
    return '\"$newsTitle\" deleted successfully.';
  }

  @override
  String failedToDeleteNews(Object error, Object newsTitle, Object xato) {
    return 'Failed to delete \"$newsTitle\": $error';
  }

  @override
  String get addNewsTooltip => 'Add New News Article';

  @override
  String get editNewsTooltip => 'Edit News';

  @override
  String get deleteNewsTooltip => 'Delete News';

  @override
  String get addNewsButton => 'Add News';

  @override
  String get noNewsAvailableManager => 'No news articles found. Add one!';

  @override
  String get editNewsTitle => 'Edit News';

  @override
  String get addNewsTitle => 'Add News Article';

  @override
  String get saveNewsTooltip => 'Save News';

  @override
  String get newsTitleLabel => 'Title';

  @override
  String get pleaseEnterNewsTitle => 'Please enter a news title.';

  @override
  String newsTitleMinLength(Object length) {
    return 'News title must be at least $length characters.';
  }

  @override
  String get newsSourceLabel => 'Source (e.g., Blog Name)';

  @override
  String get pleaseEnterNewsSource => 'Please enter the news source.';

  @override
  String get newsUrlLabel => 'Article URL';

  @override
  String get pleaseEnterNewsUrl => 'Please enter the article URL.';

  @override
  String get pleaseEnterValidNewsUrl => 'Please enter a valid URL (starting with http or https).';

  @override
  String get newsImageUrlLabel => 'Image URL (Optional)';

  @override
  String get pleaseEnterValidImageUrl => 'Please enter a valid image URL (starting with http or https), or leave blank.';

  @override
  String get publicationDateLabel => 'Publication Date';

  @override
  String get pleaseSelectPublicationDate => 'Please select a publication date.';

  @override
  String get noDateSelected => 'No date selected';

  @override
  String get selectDateTooltip => 'Select Date';

  @override
  String get updateNewsButton => 'Update News';

  @override
  String get addNewsButtonForm => 'Add News Article';

  @override
  String newsUpdatedSuccess(Object newsTitle) {
    return '\"$newsTitle\" updated successfully.';
  }

  @override
  String newsAddedSuccess(Object newsTitle) {
    return '\"$newsTitle\" added successfully.';
  }

  @override
  String failedToSaveNews(Object error, Object xato) {
    return 'Failed to save news: $error';
  }

  @override
  String errorLoadingUsers(Object error) {
    return 'Error loading users: $error';
  }

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get noEmailProvided => 'No email provided';

  @override
  String get roleLabel => 'Role';

  @override
  String get registeredOnLabel => 'Registered';

  @override
  String get manageUsersSubtitleNow => 'View and search registered users';

  @override
  String get manageResourcesSubtitleNow => 'View, edit, or delete any learning resource';

  @override
  String confirmDeleteResourceMessage(Object resourceTitle) {
    return 'Are you sure you want to delete resource \"$resourceTitle\"?';
  }

  @override
  String failedToDeleteResource(Object error, Object resourceTitle, Object xato) {
    return 'Failed to delete resource \"$resourceTitle\": $error';
  }

  @override
  String errorLoadingResources(Object error) {
    return 'Error loading resources: $error';
  }

  @override
  String get noResourcesFoundManager => 'No resources found in the system.';

  @override
  String get editResourceTooltip => 'Edit Resource';

  @override
  String get deleteResourceTooltip => 'Delete Resource';

  @override
  String get manageQuizzesTitle => 'Manage Quizzes';

  @override
  String get addQuizTooltip => 'Add New Quiz';

  @override
  String errorLoadingQuizzesAdmin(Object error) {
    return 'Error loading quizzes: $error';
  }

  @override
  String get noQuizzesFoundManager => 'No quizzes found. Add one!';

  @override
  String confirmDeleteQuizMessage(Object quizTitle) {
    return 'Are you sure you want to delete quiz \"$quizTitle\" and all its questions? This action cannot be undone.';
  }

  @override
  String quizDeletedSuccess(Object quizTitle) {
    return 'Quiz \"$quizTitle\" and its questions deleted successfully.';
  }

  @override
  String failedToDeleteQuiz(Object error, Object quizTitle, Object xato) {
    return 'Failed to delete quiz \"$quizTitle\": $error';
  }

  @override
  String get editDetailsButton => 'Edit Details';

  @override
  String get manageQuestionsButton => 'Questions';

  @override
  String get deleteQuizTooltip => 'Delete Quiz and Questions';

  @override
  String get addQuizButton => 'Add Quiz';

  @override
  String get manageQuizzesSubtitle => 'Oversee all quizzes and their questions';
}
