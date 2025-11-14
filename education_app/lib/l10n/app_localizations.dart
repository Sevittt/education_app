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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Court Handbook'**
  String get appTitle;

  /// Title on the login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get loginWelcomeTitle;

  /// Subtitle on the login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginWelcomeSubtitle;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavResources.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get bottomNavResources;

  /// No description provided for @bottomNavCommunity.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get bottomNavCommunity;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// Title for the resources/guides screen
  ///
  /// In en, this message translates to:
  /// **'Guides & Manuals'**
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

  /// No description provided for @registrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get registrationTitle;

  /// No description provided for @registrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the professional community!'**
  String get registrationSubtitle;

  /// Label for the full name field on registration screen
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registrationFullNameLabel;

  /// Error message if full name is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get registrationFullNameError;

  /// Label for the role selection on registration screen
  ///
  /// In en, this message translates to:
  /// **'Your Role'**
  String get registrationRoleLabel;

  /// Error message if no role is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get registrationRoleError;

  /// Option for 'xodim' (staff) role
  ///
  /// In en, this message translates to:
  /// **'Regular Staff'**
  String get registrationRoleXodim;

  /// Option for 'ekspert' (expert) role
  ///
  /// In en, this message translates to:
  /// **'Expert (Content Creator)'**
  String get registrationRoleEkspert;

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
  /// **'Confirm Password'**
  String get registrationConfirmPasswordLabel;

  /// Error message if passwords don't match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registrationConfirmPasswordError;

  /// Text for the sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registrationSignUpButton;

  /// Text to switch to login screen
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get registrationSwitchToLogin;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEnglish;

  /// No description provided for @languageUzbek.
  ///
  /// In en, this message translates to:
  /// **'Uzbek (Uzbekistan)'**
  String get languageUzbek;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian (Russia)'**
  String get languageRussian;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystemDefault;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsReceiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive Notifications'**
  String get settingsReceiveNotifications;

  /// No description provided for @settingsReceiveNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get updates about new resources and discussions'**
  String get settingsReceiveNotificationsSubtitle;

  /// No description provided for @settingsAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location Access'**
  String get settingsAllowLocation;

  /// No description provided for @settingsAllowLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For features requiring your location (if any)'**
  String get settingsAllowLocationSubtitle;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get settingsHelpCenter;

  /// No description provided for @settingsAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Court Handbook'**
  String get settingsAboutApp;

  /// No description provided for @settingsAppLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2025 Court Handbook Project'**
  String get settingsAppLegalese;

  /// No description provided for @settingsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Bridging the IT skills gap through collaborative learning and resource sharing.'**
  String get settingsAppDescription;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorPrefix;

  /// No description provided for @resourcesNoResourcesFound.
  ///
  /// In en, this message translates to:
  /// **'No resources found.'**
  String get resourcesNoResourcesFound;

  /// No description provided for @loginButtonText.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButtonText;

  /// No description provided for @signUpButtonText.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButtonText;

  /// No description provided for @logoutButtonText.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButtonText;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to logout'**
  String get logoutConfirmTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @homeDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get homeDashboardTitle;

  /// No description provided for @communityScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get communityScreenTitle;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// No description provided for @editProfileButtonText.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileButtonText;

  /// No description provided for @guestUser.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// No description provided for @updateYourInformation.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get updateYourInformation;

  /// No description provided for @loginToEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Log in to edit your profile'**
  String get loginToEditProfile;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme Options'**
  String get themeOptionsTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutButton;

  /// No description provided for @resourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get resourcesTitle;

  /// No description provided for @resourcesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search guides...'**
  String get resourcesSearchHint;

  /// No description provided for @resourcesFilterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by Type'**
  String get resourcesFilterByType;

  /// No description provided for @resourcesAllTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get resourcesAllTypes;

  /// No description provided for @resourcesNoResourcesMatch.
  ///
  /// In en, this message translates to:
  /// **'No resources match your criteria.'**
  String get resourcesNoResourcesMatch;

  /// No description provided for @resourcesTryAdjusting.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter.'**
  String get resourcesTryAdjusting;

  /// No description provided for @resourcesCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get resourcesCreateButton;

  /// No description provided for @resourceAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resource added successfully!'**
  String get resourceAddedSuccess;

  /// Error message when adding a resource fails
  ///
  /// In en, this message translates to:
  /// **'Error adding resource: {error}'**
  String resourceAddedError(String error);

  /// No description provided for @createResourceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Guide'**
  String get createResourceScreenTitle;

  /// No description provided for @createResourceFormWillBeHere.
  ///
  /// In en, this message translates to:
  /// **'Resource creation form will be here.'**
  String get createResourceFormWillBeHere;

  /// No description provided for @saveButtonText.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveButtonText;

  /// No description provided for @createResourceTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get createResourceTitleLabel;

  /// No description provided for @createResourceDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createResourceDescriptionLabel;

  /// No description provided for @createResourceAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get createResourceAuthorLabel;

  /// No description provided for @createResourceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'System Type'**
  String get createResourceTypeLabel;

  /// No description provided for @createResourceUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL (Optional)'**
  String get createResourceUrlLabel;

  /// No description provided for @couldNotLaunchUrl.
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(Object url);

  /// No description provided for @createResourceValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a {fieldName}'**
  String createResourceValidationEmpty(Object fieldName);

  /// No description provided for @createResourceValidationSelect.
  ///
  /// In en, this message translates to:
  /// **'Please select a {fieldName}'**
  String createResourceValidationSelect(Object fieldName);

  /// No description provided for @createResourceValidationInvalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get createResourceValidationInvalidUrl;

  /// No description provided for @editButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Resource'**
  String get editButtonTooltip;

  /// No description provided for @editResourceScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Guide'**
  String get editResourceScreenTitle;

  /// No description provided for @resourceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get resourceTypeLabel;

  /// No description provided for @authorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// No description provided for @dateAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get dateAddedLabel;

  /// No description provided for @launchingUrlMessage.
  ///
  /// In en, this message translates to:
  /// **'Launching URL'**
  String get launchingUrlMessage;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @resourceUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resource updated successfully!'**
  String get resourceUpdatedSuccess;

  /// Error message when updating a resource fails
  ///
  /// In en, this message translates to:
  /// **'Error updating resource: {error}'**
  String resourceUpdatedError(String error);

  /// No description provided for @deleteResourceConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get deleteResourceConfirmTitle;

  /// No description provided for @deleteResourceConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this resource? This action cannot be undone.'**
  String get deleteResourceConfirmMessage;

  /// No description provided for @cancelButtonText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonText;

  /// No description provided for @deleteButtonText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonText;

  /// No description provided for @resourceDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Resource \"{resourceTitle}\" deleted successfully.'**
  String resourceDeletedSuccess(Object resourceTitle);

  /// No description provided for @resourceDeletedError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting resource: {error}'**
  String resourceDeletedError(Object error);

  /// No description provided for @deleteButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Resource'**
  String get deleteButtonTooltip;

  /// No description provided for @createANewQuiz.
  ///
  /// In en, this message translates to:
  /// **'Create a New Quiz'**
  String get createANewQuiz;

  /// No description provided for @quizTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz Title'**
  String get quizTitle;

  /// No description provided for @quizDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get quizDescription;

  /// No description provided for @saveAndAddQuestions.
  ///
  /// In en, this message translates to:
  /// **'Save and Add Questions'**
  String get saveAndAddQuestions;

  /// No description provided for @failedToCreateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Failed to create quiz'**
  String get failedToCreateQuiz;

  /// No description provided for @addQuestions.
  ///
  /// In en, this message translates to:
  /// **'Add Questions'**
  String get addQuestions;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finish;

  /// No description provided for @questionText.
  ///
  /// In en, this message translates to:
  /// **'Question Text'**
  String get questionText;

  /// No description provided for @pleaseEnterAQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please enter a question'**
  String get pleaseEnterAQuestion;

  /// No description provided for @questionType.
  ///
  /// In en, this message translates to:
  /// **'Question Type'**
  String get questionType;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get multipleChoice;

  /// No description provided for @trueFalse.
  ///
  /// In en, this message translates to:
  /// **'True/False'**
  String get trueFalse;

  /// No description provided for @pleaseSelectCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please select a correct answer.'**
  String get pleaseSelectCorrectAnswer;

  /// No description provided for @option.
  ///
  /// In en, this message translates to:
  /// **'Option {number}'**
  String option(Object number);

  /// No description provided for @pleaseEnterAnOption.
  ///
  /// In en, this message translates to:
  /// **'Please enter an option'**
  String get pleaseEnterAnOption;

  /// No description provided for @addQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestion;

  /// No description provided for @questionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Question added successfully!'**
  String get questionAddedSuccessfully;

  /// No description provided for @failedToAddQuestion.
  ///
  /// In en, this message translates to:
  /// **'Failed to add question'**
  String get failedToAddQuestion;

  /// No description provided for @noQuestionsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No questions added yet.'**
  String get noQuestionsAddedYet;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctAnswer;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @quizNotFound.
  ///
  /// In en, this message translates to:
  /// **'Quiz not found.'**
  String get quizNotFound;

  /// No description provided for @failedToLoadQuiz.
  ///
  /// In en, this message translates to:
  /// **'Failed to load quiz'**
  String get failedToLoadQuiz;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String question(Object number);

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'of {total}'**
  String totalQuestions(Object total);

  /// No description provided for @submitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Submit Quiz'**
  String get submitQuiz;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @quizResults.
  ///
  /// In en, this message translates to:
  /// **'Quiz Results'**
  String get quizResults;

  /// No description provided for @quizCompletionMessage.
  ///
  /// In en, this message translates to:
  /// **'You have completed the quiz!'**
  String get quizCompletionMessage;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score:'**
  String get yourScore;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @failedToSaveAttempt.
  ///
  /// In en, this message translates to:
  /// **'Failed to save your attempt'**
  String get failedToSaveAttempt;

  /// No description provided for @myQuizHistory.
  ///
  /// In en, this message translates to:
  /// **'My Quiz History'**
  String get myQuizHistory;

  /// No description provided for @noQuizAttempts.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t attempted any quizzes yet.'**
  String get noQuizAttempts;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @relatedQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Related Quizzes'**
  String get relatedQuizzesTitle;

  /// No description provided for @noQuizzesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No quizzes available for this resource yet.'**
  String get noQuizzesAvailable;

  /// No description provided for @errorLoadingQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Error loading quizzes'**
  String get errorLoadingQuizzes;

  /// No description provided for @invalidUrlFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL format: {url}'**
  String invalidUrlFormat(Object url);

  /// No description provided for @errorLaunchingUrl.
  ///
  /// In en, this message translates to:
  /// **'Error launching URL: {error}'**
  String errorLaunchingUrl(Object error);

  /// No description provided for @createResourceValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be at least {length} characters long'**
  String createResourceValidationMinLength(Object fieldName, Object length);

  /// No description provided for @createResourceValidationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot exceed {length} characters'**
  String createResourceValidationMaxLength(Object fieldName, Object length);

  /// No description provided for @titleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters long'**
  String get titleMinLength;

  /// No description provided for @titleMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Title cannot exceed 100 characters'**
  String get titleMaxLength;

  /// No description provided for @createTopicScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Start New Discussion'**
  String get createTopicScreenTitle;

  /// No description provided for @createTopicTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic Title'**
  String get createTopicTitleLabel;

  /// No description provided for @createTopicContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Discussion Content'**
  String get createTopicContentLabel;

  /// No description provided for @createTopicButtonText.
  ///
  /// In en, this message translates to:
  /// **'Create Discussion Topic'**
  String get createTopicButtonText;

  /// No description provided for @mustBeLoggedInToCreateTopic.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to create a topic.'**
  String get mustBeLoggedInToCreateTopic;

  /// No description provided for @topicCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Topic created successfully!'**
  String get topicCreatedSuccess;

  /// Error message when creating a topic fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create topic: {error}'**
  String failedToCreateTopic(String error, String xato);

  /// No description provided for @createTopicValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot be empty.'**
  String createTopicValidationEmpty(Object fieldName);

  /// No description provided for @createTopicValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} must be at least {length} characters long.'**
  String createTopicValidationMinLength(Object fieldName, Object length);

  /// No description provided for @createTopicValidationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} cannot exceed {length} characters.'**
  String createTopicValidationMaxLength(Object fieldName, Object length);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading resources. Please try again.'**
  String get errorLoadingData;

  /// Error message shown when topic update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating topic: {error}'**
  String failedToUpdateTopic(String error, String xato);

  /// No description provided for @topicUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Topic updated successfully!'**
  String get topicUpdatedSuccess;

  /// No description provided for @noDiscussionsYet.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet.'**
  String get noDiscussionsYet;

  /// No description provided for @beTheFirstToStartConversation.
  ///
  /// In en, this message translates to:
  /// **'Be the first to start a conversation!'**
  String get beTheFirstToStartConversation;

  /// No description provided for @mustBeLoggedInToCreateResource.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to create a resource.'**
  String get mustBeLoggedInToCreateResource;

  /// No description provided for @profileIncompleteToCreateResource.
  ///
  /// In en, this message translates to:
  /// **'Your profile information is incomplete. Please update your name in your profile.'**
  String get profileIncompleteToCreateResource;

  /// No description provided for @profileIncompleteToCreateTopic.
  ///
  /// In en, this message translates to:
  /// **'Your profile name is not set. Please update your profile.'**
  String get profileIncompleteToCreateTopic;

  /// No description provided for @commentCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Comment cannot be empty.'**
  String get commentCannotBeEmpty;

  /// No description provided for @mustBeLoggedInToComment.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to comment.'**
  String get mustBeLoggedInToComment;

  /// No description provided for @commentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully!'**
  String get commentAddedSuccessfully;

  /// Error message when adding a comment fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add comment: {error}'**
  String failedToAddComment(String error, String xato);

  /// No description provided for @postedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted by {authorName}'**
  String postedBy(Object authorName);

  /// No description provided for @onDate.
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String onDate(Object date);

  /// No description provided for @repliesTitle.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get repliesTitle;

  /// No description provided for @errorLoadingComments.
  ///
  /// In en, this message translates to:
  /// **'Error loading comments: {error}'**
  String errorLoadingComments(Object error);

  /// No description provided for @noRepliesYet.
  ///
  /// In en, this message translates to:
  /// **'No replies yet. Be the first to comment!'**
  String get noRepliesYet;

  /// No description provided for @writeAReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply...'**
  String get writeAReplyHint;

  /// No description provided for @sendCommentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send Comment'**
  String get sendCommentTooltip;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {userName}!'**
  String welcomeBack(Object userName);

  /// No description provided for @readyToLearnSomethingNew.
  ///
  /// In en, this message translates to:
  /// **'Ready to learn something new today?'**
  String get readyToLearnSomethingNew;

  /// No description provided for @quickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get quickAccessTitle;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get communityTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @latestNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get latestNewsTitle;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get sourceLabel;

  /// No description provided for @quizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzesTitle;

  /// No description provided for @urlCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'URL cannot be empty'**
  String get urlCannotBeEmpty;

  /// No description provided for @errorLoadingNews.
  ///
  /// In en, this message translates to:
  /// **'Error loading news: {error}'**
  String errorLoadingNews(Object error);

  /// No description provided for @noNewsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No news available at the moment.'**
  String get noNewsAvailable;

  /// No description provided for @adminPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanelTitle;

  /// No description provided for @manageNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage News'**
  String get manageNewsTitle;

  /// No description provided for @manageNewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or delete news articles'**
  String get manageNewsSubtitle;

  /// No description provided for @manageUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsersTitle;

  /// No description provided for @manageUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View users and manage roles (future)'**
  String get manageUsersSubtitle;

  /// No description provided for @manageResourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Guides'**
  String get manageResourcesTitle;

  /// No description provided for @manageResourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Oversee all learning resources (future)'**
  String get manageResourcesSubtitle;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteNewsMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{newsTitle}\"?'**
  String confirmDeleteNewsMessage(Object newsTitle);

  /// No description provided for @newsDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{newsTitle}\" deleted successfully.'**
  String newsDeletedSuccess(Object newsTitle);

  /// Error message when deleting news fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete \"{newsTitle}\": {error}'**
  String failedToDeleteNews(String error, Object newsTitle, Object xato);

  /// No description provided for @addNewsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add New News Article'**
  String get addNewsTooltip;

  /// No description provided for @editNewsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit News'**
  String get editNewsTooltip;

  /// No description provided for @deleteNewsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete News'**
  String get deleteNewsTooltip;

  /// No description provided for @addNewsButton.
  ///
  /// In en, this message translates to:
  /// **'Add News'**
  String get addNewsButton;

  /// No description provided for @noNewsAvailableManager.
  ///
  /// In en, this message translates to:
  /// **'No news articles found. Add one!'**
  String get noNewsAvailableManager;

  /// No description provided for @editNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit News'**
  String get editNewsTitle;

  /// No description provided for @addNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add News Article'**
  String get addNewsTitle;

  /// No description provided for @saveNewsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save News'**
  String get saveNewsTooltip;

  /// No description provided for @newsTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get newsTitleLabel;

  /// No description provided for @pleaseEnterNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a news title.'**
  String get pleaseEnterNewsTitle;

  /// No description provided for @newsTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'News title must be at least {length} characters.'**
  String newsTitleMinLength(Object length);

  /// No description provided for @newsSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source (e.g., Blog Name)'**
  String get newsSourceLabel;

  /// No description provided for @pleaseEnterNewsSource.
  ///
  /// In en, this message translates to:
  /// **'Please enter the news source.'**
  String get pleaseEnterNewsSource;

  /// No description provided for @newsUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Article URL'**
  String get newsUrlLabel;

  /// No description provided for @pleaseEnterNewsUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter the article URL.'**
  String get pleaseEnterNewsUrl;

  /// No description provided for @pleaseEnterValidNewsUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL (starting with http or https).'**
  String get pleaseEnterValidNewsUrl;

  /// No description provided for @newsImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL (Optional)'**
  String get newsImageUrlLabel;

  /// No description provided for @pleaseEnterValidImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid image URL (starting with http or https), or leave blank.'**
  String get pleaseEnterValidImageUrl;

  /// No description provided for @publicationDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Publication Date'**
  String get publicationDateLabel;

  /// No description provided for @pleaseSelectPublicationDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a publication date.'**
  String get pleaseSelectPublicationDate;

  /// No description provided for @noDateSelected.
  ///
  /// In en, this message translates to:
  /// **'No date selected'**
  String get noDateSelected;

  /// No description provided for @selectDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDateTooltip;

  /// No description provided for @updateNewsButton.
  ///
  /// In en, this message translates to:
  /// **'Update News'**
  String get updateNewsButton;

  /// No description provided for @addNewsButtonForm.
  ///
  /// In en, this message translates to:
  /// **'Add News Article'**
  String get addNewsButtonForm;

  /// No description provided for @newsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{newsTitle}\" updated successfully.'**
  String newsUpdatedSuccess(Object newsTitle);

  /// No description provided for @newsAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{newsTitle}\" added successfully.'**
  String newsAddedSuccess(Object newsTitle);

  /// Error message when saving news fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save news: {error}'**
  String failedToSaveNews(String error, Object xato);

  /// No description provided for @errorLoadingUsers.
  ///
  /// In en, this message translates to:
  /// **'Error loading users: {error}'**
  String errorLoadingUsers(Object error);

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @noEmailProvided.
  ///
  /// In en, this message translates to:
  /// **'No email provided'**
  String get noEmailProvided;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @registeredOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredOnLabel;

  /// No description provided for @manageUsersSubtitleNow.
  ///
  /// In en, this message translates to:
  /// **'View and search registered users'**
  String get manageUsersSubtitleNow;

  /// No description provided for @manageResourcesSubtitleNow.
  ///
  /// In en, this message translates to:
  /// **'View, edit, or delete any learning resource'**
  String get manageResourcesSubtitleNow;

  /// No description provided for @confirmDeleteResourceMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete resource \"{resourceTitle}\"?'**
  String confirmDeleteResourceMessage(Object resourceTitle);

  /// Error message when deleting resource fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete resource \"{resourceTitle}\": {error}'**
  String failedToDeleteResource(
    String error,
    Object resourceTitle,
    Object xato,
  );

  /// No description provided for @errorLoadingResources.
  ///
  /// In en, this message translates to:
  /// **'Error loading resources: {error}'**
  String errorLoadingResources(Object error);

  /// No description provided for @noResourcesFoundManager.
  ///
  /// In en, this message translates to:
  /// **'No resources found in the system.'**
  String get noResourcesFoundManager;

  /// No description provided for @editResourceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Resource'**
  String get editResourceTooltip;

  /// No description provided for @deleteResourceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Resource'**
  String get deleteResourceTooltip;

  /// No description provided for @manageQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Quizzes'**
  String get manageQuizzesTitle;

  /// No description provided for @addQuizTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add New Quiz'**
  String get addQuizTooltip;

  /// No description provided for @errorLoadingQuizzesAdmin.
  ///
  /// In en, this message translates to:
  /// **'Error loading quizzes: {error}'**
  String errorLoadingQuizzesAdmin(Object error);

  /// No description provided for @noQuizzesFoundManager.
  ///
  /// In en, this message translates to:
  /// **'No quizzes found. Add one!'**
  String get noQuizzesFoundManager;

  /// No description provided for @confirmDeleteQuizMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete quiz \"{quizTitle}\" and all its questions? This action cannot be undone.'**
  String confirmDeleteQuizMessage(Object quizTitle);

  /// No description provided for @quizDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Quiz \"{quizTitle}\" and its questions deleted successfully.'**
  String quizDeletedSuccess(Object quizTitle);

  /// Error message when deleting quiz fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete quiz \"{quizTitle}\": {error}'**
  String failedToDeleteQuiz(String error, Object quizTitle, Object xato);

  /// No description provided for @editDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get editDetailsButton;

  /// No description provided for @manageQuestionsButton.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get manageQuestionsButton;

  /// No description provided for @deleteQuizTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Quiz and Questions'**
  String get deleteQuizTooltip;

  /// No description provided for @addQuizButton.
  ///
  /// In en, this message translates to:
  /// **'Add Quiz'**
  String get addQuizButton;

  /// No description provided for @manageQuizzesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Oversee all quizzes and their questions'**
  String get manageQuizzesSubtitle;

  get welcomeMessage => null;

  get signInToContinue => null;

  get registrationNameLabel => null;

  get registrationNameError => null;

  get registrationEmailError => null;

  String? get registrationRoleHint => null;

  String? get roleExpert => null;

  String? get searchResources => null;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
