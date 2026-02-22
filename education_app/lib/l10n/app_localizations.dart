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
    Locale('uz')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Court Handbook'**
  String get appTitle;

  /// No description provided for @openInYoutube.
  ///
  /// In en, this message translates to:
  /// **'Open in YouTube'**
  String get openInYoutube;

  /// No description provided for @watchOnYoutube.
  ///
  /// In en, this message translates to:
  /// **'Watch on YouTube'**
  String get watchOnYoutube;

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
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUzbek.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get languageUzbek;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
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

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

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

  /// Title for the screen where users edit a discussion topic
  ///
  /// In en, this message translates to:
  /// **'Edit Discussion Topic'**
  String get editTopicScreenTitle;

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
  /// **'Quiz not found'**
  String get quizNotFound;

  /// No description provided for @failedToLoadQuiz.
  ///
  /// In en, this message translates to:
  /// **'Failed to load quiz'**
  String get failedToLoadQuiz;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question {index}'**
  String question(String index);

  /// No description provided for @totalQuestions.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String totalQuestions(String total);

  /// No description provided for @submitQuiz.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
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
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @failedToSaveAttempt.
  ///
  /// In en, this message translates to:
  /// **'Failed to save attempt'**
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
  String failedToDeleteNews(String error, Object newsTitle);

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @searchHelp.
  ///
  /// In en, this message translates to:
  /// **'Search help...'**
  String get searchHelp;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @helpfulFeedback.
  ///
  /// In en, this message translates to:
  /// **'Was this helpful?'**
  String get helpfulFeedback;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No FAQs found'**
  String get noArticlesFound;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenterTitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settingsAbout;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccess;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect current password'**
  String get errorWrongPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

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
  String failedToDeleteResource(String error, Object resourceTitle);

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
  String failedToDeleteQuiz(String error, Object quizTitle);

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

  /// Error message if email is invalid
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get registrationEmailError;

  /// Title for the regular staff member's dashboard section
  ///
  /// In en, this message translates to:
  /// **'My Activity'**
  String get dashboardXodimTitle;

  /// Title for the expert's dashboard section
  ///
  /// In en, this message translates to:
  /// **'My Contributions'**
  String get dashboardEkspertTitle;

  /// Title for the admin's dashboard section
  ///
  /// In en, this message translates to:
  /// **'System Overview'**
  String get dashboardAdminTitle;

  /// A button to see all items in a list
  ///
  /// In en, this message translates to:
  /// **'See All'**
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

  /// A divider text, like 'OR', between login options.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// Button text for signing in with a Google account.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Google'**
  String get signInWithGoogle;

  /// No description provided for @themeSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystemDefault;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDark;

  /// No description provided for @bioOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio (Optional)'**
  String get bioOptionalLabel;

  /// No description provided for @profilePictureUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture URL (Optional)'**
  String get profilePictureUrlLabel;

  /// No description provided for @levelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Newbie'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get levelAdvanced;

  /// No description provided for @levelExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get levelExpert;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @pointsToNextLevel.
  ///
  /// In en, this message translates to:
  /// **'{points} XP to next level'**
  String pointsToNextLevel(Object points);

  /// No description provided for @manageArticlesTitle.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get manageArticlesTitle;

  /// No description provided for @manageArticlesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Knowledge Base'**
  String get manageArticlesSubtitle;

  /// No description provided for @manageVideosTitle.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get manageVideosTitle;

  /// No description provided for @manageVideosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Video Tutorials'**
  String get manageVideosSubtitle;

  /// No description provided for @manageSystemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Systems'**
  String get manageSystemsTitle;

  /// No description provided for @manageSystemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Systems Directory'**
  String get manageSystemsSubtitle;

  /// No description provided for @manageFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get manageFaqTitle;

  /// No description provided for @manageFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage FAQs'**
  String get manageFaqSubtitle;

  /// No description provided for @manageNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get manageNotificationsTitle;

  /// No description provided for @manageNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send Notifications'**
  String get manageNotificationsSubtitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @topicDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{topicTitle}\" deleted successfully.'**
  String topicDeletedSuccess(Object topicTitle);

  /// No description provided for @failedToDeleteTopic.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete topic: {error}'**
  String failedToDeleteTopic(Object error);

  /// No description provided for @deleteTopicConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{topicTitle}\"?'**
  String deleteTopicConfirmMessage(Object topicTitle);

  /// No description provided for @editTopicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Topic'**
  String get editTopicTooltip;

  /// No description provided for @deleteTopicConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Topic'**
  String get deleteTopicConfirmTitle;

  /// No description provided for @commentPlural.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentPlural;

  /// No description provided for @commentSingular.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get commentSingular;

  /// No description provided for @deleteTopicTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Topic'**
  String get deleteTopicTooltip;

  /// No description provided for @faqCategoryLogin.
  ///
  /// In en, this message translates to:
  /// **'Login Issues'**
  String get faqCategoryLogin;

  /// No description provided for @faqCategoryPassword.
  ///
  /// In en, this message translates to:
  /// **'Password Issues'**
  String get faqCategoryPassword;

  /// No description provided for @faqCategoryUpload.
  ///
  /// In en, this message translates to:
  /// **'File Upload'**
  String get faqCategoryUpload;

  /// No description provided for @faqCategoryAccess.
  ///
  /// In en, this message translates to:
  /// **'Access Rights'**
  String get faqCategoryAccess;

  /// No description provided for @faqCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Questions'**
  String get faqCategoryGeneral;

  /// No description provided for @faqCategoryTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical Issues'**
  String get faqCategoryTechnical;

  /// No description provided for @confirmDeleteArticleMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the article \"{articleTitle}\"?'**
  String confirmDeleteArticleMessage(Object articleTitle);

  /// No description provided for @addArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Article'**
  String get addArticleTitle;

  /// No description provided for @editArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Article'**
  String get editArticleTitle;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @articleCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get articleCategoryGeneral;

  /// No description provided for @articleCategoryProcedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get articleCategoryProcedure;

  /// No description provided for @articleCategoryLaw.
  ///
  /// In en, this message translates to:
  /// **'Legislation'**
  String get articleCategoryLaw;

  /// No description provided for @articleCategoryFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get articleCategoryFaq;

  /// No description provided for @contentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content (Markdown)'**
  String get contentLabel;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get tagsLabel;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. court, law, code'**
  String get tagsHint;

  /// No description provided for @noPdfSelected.
  ///
  /// In en, this message translates to:
  /// **'No PDF file selected'**
  String get noPdfSelected;

  /// No description provided for @uploadPdfTooltip.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF'**
  String get uploadPdfTooltip;

  /// No description provided for @currentFileLabel.
  ///
  /// In en, this message translates to:
  /// **'Current file: {url}'**
  String currentFileLabel(Object url);

  /// No description provided for @existingPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Existing PDF file'**
  String get existingPdfFile;

  /// No description provided for @articleSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Article saved'**
  String get articleSavedSuccess;

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @contentRequired.
  ///
  /// In en, this message translates to:
  /// **'Content is required'**
  String get contentRequired;

  /// No description provided for @confirmDeleteVideoMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the video \"{videoTitle}\"?'**
  String confirmDeleteVideoMessage(Object videoTitle);

  /// No description provided for @videoDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video deleted'**
  String get videoDeletedSuccess;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideosFound;

  /// No description provided for @addVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'New Video'**
  String get addVideoTitle;

  /// No description provided for @editVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Video'**
  String get editVideoTitle;

  /// No description provided for @videoSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video saved'**
  String get videoSavedSuccess;

  /// No description provided for @youtubeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'YouTube ID'**
  String get youtubeIdLabel;

  /// No description provided for @youtubeIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. dQw4w9WgXcQ'**
  String get youtubeIdHint;

  /// No description provided for @youtubeIdRequired.
  ///
  /// In en, this message translates to:
  /// **'YouTube ID is required'**
  String get youtubeIdRequired;

  /// No description provided for @systemOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'System (Optional)'**
  String get systemOptionalLabel;

  /// No description provided for @notSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not Selected'**
  String get notSelectedLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (seconds)'**
  String get durationLabel;

  /// No description provided for @durationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 600'**
  String get durationHint;

  /// No description provided for @durationRequired.
  ///
  /// In en, this message translates to:
  /// **'Duration is required'**
  String get durationRequired;

  /// No description provided for @videoTagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. login, error, settings'**
  String get videoTagsHint;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @confirmDeleteSystemMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the system \"{systemName}\"?'**
  String confirmDeleteSystemMessage(Object systemName);

  /// No description provided for @systemDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'System deleted'**
  String get systemDeletedSuccess;

  /// No description provided for @noSystemsFound.
  ///
  /// In en, this message translates to:
  /// **'No systems found'**
  String get noSystemsFound;

  /// No description provided for @addSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'New System'**
  String get addSystemTitle;

  /// No description provided for @editSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit System'**
  String get editSystemTitle;

  /// No description provided for @systemSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'System saved'**
  String get systemSavedSuccess;

  /// No description provided for @shortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Name'**
  String get shortNameLabel;

  /// No description provided for @shortNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. e-SUD'**
  String get shortNameHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @websiteUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Website URL'**
  String get websiteUrlLabel;

  /// No description provided for @urlRequired.
  ///
  /// In en, this message translates to:
  /// **'URL is required'**
  String get urlRequired;

  /// No description provided for @logoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo URL'**
  String get logoUrlLabel;

  /// No description provided for @logoUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Logo URL is required'**
  String get logoUrlRequired;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @loginGuideIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Login Guide ID (Optional)'**
  String get loginGuideIdLabel;

  /// No description provided for @videoGuideIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Video Guide ID (Optional)'**
  String get videoGuideIdLabel;

  /// No description provided for @confirmDeleteFaqMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the question \"{question}\"?'**
  String confirmDeleteFaqMessage(Object question);

  /// No description provided for @faqDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Question deleted'**
  String get faqDeletedSuccess;

  /// No description provided for @noFaqsFound.
  ///
  /// In en, this message translates to:
  /// **'No questions found'**
  String get noFaqsFound;

  /// No description provided for @addFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'New Question'**
  String get addFaqTitle;

  /// No description provided for @editFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Question'**
  String get editFaqTitle;

  /// No description provided for @faqSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Question saved'**
  String get faqSavedSuccess;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// No description provided for @questionRequired.
  ///
  /// In en, this message translates to:
  /// **'Question is required'**
  String get questionRequired;

  /// No description provided for @answerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer (Markdown)'**
  String get answerLabel;

  /// No description provided for @answerRequired.
  ///
  /// In en, this message translates to:
  /// **'Answer is required'**
  String get answerRequired;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Field is required'**
  String get fieldRequired;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// No description provided for @successSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get successSaved;

  /// No description provided for @successDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get successDeleted;

  /// No description provided for @notificationManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Management'**
  String get notificationManagementTitle;

  /// No description provided for @notificationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification History'**
  String get notificationHistoryTitle;

  /// No description provided for @notificationHistoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'History of sent notifications will appear here (coming soon).'**
  String get notificationHistoryPlaceholder;

  /// No description provided for @sendNewNotificationButton.
  ///
  /// In en, this message translates to:
  /// **'Send New Notification'**
  String get sendNewNotificationButton;

  /// No description provided for @sendNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Notification'**
  String get sendNotificationTitle;

  /// No description provided for @notificationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Notification sent'**
  String get notificationSentSuccess;

  /// No description provided for @notificationTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notificationTitleLabel;

  /// No description provided for @notificationTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get notificationTitleRequired;

  /// No description provided for @notificationBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Message Body'**
  String get notificationBodyLabel;

  /// No description provided for @notificationBodyRequired.
  ///
  /// In en, this message translates to:
  /// **'Message body is required'**
  String get notificationBodyRequired;

  /// No description provided for @notificationTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Notification Type'**
  String get notificationTypeLabel;

  /// No description provided for @targetAudienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get targetAudienceLabel;

  /// No description provided for @resourceTabArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get resourceTabArticles;

  /// No description provided for @resourceTabVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get resourceTabVideos;

  /// No description provided for @resourceTabFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get resourceTabFiles;

  /// No description provided for @filesTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filesTabTitle;

  /// No description provided for @systemsDirectoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Court Information Systems'**
  String get systemsDirectoryTitle;

  /// No description provided for @bookmarkSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmarkSaveTooltip;

  /// No description provided for @bookmarkRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove Bookmark'**
  String get bookmarkRemoveTooltip;

  /// No description provided for @resourceTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get resourceTypeOther;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @resourceTypePDF.
  ///
  /// In en, this message translates to:
  /// **'PDF Manual'**
  String get resourceTypePDF;

  /// No description provided for @resourceTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video Tutorial'**
  String get resourceTypeVideo;

  /// No description provided for @resourceTypeLink.
  ///
  /// In en, this message translates to:
  /// **'Web Link'**
  String get resourceTypeLink;

  /// No description provided for @onlySaved.
  ///
  /// In en, this message translates to:
  /// **'Only Saved'**
  String get onlySaved;

  /// No description provided for @searchArticlesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search articles...'**
  String get searchArticlesPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noArticlesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No articles available'**
  String get noArticlesAvailable;

  /// No description provided for @noVideosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No videos available'**
  String get noVideosAvailable;

  /// No description provided for @actionCreateDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Create Discussion'**
  String get actionCreateDiscussion;

  /// No description provided for @actionCreateResource.
  ///
  /// In en, this message translates to:
  /// **'Create Resource'**
  String get actionCreateResource;

  /// No description provided for @actionCreateQuiz.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz'**
  String get actionCreateQuiz;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @markAllAsReadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsReadTooltip;

  /// No description provided for @allNotificationsReadMessage.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsReadMessage;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @leaderboardTitle.
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
  /// **'Congratulations! New Level: {level}'**
  String levelUp(String level);

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @quizHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz History'**
  String get quizHistoryTitle;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older Results'**
  String get older;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @landingTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Platform'**
  String get landingTitle;

  /// No description provided for @landingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Elevate your legal knowledge. Anytime. Anywhere.'**
  String get landingSubtitle;

  /// No description provided for @landingLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get landingLogin;

  /// No description provided for @landingRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get landingRegister;

  /// No description provided for @featureKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get featureKnowledgeBase;

  /// No description provided for @featureKnowledgeBaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Access a vast library of legal resources and documents.'**
  String get featureKnowledgeBaseDesc;

  /// No description provided for @featureVideoTutorials.
  ///
  /// In en, this message translates to:
  /// **'Video Tutorials'**
  String get featureVideoTutorials;

  /// No description provided for @featureVideoTutorialsDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn from expert-led video guides and webinars.'**
  String get featureVideoTutorialsDesc;

  /// No description provided for @featureGamification.
  ///
  /// In en, this message translates to:
  /// **'Gamification'**
  String get featureGamification;

  /// No description provided for @featureGamificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn XP, badges, and compete on the leaderboard.'**
  String get featureGamificationDesc;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Analytics (xAPI)'**
  String get analyticsTitle;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Records'**
  String get analyticsSubtitle;

  /// No description provided for @totalRecords.
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get totalRecords;

  /// No description provided for @realTime.
  ///
  /// In en, this message translates to:
  /// **'Real-time'**
  String get realTime;

  /// No description provided for @activityDistribution.
  ///
  /// In en, this message translates to:
  /// **'Activity Distribution'**
  String get activityDistribution;

  /// No description provided for @recentActivityFeed.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity Feed'**
  String get recentActivityFeed;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No learning records found yet.'**
  String get noRecords;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @unknownObject.
  ///
  /// In en, this message translates to:
  /// **'Unknown Object'**
  String get unknownObject;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @simulations.
  ///
  /// In en, this message translates to:
  /// **'Simulations'**
  String get simulations;

  /// No description provided for @catNewEmployees.
  ///
  /// In en, this message translates to:
  /// **'New Employees'**
  String get catNewEmployees;

  /// No description provided for @catIctSpecialists.
  ///
  /// In en, this message translates to:
  /// **'ICT Specialists'**
  String get catIctSpecialists;

  /// No description provided for @catSystems.
  ///
  /// In en, this message translates to:
  /// **'Systems'**
  String get catSystems;

  /// No description provided for @catAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get catAuth;

  /// No description provided for @catGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get catGeneral;

  /// No description provided for @rankBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get rankBeginner;

  /// No description provided for @rankIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get rankIntermediate;

  /// No description provided for @rankAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get rankAdvanced;

  /// No description provided for @sysCatPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary Systems'**
  String get sysCatPrimary;

  /// No description provided for @sysCatSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary Systems'**
  String get sysCatSecondary;

  /// No description provided for @sysCatSupport.
  ///
  /// In en, this message translates to:
  /// **'Support Systems'**
  String get sysCatSupport;

  /// No description provided for @sysStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get sysStatusActive;

  /// No description provided for @sysStatusMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get sysStatusMaintenance;

  /// No description provided for @sysStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get sysStatusInactive;

  /// No description provided for @videoViews.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String videoViews(int count);

  /// No description provided for @videoAuthorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get videoAuthorSubtitle;

  /// No description provided for @videoDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get videoDescriptionTitle;

  /// No description provided for @sysStatusDeprecated.
  ///
  /// In en, this message translates to:
  /// **'Deprecated'**
  String get sysStatusDeprecated;

  /// No description provided for @sysStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get sysStatusOffline;

  /// No description provided for @systemsDirectoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get systemsDirectoryAll;

  /// No description provided for @systemsDirectoryError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String systemsDirectoryError(String error);

  /// No description provided for @systemsDirectoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No systems available'**
  String get systemsDirectoryEmpty;

  /// No description provided for @backToKnowledgeBase.
  ///
  /// In en, this message translates to:
  /// **'Back to Guides'**
  String get backToKnowledgeBase;

  /// No description provided for @quizSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Great result!'**
  String get quizSuccessMessage;

  /// No description provided for @quizFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get quizFailureMessage;

  /// No description provided for @speedBonus.
  ///
  /// In en, this message translates to:
  /// **'SPEED BONUS'**
  String get speedBonus;

  /// No description provided for @levelSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Specialist'**
  String get levelSpecialist;

  /// No description provided for @levelMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get levelMaster;

  /// No description provided for @errorCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get errorCouldNotOpenLink;

  /// No description provided for @errorResourceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get errorResourceNotFound;

  /// No description provided for @errorVideoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Video not found'**
  String get errorVideoNotFound;

  /// No description provided for @errorPdfOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open PDF file'**
  String get errorPdfOpen;

  /// No description provided for @errorTelegramOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open Telegram link'**
  String get errorTelegramOpen;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorGeneric(Object error);

  /// No description provided for @labelTrue.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get labelTrue;

  /// No description provided for @labelFalse.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get labelFalse;

  /// No description provided for @labelPass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get labelPass;

  /// No description provided for @labelFail.
  ///
  /// In en, this message translates to:
  /// **'FAIL'**
  String get labelFail;

  /// No description provided for @labelPdfAvailable.
  ///
  /// In en, this message translates to:
  /// **'PDF available'**
  String get labelPdfAvailable;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get actionGoBack;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;
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
      'that was used.');
}
