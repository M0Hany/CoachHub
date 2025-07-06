// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get workout_plans_title => 'Workout Plans';

  @override
  String get workout_plans_create_plan => 'Create Workout Plan';

  @override
  String get workout_plans_plan_title => 'Plan Title';

  @override
  String get workout_plans_plan_duration => 'Plan Duration';

  @override
  String get workout_plans_days => 'days';

  @override
  String get workout_plans_next => 'Next';

  @override
  String get workout_plans_day => 'Day';

  @override
  String get workout_plans_choose_muscle => 'Choose Muscle';

  @override
  String workout_plans_muscle_groups(String muscle) {
    return '$muscle';
  }

  @override
  String get workout_plans_exercise_details_sets => 'Sets';

  @override
  String get workout_plans_exercise_details_reps => 'Reps';

  @override
  String get workout_plans_exercise_details_rest_time => 'Rest Time';

  @override
  String get workout_plans_exercise_details_seconds => 'seconds';

  @override
  String get workout_plans_exercise_details_note => 'Note';

  @override
  String get workout_plans_exercise_details_video_url => 'Video URL';

  @override
  String get workout_plans_apply => 'Apply';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginToContinue => 'Please login to continue';

  @override
  String get loginSubtitle => 'Please enter your email and password to login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get error => 'An error occurred';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_email => 'Please enter a valid email';

  @override
  String get validation_password_length => 'Password must be at least 6 characters';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign up';

  @override
  String get forgetPassword => 'Forget Password?';

  @override
  String get navSearch => 'Search';

  @override
  String get navChats => 'Chats';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSettings => 'Settings';

  @override
  String get navPlans => 'Plans';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get availability => 'Availability';

  @override
  String get pricing => 'Pricing';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get expertise => 'Expertise';

  @override
  String get certifications => 'Certifications';

  @override
  String get specializations => 'Specializations';

  @override
  String get logout => 'Logout';

  @override
  String get logoutError => 'Failed to logout. Please try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get accountSettingsTitle => 'Account Settings';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get logoutButton => 'Logout';

  @override
  String get createAccount => 'Create an account';

  @override
  String get username => 'Username';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterUsername => 'Enter your username';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get validation_username_length => 'Username must be at least 3 characters';

  @override
  String get validation_username_format => 'Username can only contain letters and numbers';

  @override
  String get registerSuccess => 'Registration successful! Please complete your profile.';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';

  @override
  String get plansTitle => 'Plans';

  @override
  String get workoutPlans => 'Workout Plans';

  @override
  String get nutritionPlans => 'Nutrition Plans';

  @override
  String get noWorkoutPlans => 'No workout plans yet';

  @override
  String get noNutritionPlans => 'No nutrition plans yet';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get workoutLabel => 'Workout';

  @override
  String get nutritionLabel => 'Nutrition';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsToday => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get notificationsJustNow => 'Just now';

  @override
  String interestedInCoaching(String name) {
    return '$name is interested in coaching with you';
  }

  @override
  String checkedOffWorkout(String name) {
    return '$name checked off their workout';
  }

  @override
  String completedPlan(String name) {
    return '$name completed their plan';
  }

  @override
  String requestedChange(String name) {
    return '$name requested a change to their plan';
  }

  @override
  String dayAgo(int count) {
    return '$count day ago';
  }

  @override
  String get yourExpertise => 'Your Expertise';

  @override
  String get selectExpertiseAreas => 'Select your areas of expertise';

  @override
  String get weightTraining => 'Weight Training';

  @override
  String get cardio => 'Cardio';

  @override
  String get yoga => 'Yoga';

  @override
  String get pilates => 'Pilates';

  @override
  String get crossfit => 'CrossFit';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get sportsPerformance => 'Sports Performance';

  @override
  String get rehabilitation => 'Rehabilitation';

  @override
  String get continueAction => 'Continue';

  @override
  String get errorPickingImage => 'Error picking image';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get fillProfile => 'Fill Profile';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterBio => 'Enter your bio';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get userType => 'User Type';

  @override
  String get coach => 'Coach';

  @override
  String get trainee => 'Trainee';

  @override
  String get next => 'Next';

  @override
  String get continueButton => 'Continue';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get muscleGain => 'Muscle Gain';

  @override
  String get overallHealth => 'Overall Health';

  @override
  String get competitionPreparation => 'Competition Preparation';

  @override
  String get boostAthleticAgility => 'Boost Athletic Agility';

  @override
  String get boostImmuneSystem => 'Boost Immune System';

  @override
  String get increaseExplosiveness => 'Increase Explosiveness';

  @override
  String get healthInformation => 'Health Information';

  @override
  String get age => 'Age';

  @override
  String get enterAge => 'Enter your age';

  @override
  String get height => 'Height';

  @override
  String get enterHeight => 'Enter your height';

  @override
  String get weight => 'Weight';

  @override
  String get enterWeight => 'Enter your weight';

  @override
  String get fatsPercentage => 'Fats Percentage';

  @override
  String get enterFatPercentage => 'Enter your fat percentage';

  @override
  String get bodyMuscle => 'Body Muscle';

  @override
  String get muscles => 'Muscles';

  @override
  String get enterMusclePercentage => 'Enter your muscle percentage';

  @override
  String get fitnessGoals => 'Fitness Goals';

  @override
  String get saveHealthData => 'Save Health Data';

  @override
  String get typeMessage => 'Type a message';

  @override
  String get messages => 'Messages';

  @override
  String get searchForClientsFields => 'Search for clients';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get upperChestMuscle => 'Upper Chest Muscle';

  @override
  String get shoulderFrontdelts => 'Shoulder Front Delts';

  @override
  String get showPlan => 'Show Plan';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get bodyWeight => 'Body Weight';

  @override
  String get kg => 'kg';

  @override
  String get bodyHeight => 'Body Height';

  @override
  String get cm => 'cm';

  @override
  String get percentSymbol => '%';

  @override
  String get fatsGraph => 'Fats Graph';

  @override
  String get monthly => 'Monthly';

  @override
  String get currentFatPercentage => 'Current Fat Percentage';

  @override
  String get profile => 'Profile';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get edit => 'Edit';

  @override
  String get name => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get coachExpertFields => 'Coach Expert Fields';

  @override
  String get posts => 'Posts';

  @override
  String get showAllPosts => 'Show All Posts';

  @override
  String timeAgo(String time) {
    return '$time ago';
  }

  @override
  String get createNewPlan => 'Create New Plan';

  @override
  String get planTitle => 'Plan Title';

  @override
  String get planDuration => 'Plan Duration';

  @override
  String get noPlanData => 'No plan data available';

  @override
  String planDurationDays(int days) {
    return '$days days';
  }

  @override
  String page(int number) {
    return 'Page $number';
  }

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get note => 'Note';

  @override
  String get apply => 'Apply';

  @override
  String get selectDayFirst => 'Please select a day first';

  @override
  String get savePlan => 'Save Plan';

  @override
  String get searchClients => 'Search Clients';

  @override
  String ageGender(String age, String gender) {
    return '$age years, $gender';
  }

  @override
  String get showHealthData => 'Show Health Data';

  @override
  String get plans => 'Plans';

  @override
  String get workoutPlansTab => 'Workout Plans';

  @override
  String get nutritionPlansTab => 'Nutrition Plans';

  @override
  String get planTitlePrefix => 'Plan: ';

  @override
  String get planDurationPrefix => 'Duration: ';

  @override
  String get dayLabel => 'Day';

  @override
  String get showExercise => 'Show Exercise';

  @override
  String get muscleSuffix => 'Exercises';

  @override
  String get noExercisesAvailable => 'No exercises available';

  @override
  String get animationComingSoon => 'Animation coming soon';

  @override
  String get workoutPlansTitle => 'Workout Plans';

  @override
  String get sets => 'Sets';

  @override
  String setsRange(int min, int max) {
    return '$min-$max sets';
  }

  @override
  String get reps => 'Reps';

  @override
  String repsRange(int min, int max) {
    return '$min-$max reps';
  }

  @override
  String get restTime => 'Rest Time';

  @override
  String restTimeRange(int min, int max) {
    return '$min-$max seconds';
  }

  @override
  String get noteFromCoach => 'Note from Coach';

  @override
  String get exerciseNote => 'Exercise Note';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingWelcomeTitle => 'Welcome to CoachHub!';

  @override
  String get onboardingWelcomeDesc => 'CoachHub will be with you supporting every coach and trainee with an all-in-one platform that simplifies workout planning, tracks real-time performance, and ensures a smooth fitness journey.';

  @override
  String get onboardingLevelUpTitle => 'Level up your fitness journey whether you\'re coaching or training';

  @override
  String get onboardingLevelUpDesc => 'Take your fitness to the next level with our comprehensive platform designed for both coaches and trainees.';

  @override
  String get onboardingProgressTitle => 'From Plan to Progress';

  @override
  String get onboardingProgressDesc => 'Transform your fitness goals into achievements with smart planning and tracking tools.';

  @override
  String get realTimeTracking => 'Real-Time Progress tracking';

  @override
  String get seamlessTraining => 'Seamless Training';

  @override
  String get workoutNutritionPlans => 'Workout & nutrition plans';

  @override
  String get visualProgress => 'Visual Progress Tracking';

  @override
  String get interactiveTraining => 'Experience Interactive Training Plans';

  @override
  String get smartCoaching => 'Achieve Your Goals with Smart Coaching';

  @override
  String get contactCoach => 'Contact Coach';

  @override
  String get viewOnboarding => 'View Onboarding';

  @override
  String get nutrition_plans_create_plan => 'Create Nutrition Plan';

  @override
  String get nutrition_plans_plan_title => 'Nutrition Plan Title';

  @override
  String get nutrition_plans_plan_duration => 'Plan Duration';

  @override
  String get nutrition_plans_days => 'days';

  @override
  String get nutrition_plans_day => 'Day';

  @override
  String get checkYourEmail => 'Check your email';

  @override
  String get otpVerificationMessage => 'We sent you a message with a confirmation code to confirm your email. Please enter it to complete your registration.';

  @override
  String get didntReceiveCode => 'Didn\'t receive code?';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get verify => 'Verify';

  @override
  String get invalidOtpCode => 'Invalid verification code. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get noTraineesSubscribed => 'No trainees are subscribed to you yet';

  @override
  String get deletePlan => 'Delete Plan';

  @override
  String get deletePlanConfirmation => 'Are you sure you want to delete this plan?';

  @override
  String get deletePlanConfirm => 'Are you sure you want to delete this plan?';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get weightLabel => 'Weight';

  @override
  String get heightLabel => 'Height';

  @override
  String get fatsLabel => 'Fats';

  @override
  String get muscleLabel => 'Muscle';

  @override
  String get searchForCoachesFields => 'Search for Coaches, fields..';

  @override
  String get noRecommendedCoaches => 'No recommended coaches available';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribeConfirmTitle => 'Subscribe to Coach';

  @override
  String subscribeConfirmMessage(String coachName) {
    return 'Would you like to send a subscription request to $coachName?';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get subscribeSuccess => 'Subscription request sent successfully';

  @override
  String get close => 'Close';

  @override
  String get subscriptionRequestsTitle => 'Subscription Requests';

  @override
  String get acceptRequest => 'Accept';

  @override
  String get rejectRequest => 'Reject';

  @override
  String get noSubscriptionRequests => 'No subscription requests yet';

  @override
  String get acceptSubscriptionConfirmTitle => 'Accept Subscription';

  @override
  String get rejectSubscriptionConfirmTitle => 'Reject Subscription';

  @override
  String acceptSubscriptionConfirmMessage(String traineeName) {
    return 'Are you sure you want to accept $traineeName\'s subscription request?';
  }

  @override
  String rejectSubscriptionConfirmMessage(String traineeName) {
    return 'Are you sure you want to reject $traineeName\'s subscription request?';
  }

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get healthConditionsTitle => 'Do you have any of these conditions?';

  @override
  String get hypertension => 'Hypertension (High Blood Pressure)';

  @override
  String get diabetes => 'Diabetes';

  @override
  String get assignPlan => 'Assign Plan';

  @override
  String get workoutPlanAssignedSuccessfully => 'Workout plan assigned successfully';

  @override
  String get nutritionPlanAssignedSuccessfully => 'Nutrition plan assigned successfully';

  @override
  String get forgotPasswordTitle => 'Forgot Your Password?';

  @override
  String get forgotPasswordSubtitle => 'Don\'t worry, we\'ll help you reset it. Please enter your registered email address to send a confirmation code';

  @override
  String get resetStepEmail => 'Email';

  @override
  String get resetStepOtp => 'OTP';

  @override
  String get resetStepNewPassword => 'New password';

  @override
  String get resetEmailLabel => 'Email';

  @override
  String get resetEmailHint => 'Enter your mail';

  @override
  String get resetSendCode => 'Send Code';

  @override
  String get otpResetTitle => 'Enter Verification code';

  @override
  String get otpResetSubtitle => 'A 6-digit code has been sent to your email. Please enter it below to reset your password.';

  @override
  String get otpResetContinue => 'Continue';

  @override
  String get newPasswordTitle => 'Create New Password';

  @override
  String get newPasswordSubtitle => 'Make sure your new password is strong';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get newPasswordHint => 'Enter your new password';

  @override
  String get newPasswordConfirm => 'Confirm';

  @override
  String get newPasswordSuccess => 'Password reset successfully';

  @override
  String get newPasswordError => 'Failed to reset password. Please try again.';

  @override
  String get otpInvalid => 'Invalid OTP. Please try again.';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get reviews => 'Reviews';

  @override
  String get showAllReviews => 'Show All Reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get createPost => 'Create Post';

  @override
  String get seeMore => 'See more';

  @override
  String get whatsOnYourMind => 'What\'s on your mind?';

  @override
  String get post => 'Post';

  @override
  String get editPost => 'Edit Post';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get update => 'Update';

  @override
  String get deletePostConfirm => 'Are you sure you want to delete this post?';

  @override
  String get makeFirstPost => 'Make Your First Post';

  @override
  String get unassignPlan => 'Unassign Plan';

  @override
  String get unassignPlanConfirmTitle => 'Unassign Plan';

  @override
  String get unassignPlanConfirmMessage => 'Are you sure you want to unassign this plan from the trainee?';

  @override
  String get unassignPlanSuccess => 'Plan unassigned successfully';

  @override
  String get unassignPlanError => 'Failed to unassign plan. Please try again.';

  @override
  String get endSubscription => 'End Subscription';

  @override
  String get endSubscriptionTitle => 'End Subscription';

  @override
  String get endSubscriptionMessage => 'Are you sure you want to end this trainee\'s subscription?';

  @override
  String get endSubscriptionSuccess => 'Subscription ended successfully';

  @override
  String get endSubscriptionError => 'Failed to end subscription. Please try again.';

  @override
  String get unsubscribeTitle => 'Unsubscribe from Coach';

  @override
  String get unsubscribeMessage => 'Are you sure you want to unsubscribe from this coach?';

  @override
  String get unsubscribeSuccess => 'Unsubscribed successfully';

  @override
  String get unsubscribeError => 'Failed to unsubscribe. Please try again.';

  @override
  String get rateCoach => 'Rate Coach';

  @override
  String get writeReview => 'Write your review...';

  @override
  String get save => 'Save';

  @override
  String get reviewSuccess => 'Review submitted successfully';

  @override
  String get reviewError => 'Failed to submit review. Please try again.';

  @override
  String get reviewAlreadySubmitted => 'You have already submitted a review for this coach';

  @override
  String get suggestedExercises => 'Suggested Exercises';

  @override
  String get suggestedFood => 'Suggested Food';

  @override
  String get noSuggestedExercises => 'No suggested exercises available';

  @override
  String get noSuggestedFood => 'No suggested food available';
}
