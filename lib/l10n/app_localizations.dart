import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Judicial guide'**
  String get appTitle;

  /// Translation for openInYoutube
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get openInYoutube;

  /// Translation for watchOnYoutube
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get watchOnYoutube;

  /// Title on the login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get loginWelcomeTitle;

  /// Subtitle on the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginWelcomeSubtitle;

  /// Translation for bottomNavHome
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// Translation for bottomNavResources
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get bottomNavResources;

  /// Translation for bottomNavCommunity
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get bottomNavCommunity;

  /// Translation for bottomNavProfile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// Title for the resources/guides screen
  ///
  /// In en, this message translates to:
  /// **'Guides & manuals'**
  String get resourcesScreenTitle;

  /// User role for a regular staff member
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleXodim;

  /// User role for an expert who can create content
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get roleEkspert;

  /// User role for an administrator
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// Translation for registrationTitle
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registrationTitle;

  /// Translation for registrationSubtitle
  ///
  /// In en, this message translates to:
  /// **'Join the professional community!'**
  String get registrationSubtitle;

  /// Label for the full name field on registration screen
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registrationFullNameLabel;

  /// Error message if full name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get registrationFullNameError;

  /// Label for the role selection on registration screen
  ///
  /// In en, this message translates to:
  /// **'Your role'**
  String get registrationRoleLabel;

  /// Error message if no role is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get registrationRoleError;

  /// Option for 'xodim' (staff) role
  ///
  /// In en, this message translates to:
  /// **'Regular staff'**
  String get registrationRoleXodim;

  /// Option for 'ekspert' (expert) role
  ///
  /// In en, this message translates to:
  /// **'Expert (content creator)'**
  String get registrationRoleEkspert;

  /// Role option: Judge
  ///
  /// In en, this message translates to:
  /// **'Judge'**
  String get registrationRoleJudge;

  /// Role option: Assistant
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get registrationRoleAssistant;

  /// Role option: Chancellery
  ///
  /// In en, this message translates to:
  /// **'Chancellery'**
  String get registrationRoleChancellery;

  /// Role option: Archive
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get registrationRoleArchive;

  /// Role option: ICT Specialist
  ///
  /// In en, this message translates to:
  /// **'ICT specialist'**
  String get registrationRoleIctSpecialist;

  /// Label for the password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registrationPasswordLabel;

  /// Error message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get registrationPasswordError;

  /// Label for the confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registrationConfirmPasswordLabel;

  /// Error message if passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registrationConfirmPasswordError;

  /// Text for the sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registrationSignUpButton;

  /// Text to switch to login screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account? sign in'**
  String get registrationSwitchToLogin;

  /// Translation for languageEnglish
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEnglish;

  /// Translation for languageUzbek
  ///
  /// In en, this message translates to:
  /// **'Uzbek (Uzbekistan)'**
  String get languageUzbek;

  /// Translation for languageRussian
  ///
  /// In en, this message translates to:
  /// **'Russian (Russia)'**
  String get languageRussian;

  /// Translation for languageSystemDefault
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// Translation for settingsScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// Translation for settingsLanguage
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Translation for settingsReceiveNotifications
  ///
  /// In en, this message translates to:
  /// **'Receive notifications'**
  String get settingsReceiveNotifications;

  /// Translation for settingsReceiveNotificationsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Get updates about new resources and discussions'**
  String get settingsReceiveNotificationsSubtitle;

  /// Translation for settingsAllowLocation
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get settingsAllowLocation;

  /// Translation for settingsAllowLocationSubtitle
  ///
  /// In en, this message translates to:
  /// **'For features requiring your location (if any)'**
  String get settingsAllowLocationSubtitle;

  /// Translation for settingsChangePassword
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// Translation for settingsHelpCenter
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get settingsHelpCenter;

  /// Translation for settingsAboutApp
  ///
  /// In en, this message translates to:
  /// **'About court handbook'**
  String get settingsAboutApp;

  /// Translation for settingsAppLegalese
  ///
  /// In en, this message translates to:
  /// **'© 2025 court handbook project'**
  String get settingsAppLegalese;

  /// Translation for settingsAppDescription
  ///
  /// In en, this message translates to:
  /// **'Bridging the iT skills gap through collaborative learning and resource sharing.'**
  String get settingsAppDescription;

  /// Translation for errorPrefix
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// Translation for days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Translation for resourcesNoResourcesFound
  ///
  /// In en, this message translates to:
  /// **'No resources found.'**
  String get resourcesNoResourcesFound;

  /// Translation for loginButtonText
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButtonText;

  /// Translation for signUpButtonText
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpButtonText;

  /// Login screen text asking if user has no account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// Translation for logoutButtonText
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButtonText;

  /// Translation for logoutConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Are you sure to logout'**
  String get logoutConfirmTitle;

  /// Translation for emailLabel
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Translation for passwordLabel
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Translation for homeDashboardTitle
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeDashboardTitle;

  /// Translation for communityScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get communityScreenTitle;

  /// Translation for profileScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// Translation for editProfileButtonText
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileButtonText;

  /// Translation for guestUser
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// Translation for updateYourInformation
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get updateYourInformation;

  /// Translation for loginToEditProfile
  ///
  /// In en, this message translates to:
  /// **'Log in to edit your profile'**
  String get loginToEditProfile;

  /// Translation for settingsTitle
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Translation for themeOptionsTitle
  ///
  /// In en, this message translates to:
  /// **'Theme options'**
  String get themeOptionsTitle;

  /// Translation for logoutConfirmMessage
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// Translation for saveChangesButton
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChangesButton;

  /// Category: Beginner
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get vidCategoryBeginner;

  /// Category: Intermediate
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get vidCategoryIntermediate;

  /// Category: Advanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get vidCategoryAdvanced;

  /// Category: Practical
  ///
  /// In en, this message translates to:
  /// **'Practical'**
  String get vidCategoryPractical;

  /// Category: Theory
  ///
  /// In en, this message translates to:
  /// **'Theory'**
  String get vidCategoryTheory;

  /// Translation for cancelButton
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Translation for logoutButton
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// Translation for resourcesTitle
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get resourcesTitle;

  /// Translation for resourcesSearchHint
  ///
  /// In en, this message translates to:
  /// **'Search guides...'**
  String get resourcesSearchHint;

  /// Translation for resourcesFilterByType
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get resourcesFilterByType;

  /// Translation for resourcesAllTypes
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get resourcesAllTypes;

  /// Translation for resourcesNoResourcesMatch
  ///
  /// In en, this message translates to:
  /// **'No resources match your criteria.'**
  String get resourcesNoResourcesMatch;

  /// Translation for resourcesTryAdjusting
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter.'**
  String get resourcesTryAdjusting;

  /// Translation for resourcesCreateButton
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get resourcesCreateButton;

  /// Translation for resourceAddedSuccess
  ///
  /// In en, this message translates to:
  /// **'Resource added successfully!'**
  String get resourceAddedSuccess;

  /// Error message when adding a resource fails
  ///
  /// In en, this message translates to:
  /// **'Error adding resource: {error}'**
  String resourceAddedError(String error);

  /// Translation for createResourceScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Create new guide'**
  String get createResourceScreenTitle;

  /// Translation for createResourceFormWillBeHere
  ///
  /// In en, this message translates to:
  /// **'Resource creation form will be here.'**
  String get createResourceFormWillBeHere;

  /// Translation for saveButtonText
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveButtonText;

  /// Translation for createResourceTitleLabel
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get createResourceTitleLabel;

  /// Translation for createResourceDescriptionLabel
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createResourceDescriptionLabel;

  /// Translation for createResourceAuthorLabel
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get createResourceAuthorLabel;

  /// Translation for createResourceTypeLabel
  ///
  /// In en, this message translates to:
  /// **'System type'**
  String get createResourceTypeLabel;

  /// Translation for createResourceUrlLabel
  ///
  /// In en, this message translates to:
  /// **'URL (optional)'**
  String get createResourceUrlLabel;

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(String url);

  /// No description provided for @createResourceValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a {fieldName}'**
  String createResourceValidationEmpty(String fieldName);

  /// No description provided for @createResourceValidationSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select a {fieldName}'**
  String createResourceValidationSelect(String fieldName);

  /// Translation for createResourceValidationInvalidUrl
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get createResourceValidationInvalidUrl;

  /// Translation for editButtonTooltip
  ///
  /// In en, this message translates to:
  /// **'Edit resource'**
  String get editButtonTooltip;

  /// Translation for editResourceScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Edit guide'**
  String get editResourceScreenTitle;

  /// Translation for resourceTypeLabel
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get resourceTypeLabel;

  /// Title for the screen where users edit a discussion topic
  ///
  /// In en, this message translates to:
  /// **'Edit discussion topic'**
  String get editTopicScreenTitle;

  /// Translation for authorLabel
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// Translation for dateAddedLabel
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get dateAddedLabel;

  /// Translation for launchingUrlMessage
  ///
  /// In en, this message translates to:
  /// **'Launching URL'**
  String get launchingUrlMessage;

  /// Label for description fields
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Translation for resourceUpdatedSuccess
  ///
  /// In en, this message translates to:
  /// **'Resource updated successfully!'**
  String get resourceUpdatedSuccess;

  /// Error message when updating a resource fails
  ///
  /// In en, this message translates to:
  /// **'Error updating resource: {error}'**
  String resourceUpdatedError(String error);

  /// Translation for deleteResourceConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get deleteResourceConfirmTitle;

  /// Translation for deleteResourceConfirmMessage
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this resource? this action cannot be undone.'**
  String get deleteResourceConfirmMessage;

  /// Translation for cancelButtonText
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonText;

  /// Translation for deleteButtonText
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonText;

  /// No description provided for @resourceDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resource \"{resourceTitle}\" deleted successfully.'**
  String resourceDeletedSuccess(String resourceTitle);

  /// No description provided for @resourceDeletedError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting resource: {error}'**
  String resourceDeletedError(String error);

  /// Translation for deleteButtonTooltip
  ///
  /// In en, this message translates to:
  /// **'Delete resource'**
  String get deleteButtonTooltip;

  /// Translation for createANewQuiz
  ///
  /// In en, this message translates to:
  /// **'Create a new quiz'**
  String get createANewQuiz;

  /// Translation for quizTitle
  ///
  /// In en, this message translates to:
  /// **'Quiz title'**
  String get quizTitle;

  /// Translation for quizDescription
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get quizDescription;

  /// Translation for saveAndAddQuestions
  ///
  /// In en, this message translates to:
  /// **'Save and add questions'**
  String get saveAndAddQuestions;

  /// Translation for failedToCreateQuiz
  ///
  /// In en, this message translates to:
  /// **'Failed to create quiz'**
  String get failedToCreateQuiz;

  /// Translation for addQuestions
  ///
  /// In en, this message translates to:
  /// **'Add questions'**
  String get addQuestions;

  /// Translation for finish
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Translation for questionText
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get questionText;

  /// Translation for pleaseEnterAQuestion
  ///
  /// In en, this message translates to:
  /// **'Please enter a question'**
  String get pleaseEnterAQuestion;

  /// Translation for questionType
  ///
  /// In en, this message translates to:
  /// **'Question type'**
  String get questionType;

  /// Translation for multipleChoice
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get multipleChoice;

  /// Translation for trueFalse
  ///
  /// In en, this message translates to:
  /// **'True/False'**
  String get trueFalse;

  /// Translation for pleaseSelectCorrectAnswer
  ///
  /// In en, this message translates to:
  /// **'Please select a correct answer.'**
  String get pleaseSelectCorrectAnswer;

  /// No description provided for @option.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String option(int number);

  /// Translation for pleaseEnterAnOption
  ///
  /// In en, this message translates to:
  /// **'Please enter an option'**
  String get pleaseEnterAnOption;

  /// Translation for addQuestion
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get addQuestion;

  /// Translation for questionAddedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Question added successfully!'**
  String get questionAddedSuccessfully;

  /// Translation for failedToAddQuestion
  ///
  /// In en, this message translates to:
  /// **'Failed to add question'**
  String get failedToAddQuestion;

  /// Translation for noQuestionsAddedYet
  ///
  /// In en, this message translates to:
  /// **'No questions added yet.'**
  String get noQuestionsAddedYet;

  /// Translation for correctAnswer
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctAnswer;

  /// Translation for quiz
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// Translation for quizCompletionMessage
  ///
  /// In en, this message translates to:
  /// **'You have completed the quiz!'**
  String get quizCompletionMessage;

  /// Translation for done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Translation for myQuizHistory
  ///
  /// In en, this message translates to:
  /// **'My quiz history'**
  String get myQuizHistory;

  /// Translation for noQuizAttempts
  ///
  /// In en, this message translates to:
  /// **'You haven\'t attempted any quizzes yet.'**
  String get noQuizAttempts;

  /// Translation for score
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Translation for role
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Translation for loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Translation for relatedQuizzesTitle
  ///
  /// In en, this message translates to:
  /// **'Related quizzes'**
  String get relatedQuizzesTitle;

  /// Translation for noQuizzesAvailable
  ///
  /// In en, this message translates to:
  /// **'No quizzes available for this resource yet.'**
  String get noQuizzesAvailable;

  /// Translation for errorLoadingQuizzes
  ///
  /// In en, this message translates to:
  /// **'Error loading quizzes'**
  String get errorLoadingQuizzes;

  /// No description provided for @invalidUrlFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL format: {url}'**
  String invalidUrlFormat(String url);

  /// No description provided for @errorLaunchingUrl.
  ///
  /// In en, this message translates to:
  /// **'Error launching URL: {error}'**
  String errorLaunchingUrl(String error);

  /// No description provided for @createResourceValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be at least {length} characters long'**
  String createResourceValidationMinLength(String fieldName, int length);

  /// No description provided for @createResourceValidationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot exceed {length} characters'**
  String createResourceValidationMaxLength(String fieldName, int length);

  /// Translation for titleMinLength
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters long'**
  String get titleMinLength;

  /// Translation for titleMaxLength
  ///
  /// In en, this message translates to:
  /// **'Title cannot exceed 100 characters'**
  String get titleMaxLength;

  /// Translation for createTopicScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Start new discussion'**
  String get createTopicScreenTitle;

  /// Translation for createTopicTitleLabel
  ///
  /// In en, this message translates to:
  /// **'Topic title'**
  String get createTopicTitleLabel;

  /// Translation for createTopicContentLabel
  ///
  /// In en, this message translates to:
  /// **'Discussion content'**
  String get createTopicContentLabel;

  /// Translation for createTopicButtonText
  ///
  /// In en, this message translates to:
  /// **'Create discussion topic'**
  String get createTopicButtonText;

  /// Translation for mustBeLoggedInToCreateTopic
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to create a topic.'**
  String get mustBeLoggedInToCreateTopic;

  /// Translation for topicCreatedSuccess
  ///
  /// In en, this message translates to:
  /// **'Topic created successfully!'**
  String get topicCreatedSuccess;

  /// Error message when creating a topic fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create topic: {error}'**
  String failedToCreateTopic(String error);

  /// No description provided for @createTopicValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot be empty.'**
  String createTopicValidationEmpty(String fieldName);

  /// No description provided for @createTopicValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be at least {length} characters long.'**
  String createTopicValidationMinLength(String fieldName, int length);

  /// No description provided for @createTopicValidationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot exceed {length} characters.'**
  String createTopicValidationMaxLength(String fieldName, int length);

  /// Translation for errorLoadingData
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading resources. please try again.'**
  String get errorLoadingData;

  /// Error message shown when topic update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating topic: {error}'**
  String failedToUpdateTopic(String error);

  /// Translation for topicUpdatedSuccess
  ///
  /// In en, this message translates to:
  /// **'Topic updated successfully!'**
  String get topicUpdatedSuccess;

  /// Translation for noDiscussionsYet
  ///
  /// In en, this message translates to:
  /// **'No discussions yet.'**
  String get noDiscussionsYet;

  /// Translation for beTheFirstToStartConversation
  ///
  /// In en, this message translates to:
  /// **'Be the first to start a conversation!'**
  String get beTheFirstToStartConversation;

  /// Translation for mustBeLoggedInToCreateResource
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to create a resource.'**
  String get mustBeLoggedInToCreateResource;

  /// Translation for profileIncompleteToCreateResource
  ///
  /// In en, this message translates to:
  /// **'Your profile information is incomplete. please update your name in your profile.'**
  String get profileIncompleteToCreateResource;

  /// Translation for profileIncompleteToCreateTopic
  ///
  /// In en, this message translates to:
  /// **'Your profile name is not set. please update your profile.'**
  String get profileIncompleteToCreateTopic;

  /// Translation for commentCannotBeEmpty
  ///
  /// In en, this message translates to:
  /// **'Comment cannot be empty.'**
  String get commentCannotBeEmpty;

  /// Translation for mustBeLoggedInToComment
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to comment.'**
  String get mustBeLoggedInToComment;

  /// Translation for commentAddedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully!'**
  String get commentAddedSuccessfully;

  /// Error message when adding a comment fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add comment: {error}'**
  String failedToAddComment(String error);

  /// No description provided for @postedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted by {authorName}'**
  String postedBy(String authorName);

  /// No description provided for @onDate.
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String onDate(String date);

  /// Translation for repliesTitle
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get repliesTitle;

  /// No description provided for @errorLoadingComments.
  ///
  /// In en, this message translates to:
  /// **'Error loading comments: {error}'**
  String errorLoadingComments(String error);

  /// Translation for noRepliesYet
  ///
  /// In en, this message translates to:
  /// **'No replies yet. be the first to comment!'**
  String get noRepliesYet;

  /// Translation for writeAReplyHint
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get writeAReplyHint;

  /// Translation for sendCommentTooltip
  ///
  /// In en, this message translates to:
  /// **'Send comment'**
  String get sendCommentTooltip;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {userName}!'**
  String welcomeBack(String userName);

  /// Translation for readyToLearnSomethingNew
  ///
  /// In en, this message translates to:
  /// **'Ready to learn something new today?'**
  String get readyToLearnSomethingNew;

  /// Translation for quickAccessTitle
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get quickAccessTitle;

  /// Translation for communityTitle
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get communityTitle;

  /// Translation for profileTitle
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Translation for latestNewsTitle
  ///
  /// In en, this message translates to:
  /// **'Latest news'**
  String get latestNewsTitle;

  /// Translation for sourceLabel
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// Translation for quizzesTitle
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesTitle;

  /// Translation for urlCannotBeEmpty
  ///
  /// In en, this message translates to:
  /// **'URL cannot be empty'**
  String get urlCannotBeEmpty;

  /// No description provided for @errorLoadingNews.
  ///
  /// In en, this message translates to:
  /// **'Error loading news: {error}'**
  String errorLoadingNews(String error);

  /// Translation for noNewsAvailable
  ///
  /// In en, this message translates to:
  /// **'No news available at the moment.'**
  String get noNewsAvailable;

  /// Translation for adminPanelTitle
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminPanelTitle;

  /// Translation for manageNewsTitle
  ///
  /// In en, this message translates to:
  /// **'Manage news'**
  String get manageNewsTitle;

  /// Translation for manageNewsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or delete news articles'**
  String get manageNewsSubtitle;

  /// Translation for manageUsersTitle
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get manageUsersTitle;

  /// Translation for manageUsersSubtitle
  ///
  /// In en, this message translates to:
  /// **'View users and manage roles (future)'**
  String get manageUsersSubtitle;

  /// Translation for manageResourcesTitle
  ///
  /// In en, this message translates to:
  /// **'Manage guides'**
  String get manageResourcesTitle;

  /// Translation for manageResourcesSubtitle
  ///
  /// In en, this message translates to:
  /// **'Oversee all learning resources (future)'**
  String get manageResourcesSubtitle;

  /// Translation for confirmDeleteTitle
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteNewsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{newsTitle}\"?'**
  String confirmDeleteNewsMessage(String newsTitle);

  /// No description provided for @newsDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{newsTitle}\" deleted successfully.'**
  String newsDeletedSuccess(String newsTitle);

  /// Error message when deleting news fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete \"{newsTitle}\": {error}'**
  String failedToDeleteNews(String error, String newsTitle);

  /// Translation for faqTitle
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// Translation for searchHelp
  ///
  /// In en, this message translates to:
  /// **'Search help...'**
  String get searchHelp;

  /// Translation for allCategories
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// Translation for helpfulFeedback
  ///
  /// In en, this message translates to:
  /// **'Was this helpful?'**
  String get helpfulFeedback;

  /// Translation for noArticlesFound
  ///
  /// In en, this message translates to:
  /// **'No fAQs found'**
  String get noArticlesFound;

  /// Translation for settingsNotifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Translation for changePasswordTitle
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// Translation for helpCenterTitle
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenterTitle;

  /// Translation for settingsAbout
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get settingsAbout;

  /// Translation for passwordUpdatedSuccess
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccess;

  /// Translation for errorWrongPassword
  ///
  /// In en, this message translates to:
  /// **'Incorrect current password'**
  String get errorWrongPassword;

  /// Translation for currentPassword
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// Translation for newPassword
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// Translation for confirmPassword
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Translation for passwordMismatch
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// Translation for save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Translation for addNewsTooltip
  ///
  /// In en, this message translates to:
  /// **'Add new news article'**
  String get addNewsTooltip;

  /// Translation for editNewsTooltip
  ///
  /// In en, this message translates to:
  /// **'Edit news'**
  String get editNewsTooltip;

  /// Translation for deleteNewsTooltip
  ///
  /// In en, this message translates to:
  /// **'Delete news'**
  String get deleteNewsTooltip;

  /// Translation for addNewsButton
  ///
  /// In en, this message translates to:
  /// **'Add news'**
  String get addNewsButton;

  /// Translation for noNewsAvailableManager
  ///
  /// In en, this message translates to:
  /// **'No news articles found. add one!'**
  String get noNewsAvailableManager;

  /// Translation for editNewsTitle
  ///
  /// In en, this message translates to:
  /// **'Edit news'**
  String get editNewsTitle;

  /// Translation for addNewsTitle
  ///
  /// In en, this message translates to:
  /// **'Add news article'**
  String get addNewsTitle;

  /// Translation for saveNewsTooltip
  ///
  /// In en, this message translates to:
  /// **'Save news'**
  String get saveNewsTooltip;

  /// Translation for newsTitleLabel
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get newsTitleLabel;

  /// Translation for pleaseEnterNewsTitle
  ///
  /// In en, this message translates to:
  /// **'Please enter a news title.'**
  String get pleaseEnterNewsTitle;

  /// No description provided for @newsTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'News title must be at least {length} characters.'**
  String newsTitleMinLength(int length);

  /// Translation for newsSourceLabel
  ///
  /// In en, this message translates to:
  /// **'Source (e.g., blog name)'**
  String get newsSourceLabel;

  /// Translation for pleaseEnterNewsSource
  ///
  /// In en, this message translates to:
  /// **'Please enter the news source.'**
  String get pleaseEnterNewsSource;

  /// Translation for newsUrlLabel
  ///
  /// In en, this message translates to:
  /// **'Article URL'**
  String get newsUrlLabel;

  /// Translation for pleaseEnterNewsUrl
  ///
  /// In en, this message translates to:
  /// **'Please enter the article uRL.'**
  String get pleaseEnterNewsUrl;

  /// Translation for pleaseEnterValidNewsUrl
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL (starting with http or https).'**
  String get pleaseEnterValidNewsUrl;

  /// Translation for newsImageUrlLabel
  ///
  /// In en, this message translates to:
  /// **'Image URL (Optional)'**
  String get newsImageUrlLabel;

  /// Translation for pleaseEnterValidImageUrl
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid image URL (starting with http or https), or leave blank.'**
  String get pleaseEnterValidImageUrl;

  /// Translation for publicationDateLabel
  ///
  /// In en, this message translates to:
  /// **'Publication date'**
  String get publicationDateLabel;

  /// Translation for pleaseSelectPublicationDate
  ///
  /// In en, this message translates to:
  /// **'Please select a publication date.'**
  String get pleaseSelectPublicationDate;

  /// Translation for noDateSelected
  ///
  /// In en, this message translates to:
  /// **'No date selected'**
  String get noDateSelected;

  /// Translation for selectDateTooltip
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateTooltip;

  /// Translation for updateNewsButton
  ///
  /// In en, this message translates to:
  /// **'Update news'**
  String get updateNewsButton;

  /// Translation for addNewsButtonForm
  ///
  /// In en, this message translates to:
  /// **'Add news article'**
  String get addNewsButtonForm;

  /// No description provided for @newsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{newsTitle}\" updated successfully.'**
  String newsUpdatedSuccess(String newsTitle);

  /// No description provided for @newsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{newsTitle}\" added successfully.'**
  String newsAddedSuccess(String newsTitle);

  /// Error message when saving news fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save news: {error}'**
  String failedToSaveNews(String error);

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users: {error}'**
  String errorLoadingUsers(String error);

  /// Translation for noUsersFound
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// Translation for noEmailProvided
  ///
  /// In en, this message translates to:
  /// **'No email provided'**
  String get noEmailProvided;

  /// Translation for roleLabel
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// Translation for registeredOnLabel
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredOnLabel;

  /// Translation for manageUsersSubtitleNow
  ///
  /// In en, this message translates to:
  /// **'View and search registered users'**
  String get manageUsersSubtitleNow;

  /// Translation for manageResourcesSubtitleNow
  ///
  /// In en, this message translates to:
  /// **'View, edit, or delete any learning resource'**
  String get manageResourcesSubtitleNow;

  /// No description provided for @confirmDeleteResourceMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete resource \"{resourceTitle}\"?'**
  String confirmDeleteResourceMessage(String resourceTitle);

  /// Error message when deleting resource fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete resource \"{resourceTitle}\": {error}'**
  String failedToDeleteResource(String error, String resourceTitle);

  /// No description provided for @errorLoadingResources.
  ///
  /// In en, this message translates to:
  /// **'Error loading resources: {error}'**
  String errorLoadingResources(String error);

  /// Translation for noResourcesFoundManager
  ///
  /// In en, this message translates to:
  /// **'No resources found in the system.'**
  String get noResourcesFoundManager;

  /// Translation for editResourceTooltip
  ///
  /// In en, this message translates to:
  /// **'Edit resource'**
  String get editResourceTooltip;

  /// Translation for deleteResourceTooltip
  ///
  /// In en, this message translates to:
  /// **'Delete resource'**
  String get deleteResourceTooltip;

  /// Translation for manageQuizzesTitle
  ///
  /// In en, this message translates to:
  /// **'Manage quizzes'**
  String get manageQuizzesTitle;

  /// Translation for addQuizTooltip
  ///
  /// In en, this message translates to:
  /// **'Add new quiz'**
  String get addQuizTooltip;

  /// No description provided for @errorLoadingQuizzesAdmin.
  ///
  /// In en, this message translates to:
  /// **'Error loading quizzes: {error}'**
  String errorLoadingQuizzesAdmin(String error);

  /// Translation for noQuizzesFoundManager
  ///
  /// In en, this message translates to:
  /// **'No quizzes found. add one!'**
  String get noQuizzesFoundManager;

  /// No description provided for @confirmDeleteQuizMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete quiz \"{quizTitle}\" and all its questions? this action cannot be undone.'**
  String confirmDeleteQuizMessage(String quizTitle);

  /// No description provided for @quizDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Quiz \"{quizTitle}\" and its questions deleted successfully.'**
  String quizDeletedSuccess(String quizTitle);

  /// Error message when deleting quiz fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete quiz \"{quizTitle}\": {error}'**
  String failedToDeleteQuiz(String error, String quizTitle);

  /// Translation for editDetailsButton
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get editDetailsButton;

  /// Translation for manageQuestionsButton
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get manageQuestionsButton;

  /// Translation for deleteQuizTooltip
  ///
  /// In en, this message translates to:
  /// **'Delete quiz and questions'**
  String get deleteQuizTooltip;

  /// Translation for addQuizButton
  ///
  /// In en, this message translates to:
  /// **'Add quiz'**
  String get addQuizButton;

  /// Translation for manageQuizzesSubtitle
  ///
  /// In en, this message translates to:
  /// **'Oversee all quizzes and their questions'**
  String get manageQuizzesSubtitle;

  /// Error message if email is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get registrationEmailError;

  /// Title for the regular staff member's dashboard section
  ///
  /// In en, this message translates to:
  /// **'My activity'**
  String get dashboardXodimTitle;

  /// Title for the expert's dashboard section
  ///
  /// In en, this message translates to:
  /// **'My contributions'**
  String get dashboardEkspertTitle;

  /// Title for the admin's dashboard section
  ///
  /// In en, this message translates to:
  /// **'System overview'**
  String get dashboardAdminTitle;

  /// A button to see all items in a list
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAllButton;

  /// Message displayed when an expert has not authored any guides yet.
  ///
  /// In en, this message translates to:
  /// **'You have not authored any guides yet.'**
  String get noGuidesAuthored;

  /// Label for the total users statistic in the admin dashboard.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminStatUsers;

  /// Label for the total guides statistic in the admin dashboard.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get adminStatGuides;

  /// Label for the total quizzes statistic in the admin dashboard.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get adminStatQuizzes;

  /// Button to go to the next level.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get nextLevel;

  /// A divider text, like 'OR', between login options.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// Button text for signing in with a Google account.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Translation for themeSystemDefault
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystemDefault;

  /// Translation for themeLight
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get themeLight;

  /// Translation for themeDark
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get themeDark;

  /// Translation for bioOptionalLabel
  ///
  /// In en, this message translates to:
  /// **'Bio (Optional)'**
  String get bioOptionalLabel;

  /// Translation for profilePictureUrlLabel
  ///
  /// In en, this message translates to:
  /// **'Profile picture URL (Optional)'**
  String get profilePictureUrlLabel;

  /// Translation for levelIntermediate
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// Translation for levelAdvanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// Translation for totalPoints
  ///
  /// In en, this message translates to:
  /// **'Total points'**
  String get totalPoints;

  /// No description provided for @pointsToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{points} XP to next level'**
  String pointsToNextLevel(int points);

  /// Translation for manageArticlesTitle
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get manageArticlesTitle;

  /// Translation for manageArticlesSubtitle
  ///
  /// In en, this message translates to:
  /// **'Manage knowledge base'**
  String get manageArticlesSubtitle;

  /// Translation for manageVideosTitle
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get manageVideosTitle;

  /// Translation for manageVideosSubtitle
  ///
  /// In en, this message translates to:
  /// **'Manage video tutorials'**
  String get manageVideosSubtitle;

  /// Translation for manageSystemsTitle
  ///
  /// In en, this message translates to:
  /// **'Systems'**
  String get manageSystemsTitle;

  /// Translation for manageSystemsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Manage systems directory'**
  String get manageSystemsSubtitle;

  /// Translation for manageFaqTitle
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get manageFaqTitle;

  /// Translation for manageFaqSubtitle
  ///
  /// In en, this message translates to:
  /// **'Manage fAQs'**
  String get manageFaqSubtitle;

  /// Translation for manageNotificationsTitle
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get manageNotificationsTitle;

  /// Translation for manageNotificationsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Send notifications'**
  String get manageNotificationsSubtitle;

  /// Translation for selectLanguage
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @topicDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{topicTitle}\" deleted successfully.'**
  String topicDeletedSuccess(String topicTitle);

  /// No description provided for @failedToDeleteTopic.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete topic: {error}'**
  String failedToDeleteTopic(String error);

  /// No description provided for @deleteTopicConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{topicTitle}\"?'**
  String deleteTopicConfirmMessage(String topicTitle);

  /// Translation for editTopicTooltip
  ///
  /// In en, this message translates to:
  /// **'Edit topic'**
  String get editTopicTooltip;

  /// Translation for deleteTopicConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Delete topic'**
  String get deleteTopicConfirmTitle;

  /// Translation for commentPlural
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentPlural;

  /// Translation for commentSingular
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentSingular;

  /// Translation for deleteTopicTooltip
  ///
  /// In en, this message translates to:
  /// **'Delete topic'**
  String get deleteTopicTooltip;

  /// Translation for faqCategoryLogin
  ///
  /// In en, this message translates to:
  /// **'Login issues'**
  String get faqCategoryLogin;

  /// Translation for faqCategoryPassword
  ///
  /// In en, this message translates to:
  /// **'Password issues'**
  String get faqCategoryPassword;

  /// Translation for faqCategoryUpload
  ///
  /// In en, this message translates to:
  /// **'File upload'**
  String get faqCategoryUpload;

  /// Translation for faqCategoryAccess
  ///
  /// In en, this message translates to:
  /// **'Access rights'**
  String get faqCategoryAccess;

  /// Translation for faqCategoryGeneral
  ///
  /// In en, this message translates to:
  /// **'General questions'**
  String get faqCategoryGeneral;

  /// Translation for faqCategoryTechnical
  ///
  /// In en, this message translates to:
  /// **'Technical issues'**
  String get faqCategoryTechnical;

  /// No description provided for @confirmDeleteArticleMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the article \"{articleTitle}\"?'**
  String confirmDeleteArticleMessage(String articleTitle);

  /// Translation for addArticleTitle
  ///
  /// In en, this message translates to:
  /// **'New article'**
  String get addArticleTitle;

  /// Translation for editArticleTitle
  ///
  /// In en, this message translates to:
  /// **'Edit article'**
  String get editArticleTitle;

  /// Translation for categoryLabel
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Translation for articleCategoryGeneral
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get articleCategoryGeneral;

  /// Translation for articleCategoryProcedure
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get articleCategoryProcedure;

  /// Translation for articleCategoryLaw
  ///
  /// In en, this message translates to:
  /// **'Legislation'**
  String get articleCategoryLaw;

  /// Translation for articleCategoryFaq
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get articleCategoryFaq;

  /// Translation for contentLabel
  ///
  /// In en, this message translates to:
  /// **'Content (Markdown)'**
  String get contentLabel;

  /// Translation for tagsLabel
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get tagsLabel;

  /// Translation for tagsHint
  ///
  /// In en, this message translates to:
  /// **'e.g. court, law, code'**
  String get tagsHint;

  /// Translation for noPdfSelected
  ///
  /// In en, this message translates to:
  /// **'No PDF file selected'**
  String get noPdfSelected;

  /// Translation for uploadPdfTooltip
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadPdfTooltip;

  /// No description provided for @currentFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Current file: {url}'**
  String currentFileLabel(String url);

  /// Translation for existingPdfFile
  ///
  /// In en, this message translates to:
  /// **'Existing PDF file'**
  String get existingPdfFile;

  /// Translation for articleSavedSuccess
  ///
  /// In en, this message translates to:
  /// **'Article saved'**
  String get articleSavedSuccess;

  /// Translation for titleRequired
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// Translation for contentRequired
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get contentRequired;

  /// No description provided for @confirmDeleteVideoMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the video \"{videoTitle}\"?'**
  String confirmDeleteVideoMessage(String videoTitle);

  /// Translation for videoDeletedSuccess
  ///
  /// In en, this message translates to:
  /// **'Video deleted'**
  String get videoDeletedSuccess;

  /// Translation for noVideosFound
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideosFound;

  /// Translation for addVideoTitle
  ///
  /// In en, this message translates to:
  /// **'New video'**
  String get addVideoTitle;

  /// Translation for editVideoTitle
  ///
  /// In en, this message translates to:
  /// **'Edit video'**
  String get editVideoTitle;

  /// Translation for videoSavedSuccess
  ///
  /// In en, this message translates to:
  /// **'Video saved'**
  String get videoSavedSuccess;

  /// Translation for youtubeIdLabel
  ///
  /// In en, this message translates to:
  /// **'YouTube ID'**
  String get youtubeIdLabel;

  /// Translation for youtubeIdHint
  ///
  /// In en, this message translates to:
  /// **'e.g. dQw4w9WgXcQ'**
  String get youtubeIdHint;

  /// Translation for youtubeIdRequired
  ///
  /// In en, this message translates to:
  /// **'YouTube ID is required'**
  String get youtubeIdRequired;

  /// Translation for systemOptionalLabel
  ///
  /// In en, this message translates to:
  /// **'System (Optional)'**
  String get systemOptionalLabel;

  /// Translation for notSelectedLabel
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelectedLabel;

  /// Translation for durationLabel
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get durationLabel;

  /// Translation for durationHint
  ///
  /// In en, this message translates to:
  /// **'e.g. 600'**
  String get durationHint;

  /// Translation for durationRequired
  ///
  /// In en, this message translates to:
  /// **'Duration is required'**
  String get durationRequired;

  /// Translation for videoTagsHint
  ///
  /// In en, this message translates to:
  /// **'e.g. login, error, settings'**
  String get videoTagsHint;

  /// Translation for descriptionRequired
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @confirmDeleteSystemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the system \"{systemName}\"?'**
  String confirmDeleteSystemMessage(String systemName);

  /// Translation for systemDeletedSuccess
  ///
  /// In en, this message translates to:
  /// **'System deleted'**
  String get systemDeletedSuccess;

  /// Translation for noSystemsFound
  ///
  /// In en, this message translates to:
  /// **'No systems found'**
  String get noSystemsFound;

  /// Translation for addSystemTitle
  ///
  /// In en, this message translates to:
  /// **'New system'**
  String get addSystemTitle;

  /// Translation for editSystemTitle
  ///
  /// In en, this message translates to:
  /// **'Edit system'**
  String get editSystemTitle;

  /// Translation for systemSavedSuccess
  ///
  /// In en, this message translates to:
  /// **'System saved'**
  String get systemSavedSuccess;

  /// Translation for shortNameLabel
  ///
  /// In en, this message translates to:
  /// **'Short name'**
  String get shortNameLabel;

  /// Translation for shortNameHint
  ///
  /// In en, this message translates to:
  /// **'e.g. e-SUD'**
  String get shortNameHint;

  /// Translation for nameRequired
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Translation for fullNameLabel
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// Translation for fullNameRequired
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// Translation for websiteUrlLabel
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get websiteUrlLabel;

  /// Translation for urlRequired
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get urlRequired;

  /// Translation for logoUrlLabel
  ///
  /// In en, this message translates to:
  /// **'Logo URL'**
  String get logoUrlLabel;

  /// Translation for logoUrlRequired
  ///
  /// In en, this message translates to:
  /// **'Logo URL is required'**
  String get logoUrlRequired;

  /// Translation for statusLabel
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// Translation for loginGuideIdLabel
  ///
  /// In en, this message translates to:
  /// **'Login guide ID (Optional)'**
  String get loginGuideIdLabel;

  /// Translation for videoGuideIdLabel
  ///
  /// In en, this message translates to:
  /// **'Video guide ID (Optional)'**
  String get videoGuideIdLabel;

  /// No description provided for @confirmDeleteFaqMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the question \"{question}\"?'**
  String confirmDeleteFaqMessage(String question);

  /// Translation for faqDeletedSuccess
  ///
  /// In en, this message translates to:
  /// **'Question deleted'**
  String get faqDeletedSuccess;

  /// Translation for noFaqsFound
  ///
  /// In en, this message translates to:
  /// **'No questions found'**
  String get noFaqsFound;

  /// Translation for addFaqTitle
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get addFaqTitle;

  /// Translation for editFaqTitle
  ///
  /// In en, this message translates to:
  /// **'Edit question'**
  String get editFaqTitle;

  /// Translation for faqSavedSuccess
  ///
  /// In en, this message translates to:
  /// **'Question saved'**
  String get faqSavedSuccess;

  /// Translation for questionLabel
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// Translation for questionRequired
  ///
  /// In en, this message translates to:
  /// **'Question is required'**
  String get questionRequired;

  /// Translation for answerLabel
  ///
  /// In en, this message translates to:
  /// **'Answer (Markdown)'**
  String get answerLabel;

  /// Translation for answerRequired
  ///
  /// In en, this message translates to:
  /// **'Answer is required'**
  String get answerRequired;

  /// Translation for add
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Translation for titleLabel
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// Translation for edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Translation for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Translation for cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Translation for search
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Translation for fieldRequired
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get fieldRequired;

  /// Translation for confirmDelete
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// Translation for successSaved
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get successSaved;

  /// Translation for successDeleted
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get successDeleted;

  /// Translation for notificationManagementTitle
  ///
  /// In en, this message translates to:
  /// **'Notification management'**
  String get notificationManagementTitle;

  /// Translation for notificationHistoryTitle
  ///
  /// In en, this message translates to:
  /// **'Notification history'**
  String get notificationHistoryTitle;

  /// Translation for notificationHistoryPlaceholder
  ///
  /// In en, this message translates to:
  /// **'History of sent notifications will appear here (coming soon).'**
  String get notificationHistoryPlaceholder;

  /// Translation for sendNewNotificationButton
  ///
  /// In en, this message translates to:
  /// **'Send new notification'**
  String get sendNewNotificationButton;

  /// Translation for sendNotificationTitle
  ///
  /// In en, this message translates to:
  /// **'Send notification'**
  String get sendNotificationTitle;

  /// Translation for notificationSentSuccess
  ///
  /// In en, this message translates to:
  /// **'Notification sent'**
  String get notificationSentSuccess;

  /// Translation for notificationTitleLabel
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notificationTitleLabel;

  /// Translation for notificationTitleRequired
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get notificationTitleRequired;

  /// Translation for notificationBodyLabel
  ///
  /// In en, this message translates to:
  /// **'Message body'**
  String get notificationBodyLabel;

  /// Translation for notificationBodyRequired
  ///
  /// In en, this message translates to:
  /// **'Message body is required'**
  String get notificationBodyRequired;

  /// Translation for notificationTypeLabel
  ///
  /// In en, this message translates to:
  /// **'Notification type'**
  String get notificationTypeLabel;

  /// Translation for targetAudienceLabel
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get targetAudienceLabel;

  /// Notification type: update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get notificationTypeUpdate;

  /// Notification type: new content
  ///
  /// In en, this message translates to:
  /// **'New content'**
  String get notificationTypeNewContent;

  /// Notification type: announcement
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get notificationTypeAnnouncement;

  /// Notification type: reminder
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get notificationTypeReminder;

  /// Notification type: system
  ///
  /// In en, this message translates to:
  /// **'System message'**
  String get notificationTypeSystem;

  /// Target audience: all
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get targetAudienceAll;

  /// Target audience: beginner
  ///
  /// In en, this message translates to:
  /// **'New staff'**
  String get targetAudienceBeginner;

  /// Target audience: AKT
  ///
  /// In en, this message translates to:
  /// **'ICT staff'**
  String get targetAudienceAkt;

  /// Target audience: specific
  ///
  /// In en, this message translates to:
  /// **'Specific users'**
  String get targetAudienceSpecific;

  /// Label for target audience in history
  ///
  /// In en, this message translates to:
  /// **'To: {audience}'**
  String notificationLabelTo(String audience);

  /// Label for read count in history
  ///
  /// In en, this message translates to:
  /// **'Read: {count}'**
  String notificationLabelReadBy(int count);

  /// Translation for resourceTabArticles
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get resourceTabArticles;

  /// Translation for resourceTabVideos
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get resourceTabVideos;

  /// Translation for resourceTabFiles
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get resourceTabFiles;

  /// Translation for filesTabTitle
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesTabTitle;

  /// Translation for systemsDirectoryTitle
  ///
  /// In en, this message translates to:
  /// **'Court information systems'**
  String get systemsDirectoryTitle;

  /// Translation for bookmarkSaveTooltip
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmarkSaveTooltip;

  /// Translation for bookmarkRemoveTooltip
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get bookmarkRemoveTooltip;

  /// Translation for resourceTypeOther
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get resourceTypeOther;

  /// Translation for openFile
  ///
  /// In en, this message translates to:
  /// **'Open file'**
  String get openFile;

  /// Translation for fileSize
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get fileSize;

  /// Translation for selectFile
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// Translation for upload
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// Translation for processing
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Translation for urlLabel
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// Translation for resourceTypePDF
  ///
  /// In en, this message translates to:
  /// **'PDF manual'**
  String get resourceTypePDF;

  /// Translation for resourceTypeVideo
  ///
  /// In en, this message translates to:
  /// **'Video tutorial'**
  String get resourceTypeVideo;

  /// Translation for resourceTypeLink
  ///
  /// In en, this message translates to:
  /// **'Web link'**
  String get resourceTypeLink;

  /// Translation for onlySaved
  ///
  /// In en, this message translates to:
  /// **'Only saved'**
  String get onlySaved;

  /// Translation for searchArticlesPlaceholder
  ///
  /// In en, this message translates to:
  /// **'Search articles...'**
  String get searchArticlesPlaceholder;

  /// Translation for filterAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Translation for noResultsFound
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Translation for noArticlesAvailable
  ///
  /// In en, this message translates to:
  /// **'No articles available'**
  String get noArticlesAvailable;

  /// Translation for noVideosAvailable
  ///
  /// In en, this message translates to:
  /// **'No videos available'**
  String get noVideosAvailable;

  /// Translation for actionCreateDiscussion
  ///
  /// In en, this message translates to:
  /// **'Create discussion'**
  String get actionCreateDiscussion;

  /// Translation for actionCreateResource
  ///
  /// In en, this message translates to:
  /// **'Create resource'**
  String get actionCreateResource;

  /// Translation for actionCreateQuiz
  ///
  /// In en, this message translates to:
  /// **'Create quiz'**
  String get actionCreateQuiz;

  /// Translation for notificationsTitle
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// Translation for loginRequired
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// Translation for markAllAsReadTooltip
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsReadTooltip;

  /// Translation for allNotificationsReadMessage
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsReadMessage;

  /// Translation for noNotifications
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// Translation for closeAction
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// Translation for leaderboardTitle
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// No description provided for @pointsEarned.
  ///
  /// In en, this message translates to:
  /// **'You earned {points} XP!'**
  String pointsEarned(int points);

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! new level: {level}'**
  String levelUp(int level);

  /// Translation for rank
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// Translation for quizHistoryTitle
  ///
  /// In en, this message translates to:
  /// **'Quiz history'**
  String get quizHistoryTitle;

  /// Translation for seeAll
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Translation for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Translation for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Translation for thisWeek
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// Translation for older
  ///
  /// In en, this message translates to:
  /// **'Older results'**
  String get older;

  /// Translation for contactSupport
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// Translation for landingTitle
  ///
  /// In en, this message translates to:
  /// **'Professional platform'**
  String get landingTitle;

  /// Translation for landingSubtitle
  ///
  /// In en, this message translates to:
  /// **'Elevate your legal knowledge. anytime. anywhere.'**
  String get landingSubtitle;

  /// Translation for landingLogin
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get landingLogin;

  /// Translation for landingRegister
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get landingRegister;

  /// Translation for featureKnowledgeBase
  ///
  /// In en, this message translates to:
  /// **'Knowledge base'**
  String get featureKnowledgeBase;

  /// Translation for featureKnowledgeBaseDesc
  ///
  /// In en, this message translates to:
  /// **'Access a vast library of legal resources and documents.'**
  String get featureKnowledgeBaseDesc;

  /// Translation for featureVideoTutorials
  ///
  /// In en, this message translates to:
  /// **'Video tutorials'**
  String get featureVideoTutorials;

  /// Translation for featureVideoTutorialsDesc
  ///
  /// In en, this message translates to:
  /// **'Learn from expert-led video guides and webinars.'**
  String get featureVideoTutorialsDesc;

  /// Translation for featureGamification
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get featureGamification;

  /// Translation for featureGamificationDesc
  ///
  /// In en, this message translates to:
  /// **'Earn XP, badges, and compete on the leaderboard.'**
  String get featureGamificationDesc;

  /// Translation for analyticsTitle
  ///
  /// In en, this message translates to:
  /// **'Learning analytics (xAPI)'**
  String get analyticsTitle;

  /// Translation for analyticsSubtitle
  ///
  /// In en, this message translates to:
  /// **'Learning records'**
  String get analyticsSubtitle;

  /// Translation for totalRecords
  ///
  /// In en, this message translates to:
  /// **'Total records'**
  String get totalRecords;

  /// Translation for realTime
  ///
  /// In en, this message translates to:
  /// **'Real-time'**
  String get realTime;

  /// Translation for activityDistribution
  ///
  /// In en, this message translates to:
  /// **'Activity distribution'**
  String get activityDistribution;

  /// Translation for recentActivityFeed
  ///
  /// In en, this message translates to:
  /// **'Recent activity feed'**
  String get recentActivityFeed;

  /// Translation for noRecords
  ///
  /// In en, this message translates to:
  /// **'No learning records found yet.'**
  String get noRecords;

  /// Translation for unknownUser
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get unknownUser;

  /// Translation for unknownObject
  ///
  /// In en, this message translates to:
  /// **'Unknown object'**
  String get unknownObject;

  /// Translation for justNow
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Translation for quizzes
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// Translation for simulations
  ///
  /// In en, this message translates to:
  /// **'Simulations'**
  String get simulations;

  /// Translation for catNewEmployees
  ///
  /// In en, this message translates to:
  /// **'New employees'**
  String get catNewEmployees;

  /// Translation for catIctSpecialists
  ///
  /// In en, this message translates to:
  /// **'ICT specialists'**
  String get catIctSpecialists;

  /// Translation for catSystems
  ///
  /// In en, this message translates to:
  /// **'Systems'**
  String get catSystems;

  /// Translation for catAuth
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get catAuth;

  /// Translation for catGeneral
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get catGeneral;

  /// Translation for rankBeginner
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get rankBeginner;

  /// Translation for rankIntermediate
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get rankIntermediate;

  /// Translation for rankAdvanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get rankAdvanced;

  /// Translation for sysCatPrimary
  ///
  /// In en, this message translates to:
  /// **'Primary systems'**
  String get sysCatPrimary;

  /// Translation for sysCatSecondary
  ///
  /// In en, this message translates to:
  /// **'Secondary systems'**
  String get sysCatSecondary;

  /// Translation for sysCatSupport
  ///
  /// In en, this message translates to:
  /// **'Support systems'**
  String get sysCatSupport;

  /// Translation for sysStatusActive
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get sysStatusActive;

  /// Translation for sysStatusMaintenance
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get sysStatusMaintenance;

  /// Translation for sysStatusInactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get sysStatusInactive;

  /// No description provided for @videoViews.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String videoViews(int count);

  /// Translation for videoAuthorSubtitle
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get videoAuthorSubtitle;

  /// Translation for videoDescriptionTitle
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get videoDescriptionTitle;

  /// Translation for sysStatusDeprecated
  ///
  /// In en, this message translates to:
  /// **'Deprecated'**
  String get sysStatusDeprecated;

  /// Translation for sysStatusOffline
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get sysStatusOffline;

  /// Translation for systemsDirectoryAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get systemsDirectoryAll;

  /// No description provided for @systemsDirectoryError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String systemsDirectoryError(String error);

  /// Translation for systemsDirectoryEmpty
  ///
  /// In en, this message translates to:
  /// **'No systems available'**
  String get systemsDirectoryEmpty;

  /// Translation for backToKnowledgeBase
  ///
  /// In en, this message translates to:
  /// **'Back to guides'**
  String get backToKnowledgeBase;

  /// Translation for quizSuccessMessage
  ///
  /// In en, this message translates to:
  /// **'Great result!'**
  String get quizSuccessMessage;

  /// Translation for quizFailureMessage
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get quizFailureMessage;

  /// Translation for failedToLoadQuiz
  ///
  /// In en, this message translates to:
  /// **'Failed to load quiz'**
  String get failedToLoadQuiz;

  /// Translation for failedToSaveAttempt
  ///
  /// In en, this message translates to:
  /// **'Failed to save attempt'**
  String get failedToSaveAttempt;

  /// Translation for quizNotFound
  ///
  /// In en, this message translates to:
  /// **'Quiz not found'**
  String get quizNotFound;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question {index}'**
  String question(String index);

  /// Translation for speedBonus
  ///
  /// In en, this message translates to:
  /// **'Speed bonus'**
  String get speedBonus;

  /// Translation for levelBeginner
  ///
  /// In en, this message translates to:
  /// **'Newbie'**
  String get levelBeginner;

  /// Translation for levelSpecialist
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get levelSpecialist;

  /// Translation for levelExpert
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get levelExpert;

  /// Translation for levelMaster
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get levelMaster;

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String totalQuestions(String total);

  /// Translation for errorCouldNotOpenLink
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get errorCouldNotOpenLink;

  /// Translation for errorResourceNotFound
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get errorResourceNotFound;

  /// Translation for errorVideoNotFound
  ///
  /// In en, this message translates to:
  /// **'Video not found'**
  String get errorVideoNotFound;

  /// Translation for errorPdfOpen
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF file'**
  String get errorPdfOpen;

  /// Translation for errorTelegramOpen
  ///
  /// In en, this message translates to:
  /// **'Could not open telegram link'**
  String get errorTelegramOpen;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorGeneric(String error);

  /// Translation for labelTrue
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get labelTrue;

  /// Translation for labelFalse
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get labelFalse;

  /// Translation for labelPass
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get labelPass;

  /// Translation for labelFail
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get labelFail;

  /// Translation for labelPdfAvailable
  ///
  /// In en, this message translates to:
  /// **'PDF available'**
  String get labelPdfAvailable;

  /// Translation for actionOk
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// Translation for actionGoBack
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get actionGoBack;

  /// Translation for searchNoResults
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// No description provided for @roleChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{userName}\'s role changed to {role}'**
  String roleChangedSuccess(String userName, String role);

  /// No description provided for @roleChangeError.
  ///
  /// In en, this message translates to:
  /// **'Error changing role: {error}'**
  String roleChangeError(String error);

  /// Translation for changeRoleTooltip
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get changeRoleTooltip;

  /// Translation for labelVideoGuide
  ///
  /// In en, this message translates to:
  /// **'Video guide'**
  String get labelVideoGuide;

  /// Translation for labelLoginGuide
  ///
  /// In en, this message translates to:
  /// **'Login guide'**
  String get labelLoginGuide;

  /// Translation for changePasswordHint
  ///
  /// In en, this message translates to:
  /// **'Change password implementation here'**
  String get changePasswordHint;

  /// Translation for editTopic
  ///
  /// In en, this message translates to:
  /// **'Edit topic'**
  String get editTopic;

  /// Translation for update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Translation for commentAdded
  ///
  /// In en, this message translates to:
  /// **'Comment added!'**
  String get commentAdded;

  /// Translation for updateFeatureMigration
  ///
  /// In en, this message translates to:
  /// **'Update feature is under migration. coming soon!'**
  String get updateFeatureMigration;

  /// Translation for topicUpdatedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Topic updated successfully'**
  String get topicUpdatedSuccessfully;

  /// No description provided for @errorDeletingTopicMsg.
  ///
  /// In en, this message translates to:
  /// **'Error deleting topic: {error}'**
  String errorDeletingTopicMsg(String error);

  /// Translation for takeQuizTitle
  ///
  /// In en, this message translates to:
  /// **'Take quiz'**
  String get takeQuizTitle;

  /// Translation for quizTakingInterface
  ///
  /// In en, this message translates to:
  /// **'Quiz taking interface (Coming soon)'**
  String get quizTakingInterface;

  /// Translation for quizCreatedSuccessfully
  ///
  /// In en, this message translates to:
  /// **'Quiz created successfully'**
  String get quizCreatedSuccessfully;

  /// Translation for saveQuizAction
  ///
  /// In en, this message translates to:
  /// **'Save quiz'**
  String get saveQuizAction;

  /// Translation for createQuizTitle
  ///
  /// In en, this message translates to:
  /// **'Create quiz'**
  String get createQuizTitle;

  /// No description provided for @editQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit questions: {title}'**
  String editQuestionsTitle(String title);

  /// Translation for questionsManagementComingSoon
  ///
  /// In en, this message translates to:
  /// **'Questions management coming soon'**
  String get questionsManagementComingSoon;

  /// Translation for aiAssistantName
  ///
  /// In en, this message translates to:
  /// **'AI assistant \"Sodiq\"'**
  String get aiAssistantName;

  /// Translation for retryAction
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// Translation for clearChatTooltip
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChatTooltip;

  /// Translation for noInternetLabel
  ///
  /// In en, this message translates to:
  /// **'No internet'**
  String get noInternetLabel;

  /// Translation for noInternetQuery
  ///
  /// In en, this message translates to:
  /// **'Internet is not working, what should i do?'**
  String get noInternetQuery;

  /// Translation for fileNotOpeningLabel
  ///
  /// In en, this message translates to:
  /// **'File won\'t open'**
  String get fileNotOpeningLabel;

  /// Translation for fileNotOpeningQuery
  ///
  /// In en, this message translates to:
  /// **'PDF file won\'t open, help me.'**
  String get fileNotOpeningQuery;

  /// Translation for printerNotWorkingLabel
  ///
  /// In en, this message translates to:
  /// **'Printer not working'**
  String get printerNotWorkingLabel;

  /// Translation for printerNotWorkingQuery
  ///
  /// In en, this message translates to:
  /// **'Printer is not printing, what should i do?'**
  String get printerNotWorkingQuery;

  /// Translation for uploadImageTooltip
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImageTooltip;

  /// Translation for writeMessageHint
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get writeMessageHint;

  /// Translation for aiMentorName
  ///
  /// In en, this message translates to:
  /// **'Sodiq (AI mentor)'**
  String get aiMentorName;

  /// Translation for True option in quizzes
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueOption;

  /// Translation for False option in quizzes
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseOption;

  /// Tab label for questions list
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questionsListTab;

  /// Tab label for adding a question
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get addQuestionTab;

  /// Button label for adding an option
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get addOptionButton;

  /// Confirmation dialog for deleting a question
  ///
  /// In en, this message translates to:
  /// **'Delete this question?'**
  String get deleteQuestionConfirm;

  /// Snackbar message after deleting a question
  ///
  /// In en, this message translates to:
  /// **'Question deleted'**
  String get questionDeleted;

  /// Button label to start a quiz
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
  String get startQuiz;

  /// Button label to go to next question
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextQuestion;

  /// Button label to go to previous question
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousQuestion;

  /// Button label to submit quiz answers
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitQuiz;

  /// Title for quiz results page
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get quizResults;

  /// Label for the score display
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get yourScore;

  /// Progress indicator for quiz questions
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionOfTotal(int current, int total);

  /// Prompt to select an answer
  ///
  /// In en, this message translates to:
  /// **'Please select an answer'**
  String get selectAnAnswer;

  /// Shows the correct answer
  ///
  /// In en, this message translates to:
  /// **'Correct answer: {answer}'**
  String correctAnswerIs(String answer);

  /// Button to retake a quiz
  ///
  /// In en, this message translates to:
  /// **'Retake quiz'**
  String get retakeQuiz;

  /// Button to go back to quiz list
  ///
  /// In en, this message translates to:
  /// **'Back to quizzes'**
  String get backToQuizList;

  /// Number of questions in a quiz
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String questionsCount(int count);

  /// Message for high quiz score
  ///
  /// In en, this message translates to:
  /// **'Excellent! 🎉'**
  String get excellentScore;

  /// Message for decent quiz score
  ///
  /// In en, this message translates to:
  /// **'Good job! 👍'**
  String get goodScore;

  /// Message for low quiz score
  ///
  /// In en, this message translates to:
  /// **'Keep practicing! 💪'**
  String get needsImprovement;

  /// Message when quiz has no questions
  ///
  /// In en, this message translates to:
  /// **'This quiz has no questions yet.'**
  String get noQuestionsInQuiz;

  /// Button text to resume learning on dashboard
  ///
  /// In en, this message translates to:
  /// **'Resume learning'**
  String get resumeLearning;

  /// Section title for recent activity on dashboard
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// Metric card title for available resources
  ///
  /// In en, this message translates to:
  /// **'Available resources'**
  String get availableResources;

  /// Metric card title for available quizzes
  ///
  /// In en, this message translates to:
  /// **'Available quizzes'**
  String get availableQuizzes;

  /// Metric card title for active discussions
  ///
  /// In en, this message translates to:
  /// **'Active discussions'**
  String get activeDiscussions;

  /// Section title for recommended resources
  ///
  /// In en, this message translates to:
  /// **'Recommended resources'**
  String get recommendedResources;

  /// Breadcrumb path text
  ///
  /// In en, this message translates to:
  /// **'Pages / dashboard'**
  String get pagesPath;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Main dashboard'**
  String get mainDashboard;

  /// Overview label on welcome banner
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Empty state for recent activity
  ///
  /// In en, this message translates to:
  /// **'No recent activities.'**
  String get noRecentActivities;

  /// Message when user is not signed in
  ///
  /// In en, this message translates to:
  /// **'Sign in to see activities.'**
  String get signInToSeeActivities;

  /// Empty state for resources
  ///
  /// In en, this message translates to:
  /// **'No resources available.'**
  String get noResourcesAvailable;

  /// No description provided for @quizCompletedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Quiz completed: {quizId}'**
  String quizCompletedPrefix(String quizId);

  /// Button to load older notifications
  ///
  /// In en, this message translates to:
  /// **'Load older notifications'**
  String get loadOlderNotifications;

  /// Filter for all search results
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchFilterAll;

  /// Filter for systems
  ///
  /// In en, this message translates to:
  /// **'Systems'**
  String get searchFilterSystems;

  /// Filter for articles
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get searchFilterArticles;

  /// Filter for videos
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get searchFilterVideos;

  /// Filter for FAQ
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get searchFilterFAQ;

  /// Filter for Courses
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get searchFilterCourses;

  /// Error title in search
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get searchErrorTitle;

  /// No results found for specific query
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String searchNoResultsForQuery(String query);

  /// Header for direct search results
  ///
  /// In en, this message translates to:
  /// **'🔍 results ({count})'**
  String searchResultsHeader(int count);

  /// Header for semantic search results
  ///
  /// In en, this message translates to:
  /// **'📎 related materials ({count})'**
  String searchSemanticHeader(int count);

  /// Badge for semantic search result
  ///
  /// In en, this message translates to:
  /// **'📎 related'**
  String get searchSemanticBadge;

  /// Title for empty search prompt
  ///
  /// In en, this message translates to:
  /// **'Unified search'**
  String get searchEmptyPromptTitle;

  /// Description for empty search prompt
  ///
  /// In en, this message translates to:
  /// **'Systems, articles, videos, courses, and\nFAQ — find everything in one place'**
  String get searchEmptyPromptDesc;

  /// System type label
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get searchTypeSystem;

  /// Article type label
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get searchTypeArticle;

  /// Video type label
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get searchTypeVideo;

  /// FAQ type label
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get searchTypeFaq;

  /// Resource type label
  ///
  /// In en, this message translates to:
  /// **'Resource'**
  String get searchTypeResource;

  /// Course type label in search results
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get searchTypeCourse;

  /// Global tab in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get leaderboardTabGlobal;

  /// Region tab in leaderboard
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get leaderboardTabRegion;

  /// Court tab in leaderboard
  ///
  /// In en, this message translates to:
  /// **'My court'**
  String get leaderboardTabCourt;

  /// Displayed when region info is missing
  ///
  /// In en, this message translates to:
  /// **'No region data'**
  String get noRegionInfo;

  /// Displayed when court info is missing
  ///
  /// In en, this message translates to:
  /// **'No court data'**
  String get noCourtInfo;

  /// Title for court selection modal
  ///
  /// In en, this message translates to:
  /// **'Select your court'**
  String get selectYourCourtTitle;

  /// Subtitle for court selection modal
  ///
  /// In en, this message translates to:
  /// **'Specify the court you work in\nfor regional statistics and leaderboards'**
  String get selectYourCourtSubtitle;

  /// Label for region selection
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegionLabel;

  /// Dropdown label for region
  ///
  /// In en, this message translates to:
  /// **'📍 region / province'**
  String get regionDropdownLabel;

  /// Label for court type selection
  ///
  /// In en, this message translates to:
  /// **'Select court type'**
  String get selectCourtTypeLabel;

  /// Dropdown label for court type
  ///
  /// In en, this message translates to:
  /// **'⚖️ court type'**
  String get courtTypeDropdownLabel;

  /// Hint when region is not selected
  ///
  /// In en, this message translates to:
  /// **'First select a region'**
  String get selectRegionFirst;

  /// Label for specific court selection
  ///
  /// In en, this message translates to:
  /// **'Select specific court'**
  String get selectSpecificCourtLabel;

  /// Dropdown label for specific court
  ///
  /// In en, this message translates to:
  /// **'🏛️ specific court'**
  String get specificCourtDropdownLabel;

  /// Hint when court type is not selected
  ///
  /// In en, this message translates to:
  /// **'First select a court type'**
  String get selectCourtTypeFirst;

  /// Save and continue button text
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// Saving text
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get savingInProgress;

  /// Header for court data section in registration
  ///
  /// In en, this message translates to:
  /// **'Court data'**
  String get courtDataHeader;

  /// Title for article details screen
  ///
  /// In en, this message translates to:
  /// **'Article details'**
  String get articleDetailTitle;

  /// Label for pinned articles
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get articlePinned;

  /// Label for knowledge base tab
  ///
  /// In en, this message translates to:
  /// **'Knowledge base'**
  String get bottomNavKnowledge;

  /// Button to download PDF
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// Success message after feedback
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThanks;

  /// Button to share an article
  ///
  /// In en, this message translates to:
  /// **'Share article'**
  String get shareArticle;

  /// Label for topic
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topicTitle;

  /// Translation for myCoursesTitle
  ///
  /// In en, this message translates to:
  /// **'My courses'**
  String get myCoursesTitle;

  /// Translation for myCoursesEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started any courses yet'**
  String get myCoursesEmptyTitle;

  /// Translation for myCoursesEmptySubtitle
  ///
  /// In en, this message translates to:
  /// **'Start courses to learn new skills and earn XP.'**
  String get myCoursesEmptySubtitle;

  /// Courses screen title
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get coursesTitle;

  /// Courses screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Boost your knowledge'**
  String get boostYourKnowledge;

  /// Courses search hint
  ///
  /// In en, this message translates to:
  /// **'Search courses...'**
  String get searchCoursesHint;

  /// Course filter: all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get courseFilterAll;

  /// Course filter: beginner
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get courseFilterBeginner;

  /// Course filter: intermediate
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get courseFilterIntermediate;

  /// Course filter: advanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get courseFilterAdvanced;

  /// Empty courses message
  ///
  /// In en, this message translates to:
  /// **'No courses found'**
  String get coursesNotFound;

  /// Generic error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// Stat label: courses
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get statCourses;

  /// Stat label: completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statCompleted;

  /// Stat label: XP points
  ///
  /// In en, this message translates to:
  /// **'XP points'**
  String get statXpPoints;

  /// Tab: all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// Tab: completed
  ///
  /// In en, this message translates to:
  /// **'✓ Completed'**
  String get tabCompleted;

  /// Tab: in progress
  ///
  /// In en, this message translates to:
  /// **'▶ In Progress'**
  String get tabInProgress;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get statusOnline;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get statusOffline;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
    case 'uz': return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
