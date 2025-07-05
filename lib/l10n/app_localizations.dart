import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('ar')
  ];

  /// No description provided for @workout_plans_title.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workout_plans_title;

  /// No description provided for @workout_plans_create_plan.
  ///
  /// In en, this message translates to:
  /// **'Create Workout Plan'**
  String get workout_plans_create_plan;

  /// No description provided for @workout_plans_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Plan Title'**
  String get workout_plans_plan_title;

  /// No description provided for @workout_plans_plan_duration.
  ///
  /// In en, this message translates to:
  /// **'Plan Duration'**
  String get workout_plans_plan_duration;

  /// No description provided for @workout_plans_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get workout_plans_days;

  /// No description provided for @workout_plans_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get workout_plans_next;

  /// No description provided for @workout_plans_day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get workout_plans_day;

  /// No description provided for @workout_plans_choose_muscle.
  ///
  /// In en, this message translates to:
  /// **'Choose Muscle'**
  String get workout_plans_choose_muscle;

  /// Muscle group name
  ///
  /// In en, this message translates to:
  /// **'{muscle}'**
  String workout_plans_muscle_groups(String muscle);

  /// No description provided for @workout_plans_exercise_details_sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get workout_plans_exercise_details_sets;

  /// No description provided for @workout_plans_exercise_details_reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get workout_plans_exercise_details_reps;

  /// No description provided for @workout_plans_exercise_details_rest_time.
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get workout_plans_exercise_details_rest_time;

  /// No description provided for @workout_plans_exercise_details_seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get workout_plans_exercise_details_seconds;

  /// No description provided for @workout_plans_exercise_details_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get workout_plans_exercise_details_note;

  /// No description provided for @workout_plans_exercise_details_video_url.
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get workout_plans_exercise_details_video_url;

  /// No description provided for @workout_plans_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get workout_plans_apply;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get loginToContinue;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password to login'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_required;

  /// No description provided for @validation_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validation_email;

  /// No description provided for @validation_password_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validation_password_length;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccount;

  /// No description provided for @forgetPassword.
  ///
  /// In en, this message translates to:
  /// **'Forget Password?'**
  String get forgetPassword;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get navChats;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get navPlans;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @expertise.
  ///
  /// In en, this message translates to:
  /// **'Expertise'**
  String get expertise;

  /// No description provided for @certifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications;

  /// No description provided for @specializations.
  ///
  /// In en, this message translates to:
  /// **'Specializations'**
  String get specializations;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Failed to logout. Please try again.'**
  String get logoutError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettingsTitle;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @validation_username_length.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get validation_username_length;

  /// No description provided for @validation_username_format.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters and numbers'**
  String get validation_username_format;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please complete your profile.'**
  String get registerSuccess;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @plansTitle.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plansTitle;

  /// No description provided for @workoutPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workoutPlans;

  /// No description provided for @nutritionPlans.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Plans'**
  String get nutritionPlans;

  /// No description provided for @noWorkoutPlans.
  ///
  /// In en, this message translates to:
  /// **'No workout plans yet'**
  String get noWorkoutPlans;

  /// No description provided for @noNutritionPlans.
  ///
  /// In en, this message translates to:
  /// **'No nutrition plans yet'**
  String get noNutritionPlans;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @workoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutLabel;

  /// No description provided for @nutritionLabel.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionLabel;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @notificationsJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsJustNow;

  /// No description provided for @interestedInCoaching.
  ///
  /// In en, this message translates to:
  /// **'{name} is interested in coaching with you'**
  String interestedInCoaching(String name);

  /// No description provided for @checkedOffWorkout.
  ///
  /// In en, this message translates to:
  /// **'{name} checked off their workout'**
  String checkedOffWorkout(String name);

  /// No description provided for @completedPlan.
  ///
  /// In en, this message translates to:
  /// **'{name} completed their plan'**
  String completedPlan(String name);

  /// No description provided for @requestedChange.
  ///
  /// In en, this message translates to:
  /// **'{name} requested a change to their plan'**
  String requestedChange(String name);

  /// No description provided for @dayAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} day ago'**
  String dayAgo(int count);

  /// No description provided for @yourExpertise.
  ///
  /// In en, this message translates to:
  /// **'Your Expertise'**
  String get yourExpertise;

  /// No description provided for @selectExpertiseAreas.
  ///
  /// In en, this message translates to:
  /// **'Select your areas of expertise'**
  String get selectExpertiseAreas;

  /// No description provided for @weightTraining.
  ///
  /// In en, this message translates to:
  /// **'Weight Training'**
  String get weightTraining;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @pilates.
  ///
  /// In en, this message translates to:
  /// **'Pilates'**
  String get pilates;

  /// No description provided for @crossfit.
  ///
  /// In en, this message translates to:
  /// **'CrossFit'**
  String get crossfit;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @sportsPerformance.
  ///
  /// In en, this message translates to:
  /// **'Sports Performance'**
  String get sportsPerformance;

  /// No description provided for @rehabilitation.
  ///
  /// In en, this message translates to:
  /// **'Rehabilitation'**
  String get rehabilitation;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @fillProfile.
  ///
  /// In en, this message translates to:
  /// **'Fill Profile'**
  String get fillProfile;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @enterBio.
  ///
  /// In en, this message translates to:
  /// **'Enter your bio'**
  String get enterBio;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @userType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// No description provided for @coach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// No description provided for @trainee.
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get trainee;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @muscleGain.
  ///
  /// In en, this message translates to:
  /// **'Muscle Gain'**
  String get muscleGain;

  /// No description provided for @overallHealth.
  ///
  /// In en, this message translates to:
  /// **'Overall Health'**
  String get overallHealth;

  /// No description provided for @competitionPreparation.
  ///
  /// In en, this message translates to:
  /// **'Competition Preparation'**
  String get competitionPreparation;

  /// No description provided for @boostAthleticAgility.
  ///
  /// In en, this message translates to:
  /// **'Boost Athletic Agility'**
  String get boostAthleticAgility;

  /// No description provided for @boostImmuneSystem.
  ///
  /// In en, this message translates to:
  /// **'Boost Immune System'**
  String get boostImmuneSystem;

  /// No description provided for @increaseExplosiveness.
  ///
  /// In en, this message translates to:
  /// **'Increase Explosiveness'**
  String get increaseExplosiveness;

  /// No description provided for @healthInformation.
  ///
  /// In en, this message translates to:
  /// **'Health Information'**
  String get healthInformation;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterAge;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @enterHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterHeight;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterWeight;

  /// No description provided for @fatsPercentage.
  ///
  /// In en, this message translates to:
  /// **'Fats Percentage'**
  String get fatsPercentage;

  /// No description provided for @enterFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Enter your fat percentage'**
  String get enterFatPercentage;

  /// No description provided for @bodyMuscle.
  ///
  /// In en, this message translates to:
  /// **'Body Muscle'**
  String get bodyMuscle;

  /// No description provided for @muscles.
  ///
  /// In en, this message translates to:
  /// **'Muscles'**
  String get muscles;

  /// No description provided for @enterMusclePercentage.
  ///
  /// In en, this message translates to:
  /// **'Enter your muscle percentage'**
  String get enterMusclePercentage;

  /// No description provided for @fitnessGoals.
  ///
  /// In en, this message translates to:
  /// **'Fitness Goals'**
  String get fitnessGoals;

  /// No description provided for @saveHealthData.
  ///
  /// In en, this message translates to:
  /// **'Save Health Data'**
  String get saveHealthData;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get typeMessage;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @searchForClientsFields.
  ///
  /// In en, this message translates to:
  /// **'Search for clients'**
  String get searchForClientsFields;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @upperChestMuscle.
  ///
  /// In en, this message translates to:
  /// **'Upper Chest Muscle'**
  String get upperChestMuscle;

  /// No description provided for @shoulderFrontdelts.
  ///
  /// In en, this message translates to:
  /// **'Shoulder Front Delts'**
  String get shoulderFrontdelts;

  /// No description provided for @showPlan.
  ///
  /// In en, this message translates to:
  /// **'Show Plan'**
  String get showPlan;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight'**
  String get bodyWeight;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @bodyHeight.
  ///
  /// In en, this message translates to:
  /// **'Body Height'**
  String get bodyHeight;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @percentSymbol.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percentSymbol;

  /// No description provided for @fatsGraph.
  ///
  /// In en, this message translates to:
  /// **'Fats Graph'**
  String get fatsGraph;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @currentFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Current Fat Percentage'**
  String get currentFatPercentage;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @coachExpertFields.
  ///
  /// In en, this message translates to:
  /// **'Coach Expert Fields'**
  String get coachExpertFields;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @showAllPosts.
  ///
  /// In en, this message translates to:
  /// **'Show All Posts'**
  String get showAllPosts;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String timeAgo(String time);

  /// No description provided for @createNewPlan.
  ///
  /// In en, this message translates to:
  /// **'Create New Plan'**
  String get createNewPlan;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan Title'**
  String get planTitle;

  /// No description provided for @planDuration.
  ///
  /// In en, this message translates to:
  /// **'Plan Duration'**
  String get planDuration;

  /// No description provided for @noPlanData.
  ///
  /// In en, this message translates to:
  /// **'No plan data available'**
  String get noPlanData;

  /// No description provided for @planDurationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String planDurationDays(int days);

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String page(int number);

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @selectDayFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a day first'**
  String get selectDayFirst;

  /// No description provided for @savePlan.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get savePlan;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search Clients'**
  String get searchClients;

  /// No description provided for @ageGender.
  ///
  /// In en, this message translates to:
  /// **'{age} years, {gender}'**
  String ageGender(String age, String gender);

  /// No description provided for @showHealthData.
  ///
  /// In en, this message translates to:
  /// **'Show Health Data'**
  String get showHealthData;

  /// No description provided for @plans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// No description provided for @workoutPlansTab.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workoutPlansTab;

  /// No description provided for @nutritionPlansTab.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Plans'**
  String get nutritionPlansTab;

  /// No description provided for @planTitlePrefix.
  ///
  /// In en, this message translates to:
  /// **'Plan: '**
  String get planTitlePrefix;

  /// No description provided for @planDurationPrefix.
  ///
  /// In en, this message translates to:
  /// **'Duration: '**
  String get planDurationPrefix;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// No description provided for @showExercise.
  ///
  /// In en, this message translates to:
  /// **'Show Exercise'**
  String get showExercise;

  /// No description provided for @muscleSuffix.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get muscleSuffix;

  /// No description provided for @noExercisesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exercises available'**
  String get noExercisesAvailable;

  /// No description provided for @animationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Animation coming soon'**
  String get animationComingSoon;

  /// No description provided for @workoutPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workoutPlansTitle;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @setsRange.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} sets'**
  String setsRange(int min, int max);

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @repsRange.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} reps'**
  String repsRange(int min, int max);

  /// No description provided for @restTime.
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get restTime;

  /// No description provided for @restTimeRange.
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} seconds'**
  String restTimeRange(int min, int max);

  /// No description provided for @noteFromCoach.
  ///
  /// In en, this message translates to:
  /// **'Note from Coach'**
  String get noteFromCoach;

  /// No description provided for @exerciseNote.
  ///
  /// In en, this message translates to:
  /// **'Exercise Note'**
  String get exerciseNote;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CoachHub!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'CoachHub will be with you supporting every coach and trainee with an all-in-one platform that simplifies workout planning, tracks real-time performance, and ensures a smooth fitness journey.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingLevelUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Level up your fitness journey whether you\'re coaching or training'**
  String get onboardingLevelUpTitle;

  /// No description provided for @onboardingLevelUpDesc.
  ///
  /// In en, this message translates to:
  /// **'Take your fitness to the next level with our comprehensive platform designed for both coaches and trainees.'**
  String get onboardingLevelUpDesc;

  /// No description provided for @onboardingProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'From Plan to Progress'**
  String get onboardingProgressTitle;

  /// No description provided for @onboardingProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'Transform your fitness goals into achievements with smart planning and tracking tools.'**
  String get onboardingProgressDesc;

  /// No description provided for @realTimeTracking.
  ///
  /// In en, this message translates to:
  /// **'Real-Time Progress tracking'**
  String get realTimeTracking;

  /// No description provided for @seamlessTraining.
  ///
  /// In en, this message translates to:
  /// **'Seamless Training'**
  String get seamlessTraining;

  /// No description provided for @workoutNutritionPlans.
  ///
  /// In en, this message translates to:
  /// **'Workout & nutrition plans'**
  String get workoutNutritionPlans;

  /// No description provided for @visualProgress.
  ///
  /// In en, this message translates to:
  /// **'Visual Progress Tracking'**
  String get visualProgress;

  /// No description provided for @interactiveTraining.
  ///
  /// In en, this message translates to:
  /// **'Experience Interactive Training Plans'**
  String get interactiveTraining;

  /// No description provided for @smartCoaching.
  ///
  /// In en, this message translates to:
  /// **'Achieve Your Goals with Smart Coaching'**
  String get smartCoaching;

  /// No description provided for @contactCoach.
  ///
  /// In en, this message translates to:
  /// **'Contact Coach'**
  String get contactCoach;

  /// No description provided for @viewOnboarding.
  ///
  /// In en, this message translates to:
  /// **'View Onboarding'**
  String get viewOnboarding;

  /// No description provided for @nutrition_plans_create_plan.
  ///
  /// In en, this message translates to:
  /// **'Create Nutrition Plan'**
  String get nutrition_plans_create_plan;

  /// No description provided for @nutrition_plans_plan_title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Plan Title'**
  String get nutrition_plans_plan_title;

  /// No description provided for @nutrition_plans_plan_duration.
  ///
  /// In en, this message translates to:
  /// **'Plan Duration'**
  String get nutrition_plans_plan_duration;

  /// No description provided for @nutrition_plans_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get nutrition_plans_days;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @otpVerificationMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent you a message with a confirmation code to confirm your email. Please enter it to complete your registration.'**
  String get otpVerificationMessage;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code?'**
  String get didntReceiveCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @invalidOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get invalidOtpCode;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noTraineesSubscribed.
  ///
  /// In en, this message translates to:
  /// **'No trainees are subscribed to you yet'**
  String get noTraineesSubscribed;

  /// No description provided for @deletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get deletePlan;

  /// No description provided for @deletePlanConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this plan?'**
  String get deletePlanConfirmation;

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

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get heightLabel;

  /// No description provided for @fatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fatsLabel;

  /// No description provided for @muscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get muscleLabel;

  /// No description provided for @searchForCoachesFields.
  ///
  /// In en, this message translates to:
  /// **'Search for Coaches, fields..'**
  String get searchForCoachesFields;

  /// No description provided for @noRecommendedCoaches.
  ///
  /// In en, this message translates to:
  /// **'No recommended coaches available'**
  String get noRecommendedCoaches;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Coach'**
  String get subscribeConfirmTitle;

  /// No description provided for @subscribeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Would you like to send a subscription request to {coachName}?'**
  String subscribeConfirmMessage(String coachName);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @subscribeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription request sent successfully'**
  String get subscribeSuccess;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @subscriptionRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Requests'**
  String get subscriptionRequestsTitle;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectRequest;

  /// No description provided for @noSubscriptionRequests.
  ///
  /// In en, this message translates to:
  /// **'No subscription requests yet'**
  String get noSubscriptionRequests;

  /// No description provided for @acceptSubscriptionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Subscription'**
  String get acceptSubscriptionConfirmTitle;

  /// No description provided for @rejectSubscriptionConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Subscription'**
  String get rejectSubscriptionConfirmTitle;

  /// No description provided for @acceptSubscriptionConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to accept {traineeName}\'s subscription request?'**
  String acceptSubscriptionConfirmMessage(String traineeName);

  /// No description provided for @rejectSubscriptionConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject {traineeName}\'s subscription request?'**
  String rejectSubscriptionConfirmMessage(String traineeName);

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @healthConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Do you have any of these conditions?'**
  String get healthConditionsTitle;

  /// No description provided for @hypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension (High Blood Pressure)'**
  String get hypertension;

  /// No description provided for @diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get diabetes;

  /// No description provided for @assignPlan.
  ///
  /// In en, this message translates to:
  /// **'Assign Plan'**
  String get assignPlan;

  /// No description provided for @workoutPlanAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Workout plan assigned successfully'**
  String get workoutPlanAssignedSuccessfully;

  /// No description provided for @nutritionPlanAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Nutrition plan assigned successfully'**
  String get nutritionPlanAssignedSuccessfully;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Your Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry, we\'ll help you reset it. Please enter your registered email address to send a confirmation code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @resetStepEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get resetStepEmail;

  /// No description provided for @resetStepOtp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get resetStepOtp;

  /// No description provided for @resetStepNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetStepNewPassword;

  /// No description provided for @resetEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get resetEmailLabel;

  /// No description provided for @resetEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your mail'**
  String get resetEmailHint;

  /// No description provided for @resetSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get resetSendCode;

  /// No description provided for @otpResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification code'**
  String get otpResetTitle;

  /// No description provided for @otpResetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code has been sent to your email. Please enter it below to reset your password.'**
  String get otpResetSubtitle;

  /// No description provided for @otpResetContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get otpResetContinue;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make sure your new password is strong'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get newPasswordHint;

  /// No description provided for @newPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get newPasswordConfirm;

  /// No description provided for @newPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get newPasswordSuccess;

  /// No description provided for @newPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset password. Please try again.'**
  String get newPasswordError;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get otpInvalid;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
