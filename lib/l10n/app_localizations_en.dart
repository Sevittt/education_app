// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Judicial guide';

  @override
  String get openInYoutube => 'Open in YouTube';

  @override
  String get watchOnYoutube => 'Watch on YouTube';

  @override
  String get loginWelcomeTitle => 'Welcome back!';

  @override
  String get loginWelcomeSubtitle => 'Sign in to continue';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavResources => 'Courses';

  @override
  String get bottomNavCommunity => 'Forum';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get resourcesScreenTitle => 'Guides & manuals';

  @override
  String get roleXodim => 'Staff';

  @override
  String get roleEkspert => 'Expert';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get registrationTitle => 'Create your account';

  @override
  String get registrationSubtitle => 'Join the professional community!';

  @override
  String get registrationFullNameLabel => 'Full name';

  @override
  String get registrationFullNameError => 'Please enter your full name';

  @override
  String get registrationRoleLabel => 'Your role';

  @override
  String get registrationRoleError => 'Please select a role';

  @override
  String get registrationRoleXodim => 'Regular staff';

  @override
  String get registrationRoleEkspert => 'Expert (content creator)';

  @override
  String get registrationRoleJudge => 'Judge';

  @override
  String get registrationRoleAssistant => 'Assistant';

  @override
  String get registrationRoleChancellery => 'Chancellery';

  @override
  String get registrationRoleArchive => 'Archive';

  @override
  String get registrationRoleIctSpecialist => 'ICT specialist';

  @override
  String get registrationPasswordLabel => 'Password';

  @override
  String get registrationPasswordError => 'Password must be at least 6 characters long';

  @override
  String get registrationConfirmPasswordLabel => 'Confirm password';

  @override
  String get registrationConfirmPasswordError => 'Passwords do not match';

  @override
  String get registrationSignUpButton => 'Sign up';

  @override
  String get registrationSwitchToLogin => 'Already have an account? sign in';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get languageUzbek => 'Uzbek (Uzbekistan)';

  @override
  String get languageRussian => 'Russian (Russia)';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsReceiveNotifications => 'Receive notifications';

  @override
  String get settingsReceiveNotificationsSubtitle => 'Get updates about new resources and discussions';

  @override
  String get settingsAllowLocation => 'Allow location access';

  @override
  String get settingsAllowLocationSubtitle => 'For features requiring your location (if any)';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsHelpCenter => 'Help center';

  @override
  String get settingsAboutApp => 'About court handbook';

  @override
  String get settingsAppLegalese => '© 2025 court handbook project';

  @override
  String get settingsAppDescription => 'Bridging the iT skills gap through collaborative learning and resource sharing.';

  @override
  String get errorPrefix => 'Error: ';

  @override
  String get days => 'days';

  @override
  String get resourcesNoResourcesFound => 'No resources found.';

  @override
  String get loginButtonText => 'Login';

  @override
  String get signUpButtonText => 'Sign up';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

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
  String get communityScreenTitle => 'Forum';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get editProfileButtonText => 'Edit profile';

  @override
  String get guestUser => 'Guest';

  @override
  String get updateYourInformation => 'Update your information';

  @override
  String get loginToEditProfile => 'Log in to edit your profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeOptionsTitle => 'Theme options';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get saveChangesButton => 'Save changes';

  @override
  String get vidCategoryBeginner => 'Beginner';

  @override
  String get vidCategoryIntermediate => 'Intermediate';

  @override
  String get vidCategoryAdvanced => 'Advanced';

  @override
  String get vidCategoryPractical => 'Practical';

  @override
  String get vidCategoryTheory => 'Theory';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get logoutButton => 'Log out';

  @override
  String get resourcesTitle => 'Guides';

  @override
  String get resourcesSearchHint => 'Search guides...';

  @override
  String get resourcesFilterByType => 'Filter by type';

  @override
  String get resourcesAllTypes => 'All types';

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
  String get createResourceScreenTitle => 'Create new guide';

  @override
  String get createResourceFormWillBeHere => 'Resource creation form will be here.';

  @override
  String get saveButtonText => 'Save changes';

  @override
  String get createResourceTitleLabel => 'Title';

  @override
  String get createResourceDescriptionLabel => 'Description';

  @override
  String get createResourceAuthorLabel => 'Author';

  @override
  String get createResourceTypeLabel => 'System type';

  @override
  String get createResourceUrlLabel => 'URL (optional)';

  @override
  String couldNotLaunchUrl(String url) {
    return 'Could not launch $url';
  }

  @override
  String createResourceValidationEmpty(String fieldName) {
    return 'Please enter a $fieldName';
  }

  @override
  String createResourceValidationSelect(String fieldName) {
    return 'Please select a $fieldName';
  }

  @override
  String get createResourceValidationInvalidUrl => 'Please enter a valid URL';

  @override
  String get editButtonTooltip => 'Edit resource';

  @override
  String get editResourceScreenTitle => 'Edit guide';

  @override
  String get resourceTypeLabel => 'Type';

  @override
  String get editTopicScreenTitle => 'Edit discussion topic';

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
  String get deleteResourceConfirmTitle => 'Confirm deletion';

  @override
  String get deleteResourceConfirmMessage => 'Are you sure you want to delete this resource? this action cannot be undone.';

  @override
  String get cancelButtonText => 'Cancel';

  @override
  String get deleteButtonText => 'Delete';

  @override
  String resourceDeletedSuccess(String resourceTitle) {
    return 'Resource \"$resourceTitle\" deleted successfully.';
  }

  @override
  String resourceDeletedError(String error) {
    return 'Error deleting resource: $error';
  }

  @override
  String get deleteButtonTooltip => 'Delete resource';

  @override
  String get createANewQuiz => 'Create a new quiz';

  @override
  String get quizTitle => 'Quiz title';

  @override
  String get quizDescription => 'Description';

  @override
  String get saveAndAddQuestions => 'Save and add questions';

  @override
  String get failedToCreateQuiz => 'Failed to create quiz';

  @override
  String get addQuestions => 'Add questions';

  @override
  String get finish => 'Finish';

  @override
  String get questionText => 'Question text';

  @override
  String get pleaseEnterAQuestion => 'Please enter a question';

  @override
  String get questionType => 'Question type';

  @override
  String get multipleChoice => 'Multiple choice';

  @override
  String get trueFalse => 'True/False';

  @override
  String get pleaseSelectCorrectAnswer => 'Please select a correct answer.';

  @override
  String option(int number) {
    return 'Option $number';
  }

  @override
  String get pleaseEnterAnOption => 'Please enter an option';

  @override
  String get addQuestion => 'Add question';

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
  String get quizCompletionMessage => 'You have completed the quiz!';

  @override
  String get done => 'Done';

  @override
  String get myQuizHistory => 'My quiz history';

  @override
  String get noQuizAttempts => 'You haven\'t attempted any quizzes yet.';

  @override
  String get score => 'Score';

  @override
  String get role => 'Role';

  @override
  String get loading => 'Loading...';

  @override
  String get relatedQuizzesTitle => 'Related quizzes';

  @override
  String get noQuizzesAvailable => 'No quizzes available for this resource yet.';

  @override
  String get errorLoadingQuizzes => 'Error loading quizzes';

  @override
  String invalidUrlFormat(String url) {
    return 'Invalid URL format: $url';
  }

  @override
  String errorLaunchingUrl(String error) {
    return 'Error launching URL: $error';
  }

  @override
  String createResourceValidationMinLength(String fieldName, int length) {
    return '$fieldName must be at least $length characters long';
  }

  @override
  String createResourceValidationMaxLength(String fieldName, int length) {
    return '$fieldName cannot exceed $length characters';
  }

  @override
  String get titleMinLength => 'Title must be at least 5 characters long';

  @override
  String get titleMaxLength => 'Title cannot exceed 100 characters';

  @override
  String get createTopicScreenTitle => 'Start new discussion';

  @override
  String get createTopicTitleLabel => 'Topic title';

  @override
  String get createTopicContentLabel => 'Discussion content';

  @override
  String get createTopicButtonText => 'Create discussion topic';

  @override
  String get mustBeLoggedInToCreateTopic => 'You must be logged in to create a topic.';

  @override
  String get topicCreatedSuccess => 'Topic created successfully!';

  @override
  String failedToCreateTopic(String error) {
    return 'Failed to create topic: $error';
  }

  @override
  String createTopicValidationEmpty(String fieldName) {
    return '$fieldName cannot be empty.';
  }

  @override
  String createTopicValidationMinLength(String fieldName, int length) {
    return '$fieldName must be at least $length characters long.';
  }

  @override
  String createTopicValidationMaxLength(String fieldName, int length) {
    return '$fieldName cannot exceed $length characters.';
  }

  @override
  String get errorLoadingData => 'An error occurred while loading resources. please try again.';

  @override
  String failedToUpdateTopic(String error) {
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
  String get profileIncompleteToCreateResource => 'Your profile information is incomplete. please update your name in your profile.';

  @override
  String get profileIncompleteToCreateTopic => 'Your profile name is not set. please update your profile.';

  @override
  String get commentCannotBeEmpty => 'Comment cannot be empty.';

  @override
  String get mustBeLoggedInToComment => 'You must be logged in to comment.';

  @override
  String get commentAddedSuccessfully => 'Comment added successfully!';

  @override
  String failedToAddComment(String error) {
    return 'Failed to add comment: $error';
  }

  @override
  String postedBy(String authorName) {
    return 'Posted by $authorName';
  }

  @override
  String onDate(String date) {
    return 'on $date';
  }

  @override
  String get repliesTitle => 'Replies';

  @override
  String errorLoadingComments(String error) {
    return 'Error loading comments: $error';
  }

  @override
  String get noRepliesYet => 'No replies yet. be the first to comment!';

  @override
  String get writeAReplyHint => 'Write a reply...';

  @override
  String get sendCommentTooltip => 'Send comment';

  @override
  String welcomeBack(String userName) {
    return 'Welcome back, $userName!';
  }

  @override
  String get readyToLearnSomethingNew => 'Ready to learn something new today?';

  @override
  String get quickAccessTitle => 'Quick access';

  @override
  String get communityTitle => 'Forum';

  @override
  String get profileTitle => 'Profile';

  @override
  String get latestNewsTitle => 'Latest news';

  @override
  String get sourceLabel => 'Source';

  @override
  String get quizzesTitle => 'Quizzes';

  @override
  String get urlCannotBeEmpty => 'URL cannot be empty';

  @override
  String errorLoadingNews(String error) {
    return 'Error loading news: $error';
  }

  @override
  String get noNewsAvailable => 'No news available at the moment.';

  @override
  String get adminPanelTitle => 'Admin panel';

  @override
  String get manageNewsTitle => 'Manage news';

  @override
  String get manageNewsSubtitle => 'Add, edit, or delete news articles';

  @override
  String get manageUsersTitle => 'Manage users';

  @override
  String get manageUsersSubtitle => 'View users and manage roles (future)';

  @override
  String get manageResourcesTitle => 'Manage guides';

  @override
  String get manageResourcesSubtitle => 'Oversee all learning resources (future)';

  @override
  String get confirmDeleteTitle => 'Confirm deletion';

  @override
  String confirmDeleteNewsMessage(String newsTitle) {
    return 'Are you sure you want to delete \"$newsTitle\"?';
  }

  @override
  String newsDeletedSuccess(String newsTitle) {
    return '\"$newsTitle\" deleted successfully.';
  }

  @override
  String failedToDeleteNews(String error, String newsTitle) {
    return 'Failed to delete \"$newsTitle\": $error';
  }

  @override
  String get faqTitle => 'FAQ';

  @override
  String get searchHelp => 'Search help...';

  @override
  String get allCategories => 'All categories';

  @override
  String get helpfulFeedback => 'Was this helpful?';

  @override
  String get noArticlesFound => 'No fAQs found';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get helpCenterTitle => 'Help center';

  @override
  String get settingsAbout => 'About app';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully';

  @override
  String get errorWrongPassword => 'Incorrect current password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get save => 'Save';

  @override
  String get addNewsTooltip => 'Add new news article';

  @override
  String get editNewsTooltip => 'Edit news';

  @override
  String get deleteNewsTooltip => 'Delete news';

  @override
  String get addNewsButton => 'Add news';

  @override
  String get noNewsAvailableManager => 'No news articles found. add one!';

  @override
  String get editNewsTitle => 'Edit news';

  @override
  String get addNewsTitle => 'Add news article';

  @override
  String get saveNewsTooltip => 'Save news';

  @override
  String get newsTitleLabel => 'Title';

  @override
  String get pleaseEnterNewsTitle => 'Please enter a news title.';

  @override
  String newsTitleMinLength(int length) {
    return 'News title must be at least $length characters.';
  }

  @override
  String get newsSourceLabel => 'Source (e.g., blog name)';

  @override
  String get pleaseEnterNewsSource => 'Please enter the news source.';

  @override
  String get newsUrlLabel => 'Article URL';

  @override
  String get pleaseEnterNewsUrl => 'Please enter the article uRL.';

  @override
  String get pleaseEnterValidNewsUrl => 'Please enter a valid URL (starting with http or https).';

  @override
  String get newsImageUrlLabel => 'Image URL (Optional)';

  @override
  String get pleaseEnterValidImageUrl => 'Please enter a valid image URL (starting with http or https), or leave blank.';

  @override
  String get publicationDateLabel => 'Publication date';

  @override
  String get pleaseSelectPublicationDate => 'Please select a publication date.';

  @override
  String get noDateSelected => 'No date selected';

  @override
  String get selectDateTooltip => 'Select date';

  @override
  String get updateNewsButton => 'Update news';

  @override
  String get addNewsButtonForm => 'Add news article';

  @override
  String newsUpdatedSuccess(String newsTitle) {
    return '\"$newsTitle\" updated successfully.';
  }

  @override
  String newsAddedSuccess(String newsTitle) {
    return '\"$newsTitle\" added successfully.';
  }

  @override
  String failedToSaveNews(String error) {
    return 'Failed to save news: $error';
  }

  @override
  String errorLoadingUsers(String error) {
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
  String confirmDeleteResourceMessage(String resourceTitle) {
    return 'Are you sure you want to delete resource \"$resourceTitle\"?';
  }

  @override
  String failedToDeleteResource(String error, String resourceTitle) {
    return 'Failed to delete resource \"$resourceTitle\": $error';
  }

  @override
  String errorLoadingResources(String error) {
    return 'Error loading resources: $error';
  }

  @override
  String get noResourcesFoundManager => 'No resources found in the system.';

  @override
  String get editResourceTooltip => 'Edit resource';

  @override
  String get deleteResourceTooltip => 'Delete resource';

  @override
  String get manageQuizzesTitle => 'Manage quizzes';

  @override
  String get addQuizTooltip => 'Add new quiz';

  @override
  String errorLoadingQuizzesAdmin(String error) {
    return 'Error loading quizzes: $error';
  }

  @override
  String get noQuizzesFoundManager => 'No quizzes found. add one!';

  @override
  String confirmDeleteQuizMessage(String quizTitle) {
    return 'Are you sure you want to delete quiz \"$quizTitle\" and all its questions? this action cannot be undone.';
  }

  @override
  String quizDeletedSuccess(String quizTitle) {
    return 'Quiz \"$quizTitle\" and its questions deleted successfully.';
  }

  @override
  String failedToDeleteQuiz(String error, String quizTitle) {
    return 'Failed to delete quiz \"$quizTitle\": $error';
  }

  @override
  String get editDetailsButton => 'Edit details';

  @override
  String get manageQuestionsButton => 'Questions';

  @override
  String get deleteQuizTooltip => 'Delete quiz and questions';

  @override
  String get addQuizButton => 'Add quiz';

  @override
  String get manageQuizzesSubtitle => 'Oversee all quizzes and their questions';

  @override
  String get registrationEmailError => 'Please enter a valid email address';

  @override
  String get dashboardXodimTitle => 'My activity';

  @override
  String get dashboardEkspertTitle => 'My contributions';

  @override
  String get dashboardAdminTitle => 'System overview';

  @override
  String get seeAllButton => 'See all';

  @override
  String get noGuidesAuthored => 'You have not authored any guides yet.';

  @override
  String get adminStatUsers => 'Users';

  @override
  String get adminStatGuides => 'Guides';

  @override
  String get adminStatQuizzes => 'Quizzes';

  @override
  String get nextLevel => 'Next level';

  @override
  String get orDivider => 'OR';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get themeSystemDefault => 'System default';

  @override
  String get themeLight => 'Light mode';

  @override
  String get themeDark => 'Dark mode';

  @override
  String get bioOptionalLabel => 'Bio (Optional)';

  @override
  String get profilePictureUrlLabel => 'Profile picture URL (Optional)';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get totalPoints => 'Total points';

  @override
  String pointsToNextLevel(int points) {
    return '$points XP to next level';
  }

  @override
  String get manageArticlesTitle => 'Articles';

  @override
  String get manageArticlesSubtitle => 'Manage knowledge base';

  @override
  String get manageVideosTitle => 'Videos';

  @override
  String get manageVideosSubtitle => 'Manage video tutorials';

  @override
  String get manageSystemsTitle => 'Systems';

  @override
  String get manageSystemsSubtitle => 'Manage systems directory';

  @override
  String get manageFaqTitle => 'FAQ';

  @override
  String get manageFaqSubtitle => 'Manage fAQs';

  @override
  String get manageNotificationsTitle => 'Notifications';

  @override
  String get manageNotificationsSubtitle => 'Send notifications';

  @override
  String get selectLanguage => 'Select language';

  @override
  String topicDeletedSuccess(String topicTitle) {
    return '\"$topicTitle\" deleted successfully.';
  }

  @override
  String failedToDeleteTopic(String error) {
    return 'Failed to delete topic: $error';
  }

  @override
  String deleteTopicConfirmMessage(String topicTitle) {
    return 'Are you sure you want to delete \"$topicTitle\"?';
  }

  @override
  String get editTopicTooltip => 'Edit topic';

  @override
  String get deleteTopicConfirmTitle => 'Delete topic';

  @override
  String get commentPlural => 'Comments';

  @override
  String get commentSingular => 'Comment';

  @override
  String get deleteTopicTooltip => 'Delete topic';

  @override
  String get faqCategoryLogin => 'Login issues';

  @override
  String get faqCategoryPassword => 'Password issues';

  @override
  String get faqCategoryUpload => 'File upload';

  @override
  String get faqCategoryAccess => 'Access rights';

  @override
  String get faqCategoryGeneral => 'General questions';

  @override
  String get faqCategoryTechnical => 'Technical issues';

  @override
  String confirmDeleteArticleMessage(String articleTitle) {
    return 'Are you sure you want to delete the article \"$articleTitle\"?';
  }

  @override
  String get addArticleTitle => 'New article';

  @override
  String get editArticleTitle => 'Edit article';

  @override
  String get categoryLabel => 'Category';

  @override
  String get articleCategoryGeneral => 'General';

  @override
  String get articleCategoryProcedure => 'Procedure';

  @override
  String get articleCategoryLaw => 'Legislation';

  @override
  String get articleCategoryFaq => 'FAQ';

  @override
  String get contentLabel => 'Content (Markdown)';

  @override
  String get tagsLabel => 'Tags (comma separated)';

  @override
  String get tagsHint => 'e.g. court, law, code';

  @override
  String get noPdfSelected => 'No PDF file selected';

  @override
  String get uploadPdfTooltip => 'Upload PDF';

  @override
  String currentFileLabel(String url) {
    return 'Current file: $url';
  }

  @override
  String get existingPdfFile => 'Existing PDF file';

  @override
  String get articleSavedSuccess => 'Article saved';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get contentRequired => 'Content is required';

  @override
  String confirmDeleteVideoMessage(String videoTitle) {
    return 'Are you sure you want to delete the video \"$videoTitle\"?';
  }

  @override
  String get videoDeletedSuccess => 'Video deleted';

  @override
  String get noVideosFound => 'No videos found';

  @override
  String get addVideoTitle => 'New video';

  @override
  String get editVideoTitle => 'Edit video';

  @override
  String get videoSavedSuccess => 'Video saved';

  @override
  String get youtubeIdLabel => 'YouTube ID';

  @override
  String get youtubeIdHint => 'e.g. dQw4w9WgXcQ';

  @override
  String get youtubeIdRequired => 'YouTube ID is required';

  @override
  String get systemOptionalLabel => 'System (Optional)';

  @override
  String get notSelectedLabel => 'Not selected';

  @override
  String get durationLabel => 'Duration (seconds)';

  @override
  String get durationHint => 'e.g. 600';

  @override
  String get durationRequired => 'Duration is required';

  @override
  String get videoTagsHint => 'e.g. login, error, settings';

  @override
  String get descriptionRequired => 'Description is required';

  @override
  String confirmDeleteSystemMessage(String systemName) {
    return 'Are you sure you want to delete the system \"$systemName\"?';
  }

  @override
  String get systemDeletedSuccess => 'System deleted';

  @override
  String get noSystemsFound => 'No systems found';

  @override
  String get addSystemTitle => 'New system';

  @override
  String get editSystemTitle => 'Edit system';

  @override
  String get systemSavedSuccess => 'System saved';

  @override
  String get shortNameLabel => 'Short name';

  @override
  String get shortNameHint => 'e.g. e-SUD';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get websiteUrlLabel => 'Website URL';

  @override
  String get urlRequired => 'URL is required';

  @override
  String get logoUrlLabel => 'Logo URL';

  @override
  String get logoUrlRequired => 'Logo URL is required';

  @override
  String get statusLabel => 'Status';

  @override
  String get loginGuideIdLabel => 'Login guide ID (Optional)';

  @override
  String get videoGuideIdLabel => 'Video guide ID (Optional)';

  @override
  String confirmDeleteFaqMessage(String question) {
    return 'Are you sure you want to delete the question \"$question\"?';
  }

  @override
  String get faqDeletedSuccess => 'Question deleted';

  @override
  String get noFaqsFound => 'No questions found';

  @override
  String get addFaqTitle => 'New question';

  @override
  String get editFaqTitle => 'Edit question';

  @override
  String get faqSavedSuccess => 'Question saved';

  @override
  String get questionLabel => 'Question';

  @override
  String get questionRequired => 'Question is required';

  @override
  String get answerLabel => 'Answer (Markdown)';

  @override
  String get answerRequired => 'Answer is required';

  @override
  String get add => 'Add';

  @override
  String get titleLabel => 'Title';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search...';

  @override
  String get fieldRequired => 'Field is required';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get successSaved => 'Saved successfully';

  @override
  String get successDeleted => 'Deleted successfully';

  @override
  String get notificationManagementTitle => 'Notification management';

  @override
  String get notificationHistoryTitle => 'Notification history';

  @override
  String get notificationHistoryPlaceholder => 'History of sent notifications will appear here (coming soon).';

  @override
  String get sendNewNotificationButton => 'Send new notification';

  @override
  String get sendNotificationTitle => 'Send notification';

  @override
  String get notificationSentSuccess => 'Notification sent';

  @override
  String get notificationTitleLabel => 'Title';

  @override
  String get notificationTitleRequired => 'Title is required';

  @override
  String get notificationBodyLabel => 'Message body';

  @override
  String get notificationBodyRequired => 'Message body is required';

  @override
  String get notificationTypeLabel => 'Notification type';

  @override
  String get targetAudienceLabel => 'Audience';

  @override
  String get notificationTypeUpdate => 'Update';

  @override
  String get notificationTypeNewContent => 'New content';

  @override
  String get notificationTypeAnnouncement => 'Announcement';

  @override
  String get notificationTypeReminder => 'Reminder';

  @override
  String get notificationTypeSystem => 'System message';

  @override
  String get targetAudienceAll => 'All users';

  @override
  String get targetAudienceBeginner => 'New staff';

  @override
  String get targetAudienceAkt => 'ICT staff';

  @override
  String get targetAudienceSpecific => 'Specific users';

  @override
  String notificationLabelTo(String audience) {
    return 'To: $audience';
  }

  @override
  String notificationLabelReadBy(int count) {
    return 'Read: $count';
  }

  @override
  String get resourceTabArticles => 'Articles';

  @override
  String get resourceTabVideos => 'Videos';

  @override
  String get resourceTabFiles => 'Files';

  @override
  String get filesTabTitle => 'Files';

  @override
  String get systemsDirectoryTitle => 'Court information systems';

  @override
  String get bookmarkSaveTooltip => 'Bookmark';

  @override
  String get bookmarkRemoveTooltip => 'Remove bookmark';

  @override
  String get resourceTypeOther => 'Others';

  @override
  String get openFile => 'Open file';

  @override
  String get fileSize => 'File size';

  @override
  String get selectFile => 'Select file';

  @override
  String get upload => 'Upload';

  @override
  String get processing => 'Processing...';

  @override
  String get urlLabel => 'URL';

  @override
  String get resourceTypePDF => 'PDF manual';

  @override
  String get resourceTypeVideo => 'Video tutorial';

  @override
  String get resourceTypeLink => 'Web link';

  @override
  String get onlySaved => 'Only saved';

  @override
  String get searchArticlesPlaceholder => 'Search articles...';

  @override
  String get filterAll => 'All';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noArticlesAvailable => 'No articles available';

  @override
  String get noVideosAvailable => 'No videos available';

  @override
  String get actionCreateDiscussion => 'Create discussion';

  @override
  String get actionCreateResource => 'Create resource';

  @override
  String get actionCreateQuiz => 'Create quiz';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get loginRequired => 'Login required';

  @override
  String get markAllAsReadTooltip => 'Mark all as read';

  @override
  String get allNotificationsReadMessage => 'All notifications marked as read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get closeAction => 'Close';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String pointsEarned(int points) {
    return 'You earned $points XP!';
  }

  @override
  String levelUp(int level) {
    return 'Congratulations! new level: $level';
  }

  @override
  String get rank => 'Rank';

  @override
  String get quizHistoryTitle => 'Quiz history';

  @override
  String get seeAll => 'See all';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get older => 'Older results';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get landingTitle => 'Professional platform';

  @override
  String get landingSubtitle => 'Elevate your legal knowledge. anytime. anywhere.';

  @override
  String get landingLogin => 'Login';

  @override
  String get landingRegister => 'Register';

  @override
  String get featureKnowledgeBase => 'Knowledge base';

  @override
  String get featureKnowledgeBaseDesc => 'Access a vast library of legal resources and documents.';

  @override
  String get featureVideoTutorials => 'Video tutorials';

  @override
  String get featureVideoTutorialsDesc => 'Learn from expert-led video guides and webinars.';

  @override
  String get featureGamification => 'Gamification';

  @override
  String get featureGamificationDesc => 'Earn XP, badges, and compete on the leaderboard.';

  @override
  String get analyticsTitle => 'Learning analytics (xAPI)';

  @override
  String get analyticsSubtitle => 'Learning records';

  @override
  String get totalRecords => 'Total records';

  @override
  String get realTime => 'Real-time';

  @override
  String get activityDistribution => 'Activity distribution';

  @override
  String get recentActivityFeed => 'Recent activity feed';

  @override
  String get noRecords => 'No learning records found yet.';

  @override
  String get unknownUser => 'Unknown user';

  @override
  String get unknownObject => 'Unknown object';

  @override
  String get justNow => 'Just now';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get simulations => 'Simulations';

  @override
  String get catNewEmployees => 'New employees';

  @override
  String get catIctSpecialists => 'ICT specialists';

  @override
  String get catSystems => 'Systems';

  @override
  String get catAuth => 'Authentication';

  @override
  String get catGeneral => 'General';

  @override
  String get rankBeginner => 'Beginner';

  @override
  String get rankIntermediate => 'Intermediate';

  @override
  String get rankAdvanced => 'Advanced';

  @override
  String get sysCatPrimary => 'Primary systems';

  @override
  String get sysCatSecondary => 'Secondary systems';

  @override
  String get sysCatSupport => 'Support systems';

  @override
  String get sysStatusActive => 'Active';

  @override
  String get sysStatusMaintenance => 'Maintenance';

  @override
  String get sysStatusInactive => 'Inactive';

  @override
  String videoViews(int count) {
    return '$count views';
  }

  @override
  String get videoAuthorSubtitle => 'Author';

  @override
  String get videoDescriptionTitle => 'Description';

  @override
  String get sysStatusDeprecated => 'Deprecated';

  @override
  String get sysStatusOffline => 'Offline';

  @override
  String get systemsDirectoryAll => 'All';

  @override
  String systemsDirectoryError(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get systemsDirectoryEmpty => 'No systems available';

  @override
  String get backToKnowledgeBase => 'Back to guides';

  @override
  String get quizSuccessMessage => 'Great result!';

  @override
  String get quizFailureMessage => 'Try again!';

  @override
  String get failedToLoadQuiz => 'Failed to load quiz';

  @override
  String get failedToSaveAttempt => 'Failed to save attempt';

  @override
  String get quizNotFound => 'Quiz not found';

  @override
  String question(String index) {
    return 'Question $index';
  }

  @override
  String get speedBonus => 'Speed bonus';

  @override
  String get levelBeginner => 'Newbie';

  @override
  String get levelSpecialist => 'Specialist';

  @override
  String get levelExpert => 'Expert';

  @override
  String get levelMaster => 'Master';

  @override
  String totalQuestions(String total) {
    return 'Total: $total';
  }

  @override
  String get errorCouldNotOpenLink => 'Could not open link';

  @override
  String get errorResourceNotFound => 'Resource not found';

  @override
  String get errorVideoNotFound => 'Video not found';

  @override
  String get errorPdfOpen => 'Could not open PDF file';

  @override
  String get errorTelegramOpen => 'Could not open telegram link';

  @override
  String errorGeneric(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get labelTrue => 'True';

  @override
  String get labelFalse => 'False';

  @override
  String get labelPass => 'Pass';

  @override
  String get labelFail => 'Fail';

  @override
  String get labelPdfAvailable => 'PDF available';

  @override
  String get actionOk => 'OK';

  @override
  String get actionGoBack => 'Go back';

  @override
  String get searchNoResults => 'No results found';

  @override
  String roleChangedSuccess(String userName, String role) {
    return '$userName\'s role changed to $role';
  }

  @override
  String roleChangeError(String error) {
    return 'Error changing role: $error';
  }

  @override
  String get changeRoleTooltip => 'Change role';

  @override
  String get labelVideoGuide => 'Video guide';

  @override
  String get labelLoginGuide => 'Login guide';

  @override
  String get changePasswordHint => 'Change password implementation here';

  @override
  String get editTopic => 'Edit topic';

  @override
  String get update => 'Update';

  @override
  String get commentAdded => 'Comment added!';

  @override
  String get updateFeatureMigration => 'Update feature is under migration. coming soon!';

  @override
  String get topicUpdatedSuccessfully => 'Topic updated successfully';

  @override
  String errorDeletingTopicMsg(String error) {
    return 'Error deleting topic: $error';
  }

  @override
  String get takeQuizTitle => 'Take quiz';

  @override
  String get quizTakingInterface => 'Quiz taking interface (Coming soon)';

  @override
  String get quizCreatedSuccessfully => 'Quiz created successfully';

  @override
  String get saveQuizAction => 'Save quiz';

  @override
  String get createQuizTitle => 'Create quiz';

  @override
  String editQuestionsTitle(String title) {
    return 'Edit questions: $title';
  }

  @override
  String get questionsManagementComingSoon => 'Questions management coming soon';

  @override
  String get aiAssistantName => 'AI assistant \"Sodiq\"';

  @override
  String get retryAction => 'Retry';

  @override
  String get clearChatTooltip => 'Clear chat';

  @override
  String get noInternetLabel => 'No internet';

  @override
  String get noInternetQuery => 'Internet is not working, what should i do?';

  @override
  String get fileNotOpeningLabel => 'File won\'t open';

  @override
  String get fileNotOpeningQuery => 'PDF file won\'t open, help me.';

  @override
  String get printerNotWorkingLabel => 'Printer not working';

  @override
  String get printerNotWorkingQuery => 'Printer is not printing, what should i do?';

  @override
  String get uploadImageTooltip => 'Upload image';

  @override
  String get writeMessageHint => 'Write a message...';

  @override
  String get aiMentorName => 'Sodiq (AI mentor)';

  @override
  String get trueOption => 'True';

  @override
  String get falseOption => 'False';

  @override
  String get questionsListTab => 'Questions';

  @override
  String get addQuestionTab => 'Add question';

  @override
  String get addOptionButton => 'Add option';

  @override
  String get deleteQuestionConfirm => 'Delete this question?';

  @override
  String get questionDeleted => 'Question deleted';

  @override
  String get startQuiz => 'Start quiz';

  @override
  String get nextQuestion => 'Next';

  @override
  String get previousQuestion => 'Previous';

  @override
  String get submitQuiz => 'Submit';

  @override
  String get quizResults => 'Results';

  @override
  String get yourScore => 'Your score';

  @override
  String questionOfTotal(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get selectAnAnswer => 'Please select an answer';

  @override
  String correctAnswerIs(String answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get retakeQuiz => 'Retake quiz';

  @override
  String get backToQuizList => 'Back to quizzes';

  @override
  String questionsCount(int count) {
    return '$count questions';
  }

  @override
  String get excellentScore => 'Excellent! 🎉';

  @override
  String get goodScore => 'Good job! 👍';

  @override
  String get needsImprovement => 'Keep practicing! 💪';

  @override
  String get noQuestionsInQuiz => 'This quiz has no questions yet.';

  @override
  String get resumeLearning => 'Resume learning';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get availableResources => 'Available resources';

  @override
  String get availableQuizzes => 'Available quizzes';

  @override
  String get activeDiscussions => 'Active discussions';

  @override
  String get recommendedResources => 'Recommended resources';

  @override
  String get pagesPath => 'Pages / dashboard';

  @override
  String get mainDashboard => 'Main dashboard';

  @override
  String get overview => 'Overview';

  @override
  String get noRecentActivities => 'No recent activities.';

  @override
  String get signInToSeeActivities => 'Sign in to see activities.';

  @override
  String get noResourcesAvailable => 'No resources available.';

  @override
  String quizCompletedPrefix(String quizId) {
    return 'Quiz completed: $quizId';
  }

  @override
  String get loadOlderNotifications => 'Load older notifications';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterSystems => 'Systems';

  @override
  String get searchFilterArticles => 'Articles';

  @override
  String get searchFilterVideos => 'Videos';

  @override
  String get searchFilterFAQ => 'FAQ';

  @override
  String get searchFilterCourses => 'Courses';

  @override
  String get searchErrorTitle => 'An error occurred';

  @override
  String searchNoResultsForQuery(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String searchResultsHeader(int count) {
    return '🔍 results ($count)';
  }

  @override
  String searchSemanticHeader(int count) {
    return '📎 related materials ($count)';
  }

  @override
  String get searchSemanticBadge => '📎 related';

  @override
  String get searchEmptyPromptTitle => 'Unified search';

  @override
  String get searchEmptyPromptDesc => 'Systems, articles, videos, courses, and\nFAQ — find everything in one place';

  @override
  String get searchTypeSystem => 'System';

  @override
  String get searchTypeArticle => 'Article';

  @override
  String get searchTypeVideo => 'Video';

  @override
  String get searchTypeFaq => 'FAQ';

  @override
  String get searchTypeResource => 'Resource';

  @override
  String get searchTypeCourse => 'Course';

  @override
  String get leaderboardTabGlobal => 'Global';

  @override
  String get leaderboardTabRegion => 'Region';

  @override
  String get leaderboardTabCourt => 'My court';

  @override
  String get noRegionInfo => 'No region data';

  @override
  String get noCourtInfo => 'No court data';

  @override
  String get selectYourCourtTitle => 'Select your court';

  @override
  String get selectYourCourtSubtitle => 'Specify the court you work in\nfor regional statistics and leaderboards';

  @override
  String get selectRegionLabel => 'Select region';

  @override
  String get regionDropdownLabel => '📍 region / province';

  @override
  String get selectCourtTypeLabel => 'Select court type';

  @override
  String get courtTypeDropdownLabel => '⚖️ court type';

  @override
  String get selectRegionFirst => 'First select a region';

  @override
  String get selectSpecificCourtLabel => 'Select specific court';

  @override
  String get specificCourtDropdownLabel => '🏛️ specific court';

  @override
  String get selectCourtTypeFirst => 'First select a court type';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get savingInProgress => 'Saving...';

  @override
  String get courtDataHeader => 'Court data';

  @override
  String get articleDetailTitle => 'Article details';

  @override
  String get articlePinned => 'Important';

  @override
  String get bottomNavKnowledge => 'Knowledge base';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get feedbackThanks => 'Thank you for your feedback!';

  @override
  String get shareArticle => 'Share article';

  @override
  String get topicTitle => 'Topic';

  @override
  String get myCoursesTitle => 'My courses';

  @override
  String get myCoursesEmptyTitle => 'You haven\'t started any courses yet';

  @override
  String get myCoursesEmptySubtitle => 'Start courses to learn new skills and earn XP.';

  @override
  String get coursesTitle => 'Courses';

  @override
  String get boostYourKnowledge => 'Boost your knowledge';

  @override
  String get searchCoursesHint => 'Search courses...';

  @override
  String get courseFilterAll => 'All';

  @override
  String get courseFilterBeginner => 'Beginner';

  @override
  String get courseFilterIntermediate => 'Intermediate';

  @override
  String get courseFilterAdvanced => 'Advanced';

  @override
  String get coursesNotFound => 'No courses found';

  @override
  String get errorLabel => 'Error';

  @override
  String get statCourses => 'Courses';

  @override
  String get statCompleted => 'Completed';

  @override
  String get statXpPoints => 'XP points';

  @override
  String get tabAll => 'All';

  @override
  String get tabCompleted => '✓ Completed';

  @override
  String get tabInProgress => '▶ In Progress';

  @override
  String get statusOnline => 'ONLINE';

  @override
  String get statusOffline => 'OFFLINE';
}
