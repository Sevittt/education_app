// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Court Handbook';

  @override
  String get loginWelcomeTitle => 'Welcome Back!';

  @override
  String get loginWelcomeSubtitle => 'Sign in to continue';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavResources => 'Guides';

  @override
  String get bottomNavCommunity => 'Forum';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get resourcesScreenTitle => 'Guides & Manuals';

  @override
  String get roleXodim => 'Staff';

  @override
  String get roleEkspert => 'Expert';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get registrationTitle => 'Create Your Account';

  @override
  String get registrationSubtitle => 'Join the professional community!';

  @override
  String get registrationFullNameLabel => 'Full Name';

  @override
  String get registrationFullNameError => 'Please enter your full name';

  @override
  String get registrationRoleLabel => 'Your Role';

  @override
  String get registrationRoleError => 'Please select a role';

  @override
  String get registrationRoleXodim => 'Regular Staff';

  @override
  String get registrationRoleEkspert => 'Expert (Content Creator)';

  @override
  String get registrationPasswordLabel => 'Password';

  @override
  String get registrationPasswordError => 'Password must be at least 6 characters long';

  @override
  String get registrationConfirmPasswordLabel => 'Confirm Password';

  @override
  String get registrationConfirmPasswordError => 'Passwords do not match';

  @override
  String get registrationSignUpButton => 'Sign Up';

  @override
  String get registrationSwitchToLogin => 'Already have an account? Sign In';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageUzbek => 'Uzbek';

  @override
  String get languageRussian => 'Russian';

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
  String get settingsAboutApp => 'About Court Handbook';

  @override
  String get settingsAppLegalese => '© 2025 Court Handbook Project';

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
  String get communityScreenTitle => 'Forum';

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
  String get resourcesTitle => 'Guides';

  @override
  String get resourcesSearchHint => 'Search guides...';

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
  String get createResourceScreenTitle => 'Create New Guide';

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
  String get createResourceTypeLabel => 'System Type';

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
  String get editResourceScreenTitle => 'Edit Guide';

  @override
  String get resourceTypeLabel => 'Type';

  @override
  String get editTopicScreenTitle => 'Edit Discussion Topic';

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
  String failedToCreateTopic(String error, String xato) {
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
  String failedToUpdateTopic(String error, String xato) {
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
  String failedToAddComment(String error, String xato) {
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
  String get communityTitle => 'Forum';

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
  String get manageResourcesTitle => 'Manage Guides';

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
  String failedToDeleteNews(String error, Object newsTitle) {
    return 'Failed to delete \"$newsTitle\": $error';
  }

  @override
  String get faqTitle => 'FAQ';

  @override
  String get searchHelp => 'Search help...';

  @override
  String get allCategories => 'All Categories';

  @override
  String get helpfulFeedback => 'Was this helpful?';

  @override
  String get noArticlesFound => 'No FAQs found';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get helpCenterTitle => 'Help Center';

  @override
  String get settingsAbout => 'About App';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully';

  @override
  String get errorWrongPassword => 'Incorrect current password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get save => 'Save';

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
  String failedToSaveNews(String error, Object xato) {
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
  String failedToDeleteResource(String error, Object resourceTitle) {
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
  String failedToDeleteQuiz(String error, Object quizTitle) {
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

  @override
  String get registrationEmailError => 'Please enter a valid email address';

  @override
  String get dashboardXodimTitle => 'My Activity';

  @override
  String get dashboardEkspertTitle => 'My Contributions';

  @override
  String get dashboardAdminTitle => 'System Overview';

  @override
  String get seeAllButton => 'See All';

  @override
  String get noGuidesAuthored => 'You have not authored any guides yet.';

  @override
  String get adminStatUsers => 'Users';

  @override
  String get adminStatGuides => 'Guides';

  @override
  String get adminStatQuizzes => 'Quizzes';

  @override
  String get orDivider => 'OR';

  @override
  String get signInWithGoogle => 'Sign In with Google';

  @override
  String get themeSystemDefault => 'System Default';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get bioOptionalLabel => 'Bio (Optional)';

  @override
  String get profilePictureUrlLabel => 'Profile Picture URL (Optional)';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get levelExpert => 'Expert';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get nextLevel => 'Next Level';

  @override
  String pointsToNextLevel(Object points) {
    return '$points XP to next level';
  }

  @override
  String get manageArticlesTitle => 'Articles';

  @override
  String get manageArticlesSubtitle => 'Manage Knowledge Base';

  @override
  String get manageVideosTitle => 'Videos';

  @override
  String get manageVideosSubtitle => 'Manage Video Tutorials';

  @override
  String get manageSystemsTitle => 'Systems';

  @override
  String get manageSystemsSubtitle => 'Manage Systems Directory';

  @override
  String get manageFaqTitle => 'FAQ';

  @override
  String get manageFaqSubtitle => 'Manage FAQs';

  @override
  String get manageNotificationsTitle => 'Notifications';

  @override
  String get manageNotificationsSubtitle => 'Send Notifications';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String topicDeletedSuccess(Object topicTitle) {
    return '\"$topicTitle\" deleted successfully.';
  }

  @override
  String failedToDeleteTopic(Object error) {
    return 'Failed to delete topic: $error';
  }

  @override
  String deleteTopicConfirmMessage(Object topicTitle) {
    return 'Are you sure you want to delete \"$topicTitle\"?';
  }

  @override
  String get editTopicTooltip => 'Edit Topic';

  @override
  String get deleteTopicConfirmTitle => 'Delete Topic';

  @override
  String get commentPlural => 'Comments';

  @override
  String get commentSingular => 'Comment';

  @override
  String get deleteTopicTooltip => 'Delete Topic';

  @override
  String get faqCategoryLogin => 'Login Issues';

  @override
  String get faqCategoryPassword => 'Password Issues';

  @override
  String get faqCategoryUpload => 'File Upload';

  @override
  String get faqCategoryAccess => 'Access Rights';

  @override
  String get faqCategoryGeneral => 'General Questions';

  @override
  String get faqCategoryTechnical => 'Technical Issues';

  @override
  String confirmDeleteArticleMessage(Object articleTitle) {
    return 'Are you sure you want to delete the article \"$articleTitle\"?';
  }

  @override
  String get addArticleTitle => 'New Article';

  @override
  String get editArticleTitle => 'Edit Article';

  @override
  String get categoryLabel => 'Category';

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
  String currentFileLabel(Object url) {
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
  String confirmDeleteVideoMessage(Object videoTitle) {
    return 'Are you sure you want to delete the video \"$videoTitle\"?';
  }

  @override
  String get videoDeletedSuccess => 'Video deleted';

  @override
  String get noVideosFound => 'No videos found';

  @override
  String get addVideoTitle => 'New Video';

  @override
  String get editVideoTitle => 'Edit Video';

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
  String get notSelectedLabel => 'Not Selected';

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
  String confirmDeleteSystemMessage(Object systemName) {
    return 'Are you sure you want to delete the system \"$systemName\"?';
  }

  @override
  String get systemDeletedSuccess => 'System deleted';

  @override
  String get noSystemsFound => 'No systems found';

  @override
  String get addSystemTitle => 'New System';

  @override
  String get editSystemTitle => 'Edit System';

  @override
  String get systemSavedSuccess => 'System saved';

  @override
  String get shortNameLabel => 'Short Name';

  @override
  String get shortNameHint => 'e.g. e-SUD';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get fullNameLabel => 'Full Name';

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
  String get loginGuideIdLabel => 'Login Guide ID (Optional)';

  @override
  String get videoGuideIdLabel => 'Video Guide ID (Optional)';

  @override
  String confirmDeleteFaqMessage(Object question) {
    return 'Are you sure you want to delete the question \"$question\"?';
  }

  @override
  String get faqDeletedSuccess => 'Question deleted';

  @override
  String get noFaqsFound => 'No questions found';

  @override
  String get addFaqTitle => 'New Question';

  @override
  String get editFaqTitle => 'Edit Question';

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
  String get notificationManagementTitle => 'Notification Management';

  @override
  String get notificationHistoryTitle => 'Notification History';

  @override
  String get notificationHistoryPlaceholder => 'History of sent notifications will appear here (coming soon).';

  @override
  String get sendNewNotificationButton => 'Send New Notification';

  @override
  String get sendNotificationTitle => 'Send Notification';

  @override
  String get notificationSentSuccess => 'Notification sent';

  @override
  String get notificationTitleLabel => 'Title';

  @override
  String get notificationTitleRequired => 'Title is required';

  @override
  String get notificationBodyLabel => 'Message Body';

  @override
  String get notificationBodyRequired => 'Message body is required';

  @override
  String get notificationTypeLabel => 'Notification Type';

  @override
  String get targetAudienceLabel => 'Audience';

  @override
  String get resourceTabArticles => 'Articles';

  @override
  String get resourceTabVideos => 'Videos';

  @override
  String get resourceTabFiles => 'Files';

  @override
  String get filesTabTitle => 'Files';

  @override
  String get systemsDirectoryTitle => 'Court Information Systems';

  @override
  String get bookmarkSaveTooltip => 'Bookmark';

  @override
  String get bookmarkRemoveTooltip => 'Remove Bookmark';

  @override
  String get resourceTypeOther => 'Others';

  @override
  String get openFile => 'Open File';

  @override
  String get fileSize => 'File Size';

  @override
  String get selectFile => 'Select File';

  @override
  String get upload => 'Upload';

  @override
  String get processing => 'Processing...';

  @override
  String get urlLabel => 'URL';

  @override
  String get resourceTypePDF => 'PDF Manual';

  @override
  String get resourceTypeVideo => 'Video Tutorial';

  @override
  String get resourceTypeLink => 'Web Link';
}
