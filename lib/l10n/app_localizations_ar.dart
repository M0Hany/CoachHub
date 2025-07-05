// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get workout_plans_title => 'خطط التمرين';

  @override
  String get workout_plans_create_plan => 'إنشاء خطة تمرين';

  @override
  String get workout_plans_plan_title => 'عنوان الخطة';

  @override
  String get workout_plans_plan_duration => 'مدة الخطة';

  @override
  String get workout_plans_days => 'أيام';

  @override
  String get workout_plans_next => 'التالي';

  @override
  String get workout_plans_day => 'يوم';

  @override
  String get workout_plans_choose_muscle => 'اختر مجموعة العضلات';

  @override
  String workout_plans_muscle_groups(String muscle) {
    return '$muscle';
  }

  @override
  String get workout_plans_exercise_details_sets => 'المجموعات';

  @override
  String get workout_plans_exercise_details_reps => 'التكرارات';

  @override
  String get workout_plans_exercise_details_rest_time => 'وقت الراحة';

  @override
  String get workout_plans_exercise_details_seconds => 'ثانية';

  @override
  String get workout_plans_exercise_details_note => 'ملاحظة';

  @override
  String get workout_plans_exercise_details_video_url => 'رابط الفيديو';

  @override
  String get workout_plans_apply => 'تطبيق';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get loginToContinue => 'الرجاء تسجيل الدخول للمتابعة';

  @override
  String get loginSubtitle => 'الرجاء إدخال البريد الإلكتروني وكلمة المرور لتسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get error => 'حدث خطأ';

  @override
  String get validation_required => 'هذا الحقل مطلوب';

  @override
  String get validation_email => 'الرجاء إدخال بريد إلكتروني صحيح';

  @override
  String get validation_password_length => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get forgetPassword => 'نسيت كلمة المرور؟';

  @override
  String get navSearch => 'بحث';

  @override
  String get navChats => 'المحادثات';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navProfile => 'الحساب';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navPlans => 'الخطط';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get availability => 'التوفر';

  @override
  String get pricing => 'التسعير';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get expertise => 'الخبرة';

  @override
  String get certifications => 'الشهادات';

  @override
  String get specializations => 'التخصصات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutError => 'فشل تسجيل الخروج. يرجى المحاولة مرة أخرى.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get languageSettings => 'إعدادات اللغة';

  @override
  String get accountSettingsTitle => 'إعدادات الحساب';

  @override
  String get notificationSettingsTitle => 'إعدادات الإشعارات';

  @override
  String get darkModeTitle => 'الوضع الداكن';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterUsername => 'أدخل اسم المستخدم';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get validation_username_length => 'يجب أن يكون اسم المستخدم 3 أحرف على الأقل';

  @override
  String get validation_username_format => 'يمكن أن يحتوي اسم المستخدم على أحرف وأرقام فقط';

  @override
  String get registerSuccess => 'تم التسجيل بنجاح! الرجاء إكمال ملفك الشخصي.';

  @override
  String get signUp => 'تسجيل';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ سجل دخول';

  @override
  String get plansTitle => 'الخطط';

  @override
  String get workoutPlans => 'خطط التمارين';

  @override
  String get nutritionPlans => 'خطط التغذية';

  @override
  String get noWorkoutPlans => 'لا توجد خطط تمارين حتى الآن';

  @override
  String get noNutritionPlans => 'لا توجد خطط تغذية حتى الآن';

  @override
  String daysCount(int count) {
    return '$count يوم';
  }

  @override
  String get workoutLabel => 'تمرين';

  @override
  String get nutritionLabel => 'تغذية';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsToday => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get notificationsJustNow => 'الآن';

  @override
  String interestedInCoaching(String name) {
    return '$name مهتم بالتدريب معك';
  }

  @override
  String checkedOffWorkout(String name) {
    return 'قام مدربك $name بتحديث خطة التدريب الخاصة بك';
  }

  @override
  String completedPlan(String name) {
    return '$name أكمل خطته';
  }

  @override
  String requestedChange(String name) {
    return '$name طلب تغييراً في خطته';
  }

  @override
  String dayAgo(int count) {
    return 'منذ $count يوم';
  }

  @override
  String get yourExpertise => 'خبرتك';

  @override
  String get selectExpertiseAreas => 'اختر مجالات خبرتك';

  @override
  String get weightTraining => 'تدريب الأوزان';

  @override
  String get cardio => 'تمارين القلب';

  @override
  String get yoga => 'يوغا';

  @override
  String get pilates => 'بيلاتس';

  @override
  String get crossfit => 'كروسفت';

  @override
  String get nutrition => 'تغذية';

  @override
  String get sportsPerformance => 'الأداء الرياضي';

  @override
  String get rehabilitation => 'إعادة التأهيل';

  @override
  String get continueAction => 'متابعة';

  @override
  String get errorPickingImage => 'خطأ في اختيار الصورة';

  @override
  String get fillAllFields => 'يرجى ملء جميع الحقول';

  @override
  String get fillProfile => 'ملء الملف الشخصي';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get enterBio => 'أدخل نبذة عنك';

  @override
  String get gender => 'الجنس';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get userType => 'نوع المستخدم';

  @override
  String get coach => 'مدرب';

  @override
  String get trainee => 'متدرب';

  @override
  String get next => 'التالي';

  @override
  String get continueButton => 'متابعة';

  @override
  String get enterValidNumber => 'الرجاء إدخال رقم صحيح';

  @override
  String get muscleGain => 'زيادة العضلات';

  @override
  String get overallHealth => 'الصحة العامة';

  @override
  String get competitionPreparation => 'التحضير للمنافسة';

  @override
  String get boostAthleticAgility => 'تعزيز الرشاقة الرياضية';

  @override
  String get boostImmuneSystem => 'تعزيز جهاز المناعة';

  @override
  String get increaseExplosiveness => 'زيادة القوة الانفجارية';

  @override
  String get healthInformation => 'المعلومات الصحية';

  @override
  String get age => 'العمر';

  @override
  String get enterAge => 'الرجاء إدخال عمرك';

  @override
  String get height => 'الطول (سم)';

  @override
  String get enterHeight => 'الرجاء إدخال طولك';

  @override
  String get weight => 'الوزن (كجم)';

  @override
  String get enterWeight => 'الرجاء إدخال وزنك';

  @override
  String get fatsPercentage => 'نسبة الدهون';

  @override
  String get enterFatPercentage => 'الرجاء إدخال نسبة الدهون في الجسم';

  @override
  String get bodyMuscle => 'كتلة العضلات';

  @override
  String get muscles => 'العضلات';

  @override
  String get enterMusclePercentage => 'الرجاء إدخال نسبة كتلة العضلات';

  @override
  String get fitnessGoals => 'أهدافك الرياضية';

  @override
  String get saveHealthData => 'حفظ البيانات الصحية';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get messages => 'الرسائل';

  @override
  String get searchForClientsFields => 'البحث عن المتدربين';

  @override
  String get goodMorning => 'صباح الخير،';

  @override
  String get upperChestMuscle => 'عضلات الصدر العلوية';

  @override
  String get shoulderFrontdelts => 'عضلات الكتف الأمامية';

  @override
  String get showPlan => 'عرض الخطة';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get bodyWeight => 'وزن الجسم';

  @override
  String get kg => 'كجم';

  @override
  String get bodyHeight => 'طول الجسم';

  @override
  String get cm => 'سم';

  @override
  String get percentSymbol => '%';

  @override
  String get fatsGraph => 'رسم بياني للدهون';

  @override
  String get monthly => 'شهري';

  @override
  String get currentFatPercentage => 'نسبة الدهون الحالية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get edit => 'تعديل';

  @override
  String get name => 'الاسم';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get coachExpertFields => 'مجالات خبرة المدرب';

  @override
  String get posts => 'المنشورات';

  @override
  String get showAllPosts => 'عرض كل المنشورات >';

  @override
  String timeAgo(String time) {
    return 'منذ $time';
  }

  @override
  String get createNewPlan => 'إنشاء خطة جديدة';

  @override
  String get planTitle => 'عنوان الخطة';

  @override
  String get planDuration => 'مدة الخطة (أيام)';

  @override
  String get noPlanData => 'لا توجد بيانات خطة متاحة';

  @override
  String planDurationDays(int days) {
    return '$days يوم';
  }

  @override
  String page(int number) {
    return 'الصفحة $number';
  }

  @override
  String get breakfast => 'الإفطار';

  @override
  String get lunch => 'الغداء';

  @override
  String get dinner => 'العشاء';

  @override
  String get snack => 'سناك';

  @override
  String get note => 'ملاحظة';

  @override
  String get apply => 'تطبيق';

  @override
  String get selectDayFirst => 'الرجاء اختيار يوم أولاً';

  @override
  String get savePlan => 'حفظ الخطة';

  @override
  String get searchClients => 'ابحث عن العملاء...';

  @override
  String ageGender(String age, String gender) {
    return 'العمر: $age - $gender';
  }

  @override
  String get showHealthData => 'عرض البيانات الصحية';

  @override
  String get plans => 'الخطط';

  @override
  String get workoutPlansTab => 'خطط التمارين';

  @override
  String get nutritionPlansTab => 'خطط التغذية';

  @override
  String get planTitlePrefix => 'عنوان الخطة: ';

  @override
  String get planDurationPrefix => 'مدة الخطة: ';

  @override
  String get dayLabel => 'يوم';

  @override
  String get showExercise => 'عرض التمرين';

  @override
  String get muscleSuffix => 'عضلة';

  @override
  String get noExercisesAvailable => 'لا توجد تمارين متاحة لهذه المجموعة العضلية';

  @override
  String get animationComingSoon => 'الرسوم المتحركة قادمة قريباً';

  @override
  String get workoutPlansTitle => 'خطط التمارين';

  @override
  String get sets => 'المجموعات:';

  @override
  String setsRange(int min, int max) {
    return '$min-$max مجموعة';
  }

  @override
  String get reps => 'التكرارات:';

  @override
  String repsRange(int min, int max) {
    return '$min-$max تكرار';
  }

  @override
  String get restTime => 'وقت الراحة:';

  @override
  String restTimeRange(int min, int max) {
    return '$min-$max ثانية';
  }

  @override
  String get noteFromCoach => 'ملاحظة من المدرب:';

  @override
  String get exerciseNote => 'حاول الحفاظ على وتيرة متحكم بها طوال التمرين. لا تدع الوزن يسحبك للخلف بسرعة كبيرة - قاوم في الطريق للخارج والعودة. هذا سيساعد في تحقيق أقصى قدر من مشاركة العضلات ومنع الإصابة.';

  @override
  String get skip => 'تخطي';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get onboardingWelcomeTitle => 'مرحباً بك في CoachHub!';

  @override
  String get onboardingWelcomeDesc => 'سيكون CoachHub معك لدعم كل مدرب ومتدرب من خلال منصة شاملة تبسط تخطيط التمارين وتتبع الأداء في الوقت الفعلي وتضمن رحلة لياقة سلسة.';

  @override
  String get onboardingLevelUpTitle => 'ارتقِ برحلة لياقتك سواء كنت مدرباً أو متدرباً';

  @override
  String get onboardingLevelUpDesc => 'ارتقِ بلياقتك إلى المستوى التالي مع منصتنا الشاملة المصممة للمدربين والمتدربين.';

  @override
  String get onboardingProgressTitle => 'من الخطة إلى التقدم';

  @override
  String get onboardingProgressDesc => 'حول أهداف لياقتك إلى إنجازات مع أدوات التخطيط والتتبع الذكية.';

  @override
  String get realTimeTracking => 'تتبع التقدم في الوقت الفعلي';

  @override
  String get seamlessTraining => 'تدريب سلس';

  @override
  String get workoutNutritionPlans => 'خطط التمارين والتغذية';

  @override
  String get visualProgress => 'تتبع التقدم المرئي';

  @override
  String get interactiveTraining => 'جرب خطط التدريب التفاعلية';

  @override
  String get smartCoaching => 'حقق أهدافك مع التدريب الذكي';

  @override
  String get contactCoach => 'تواصل مع المدرب';

  @override
  String get viewOnboarding => 'عرض شاشات الترحيب';

  @override
  String get nutrition_plans_create_plan => 'إنشاء خطة تغذية';

  @override
  String get nutrition_plans_plan_title => 'عنوان خطة التغذية';

  @override
  String get nutrition_plans_plan_duration => 'مدة الخطة';

  @override
  String get nutrition_plans_days => 'أيام';

  @override
  String get checkYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get otpVerificationMessage => 'لقد أرسلنا لك رسالة تحتوي على رمز تأكيد لتأكيد بريدك الإلكتروني. يرجى إدخاله لإكمال التسجيل.';

  @override
  String get didntReceiveCode => 'لم تستلم الرمز؟';

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get verify => 'تحقق';

  @override
  String get invalidOtpCode => 'رمز التحقق غير صحيح. حاول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noTraineesSubscribed => 'لا يوجد متدربين مشتركين معك حتى الآن';

  @override
  String get deletePlan => 'حذف الخطة';

  @override
  String get deletePlanConfirmation => 'هل أنت متأكد أنك تريد حذف هذه الخطة؟';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get weightLabel => 'الوزن';

  @override
  String get heightLabel => 'الطول';

  @override
  String get fatsLabel => 'الدهون';

  @override
  String get muscleLabel => 'العضلات';

  @override
  String get searchForCoachesFields => 'البحث عن المدربين والمجالات..';

  @override
  String get noRecommendedCoaches => 'لا يوجد مدربين موصى بهم';

  @override
  String get subscribe => 'اشتراك';

  @override
  String get subscribeConfirmTitle => 'الاشتراك مع المدرب';

  @override
  String subscribeConfirmMessage(String coachName) {
    return 'هل تريد إرسال طلب اشتراك إلى $coachName؟';
  }

  @override
  String get confirm => 'تأكيد';

  @override
  String get subscribeSuccess => 'تم إرسال طلب الاشتراك بنجاح';

  @override
  String get close => 'إغلاق';

  @override
  String get subscriptionRequestsTitle => 'طلبات الاشتراك';

  @override
  String get acceptRequest => 'قبول';

  @override
  String get rejectRequest => 'رفض';

  @override
  String get noSubscriptionRequests => 'لا توجد طلبات اشتراك حتى الآن';

  @override
  String get acceptSubscriptionConfirmTitle => 'قبول الاشتراك';

  @override
  String get rejectSubscriptionConfirmTitle => 'رفض الاشتراك';

  @override
  String acceptSubscriptionConfirmMessage(String traineeName) {
    return 'هل أنت متأكد أنك تريد قبول طلب اشتراك $traineeName؟';
  }

  @override
  String rejectSubscriptionConfirmMessage(String traineeName) {
    return 'هل أنت متأكد أنك تريد رفض طلب اشتراك $traineeName؟';
  }

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get healthConditionsTitle => 'هل لديك أي من هذه الأمراض؟';

  @override
  String get hypertension => 'ارتفاع ضغط الدم';

  @override
  String get diabetes => 'السكري';

  @override
  String get assignPlan => 'تعيين خطة';

  @override
  String get workoutPlanAssignedSuccessfully => 'تم تعيين خطة التمرين بنجاح';

  @override
  String get nutritionPlanAssignedSuccessfully => 'تم تعيين خطة التغذية بنجاح';

  @override
  String get forgotPasswordTitle => 'هل نسيت كلمة المرور؟';

  @override
  String get forgotPasswordSubtitle => 'لا تقلق، سنساعدك في إعادة تعيينها. يرجى إدخال بريدك الإلكتروني المسجل لإرسال رمز التأكيد';

  @override
  String get resetStepEmail => 'البريد الإلكتروني';

  @override
  String get resetStepOtp => 'رمز التحقق';

  @override
  String get resetStepNewPassword => 'كلمة مرور جديدة';

  @override
  String get resetEmailLabel => 'البريد الإلكتروني';

  @override
  String get resetEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get resetSendCode => 'إرسال الرمز';

  @override
  String get otpResetTitle => 'أدخل رمز التحقق';

  @override
  String get otpResetSubtitle => 'تم إرسال رمز مكون من 6 أرقام إلى بريدك الإلكتروني. يرجى إدخاله أدناه لإعادة تعيين كلمة المرور.';

  @override
  String get otpResetContinue => 'متابعة';

  @override
  String get newPasswordTitle => 'إنشاء كلمة مرور جديدة';

  @override
  String get newPasswordSubtitle => 'تأكد من أن كلمة المرور الجديدة قوية';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get newPasswordHint => 'أدخل كلمة المرور الجديدة';

  @override
  String get newPasswordConfirm => 'تأكيد';

  @override
  String get newPasswordSuccess => 'تمت إعادة تعيين كلمة المرور بنجاح';

  @override
  String get newPasswordError => 'فشل في إعادة تعيين كلمة المرور. يرجى المحاولة مرة أخرى.';

  @override
  String get otpInvalid => 'رمز التحقق غير صحيح. حاول مرة أخرى.';
}
