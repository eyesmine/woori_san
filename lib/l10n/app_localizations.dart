import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'우리산'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// No description provided for @nickname.
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get nickname;

  /// No description provided for @emailValidation.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일을 입력하세요'**
  String get emailValidation;

  /// No description provided for @passwordValidation.
  ///
  /// In ko, this message translates to:
  /// **'6자 이상 입력하세요'**
  String get passwordValidation;

  /// No description provided for @nicknameValidation.
  ///
  /// In ko, this message translates to:
  /// **'2자 이상 입력하세요'**
  String get nicknameValidation;

  /// No description provided for @noAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정이 없으신가요? 회원가입'**
  String get noAccount;

  /// No description provided for @tabHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get tabHome;

  /// No description provided for @tabPlan.
  ///
  /// In ko, this message translates to:
  /// **'계획'**
  String get tabPlan;

  /// No description provided for @tabStamp.
  ///
  /// In ko, this message translates to:
  /// **'도장'**
  String get tabStamp;

  /// No description provided for @tabMap.
  ///
  /// In ko, this message translates to:
  /// **'지도'**
  String get tabMap;

  /// No description provided for @headerSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'다음 산행은 어디로?'**
  String get headerSubtitle;

  /// No description provided for @headerTitle.
  ///
  /// In ko, this message translates to:
  /// **'함께라면\n어디든 좋아요 🌿'**
  String get headerTitle;

  /// No description provided for @recommendedCourses.
  ///
  /// In ko, this message translates to:
  /// **'이번 주 추천 코스'**
  String get recommendedCourses;

  /// No description provided for @viewAll.
  ///
  /// In ko, this message translates to:
  /// **'전체보기'**
  String get viewAll;

  /// No description provided for @ourRecords.
  ///
  /// In ko, this message translates to:
  /// **'우리의 기록'**
  String get ourRecords;

  /// No description provided for @hikingPlan.
  ///
  /// In ko, this message translates to:
  /// **'등산 계획'**
  String get hikingPlan;

  /// No description provided for @newPlan.
  ///
  /// In ko, this message translates to:
  /// **'새 산행 계획'**
  String get newPlan;

  /// No description provided for @noPlanYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 계획이 없어요\n새 산행을 추가해보세요! 🌱'**
  String get noPlanYet;

  /// No description provided for @addPlan.
  ///
  /// In ko, this message translates to:
  /// **'새 산행 계획 추가'**
  String get addPlan;

  /// No description provided for @checklist.
  ///
  /// In ko, this message translates to:
  /// **'준비물 체크리스트'**
  String get checklist;

  /// No description provided for @stampCollection.
  ///
  /// In ko, this message translates to:
  /// **'도장 컬렉션'**
  String get stampCollection;

  /// No description provided for @mountainMap.
  ///
  /// In ko, this message translates to:
  /// **'산 지도'**
  String get mountainMap;

  /// No description provided for @profile.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @darkMode.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notifications;

  /// No description provided for @search.
  ///
  /// In ko, this message translates to:
  /// **'산 검색'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In ko, this message translates to:
  /// **'산 이름으로 검색'**
  String get searchHint;

  /// No description provided for @mountainDetail.
  ///
  /// In ko, this message translates to:
  /// **'산 상세'**
  String get mountainDetail;

  /// No description provided for @startHiking.
  ///
  /// In ko, this message translates to:
  /// **'등산 시작'**
  String get startHiking;

  /// No description provided for @stopHiking.
  ///
  /// In ko, this message translates to:
  /// **'등산 종료'**
  String get stopHiking;

  /// No description provided for @pauseHiking.
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get pauseHiking;

  /// No description provided for @resumeHiking.
  ///
  /// In ko, this message translates to:
  /// **'재개'**
  String get resumeHiking;

  /// No description provided for @trackingTitle.
  ///
  /// In ko, this message translates to:
  /// **'등산 중'**
  String get trackingTitle;

  /// No description provided for @elapsed.
  ///
  /// In ko, this message translates to:
  /// **'경과 시간'**
  String get elapsed;

  /// No description provided for @currentDistance.
  ///
  /// In ko, this message translates to:
  /// **'거리'**
  String get currentDistance;

  /// No description provided for @currentSpeed.
  ///
  /// In ko, this message translates to:
  /// **'속도'**
  String get currentSpeed;

  /// No description provided for @addRecord.
  ///
  /// In ko, this message translates to:
  /// **'기록 추가'**
  String get addRecord;

  /// No description provided for @selectMountain.
  ///
  /// In ko, this message translates to:
  /// **'산 선택'**
  String get selectMountain;

  /// No description provided for @selectDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜 선택'**
  String get selectDate;

  /// No description provided for @duration.
  ///
  /// In ko, this message translates to:
  /// **'소요 시간'**
  String get duration;

  /// No description provided for @distance.
  ///
  /// In ko, this message translates to:
  /// **'거리'**
  String get distance;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @summitReached.
  ///
  /// In ko, this message translates to:
  /// **'정상 도착!'**
  String get summitReached;

  /// No description provided for @summitCongrats.
  ///
  /// In ko, this message translates to:
  /// **'축하합니다! 정상에 도착했습니다!'**
  String get summitCongrats;

  /// No description provided for @stampAwarded.
  ///
  /// In ko, this message translates to:
  /// **'도장이 자동으로 부여되었습니다'**
  String get stampAwarded;

  /// No description provided for @together.
  ///
  /// In ko, this message translates to:
  /// **'함께'**
  String get together;

  /// No description provided for @totalHikes.
  ///
  /// In ko, this message translates to:
  /// **'함께한 산행'**
  String get totalHikes;

  /// No description provided for @totalDistance.
  ///
  /// In ko, this message translates to:
  /// **'총 거리'**
  String get totalDistance;

  /// No description provided for @earnedStamps.
  ///
  /// In ko, this message translates to:
  /// **'획득 도장'**
  String get earnedStamps;

  /// No description provided for @allMountains.
  ///
  /// In ko, this message translates to:
  /// **'추천 코스 전체보기'**
  String get allMountains;

  /// No description provided for @togetherMountains.
  ///
  /// In ko, this message translates to:
  /// **'함께 오른 산'**
  String get togetherMountains;

  /// No description provided for @challenge100.
  ///
  /// In ko, this message translates to:
  /// **'명산 100 도전'**
  String get challenge100;

  /// No description provided for @waitingMountains.
  ///
  /// In ko, this message translates to:
  /// **'개의 산이 여러분을 기다리고 있어요'**
  String get waitingMountains;

  /// No description provided for @whichMountain.
  ///
  /// In ko, this message translates to:
  /// **'어느 산으로?'**
  String get whichMountain;

  /// No description provided for @whenToGo.
  ///
  /// In ko, this message translates to:
  /// **'언제 갈까요?'**
  String get whenToGo;

  /// No description provided for @addPlanButton.
  ///
  /// In ko, this message translates to:
  /// **'계획 추가하기'**
  String get addPlanButton;

  /// No description provided for @upcomingHikes.
  ///
  /// In ko, this message translates to:
  /// **'예정된 산행'**
  String get upcomingHikes;

  /// No description provided for @beginner.
  ///
  /// In ko, this message translates to:
  /// **'초급'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In ko, this message translates to:
  /// **'중급'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In ko, this message translates to:
  /// **'상급'**
  String get advanced;

  /// No description provided for @logoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃 하시겠습니까?'**
  String get logoutConfirm;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @editProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 편집'**
  String get editProfile;

  /// No description provided for @joinDate.
  ///
  /// In ko, this message translates to:
  /// **'가입일'**
  String get joinDate;

  /// No description provided for @photoFromCamera.
  ///
  /// In ko, this message translates to:
  /// **'카메라'**
  String get photoFromCamera;

  /// No description provided for @photoFromGallery.
  ///
  /// In ko, this message translates to:
  /// **'갤러리'**
  String get photoFromGallery;

  /// No description provided for @region.
  ///
  /// In ko, this message translates to:
  /// **'지역'**
  String get region;

  /// No description provided for @difficulty.
  ///
  /// In ko, this message translates to:
  /// **'난이도'**
  String get difficulty;

  /// No description provided for @altitude.
  ///
  /// In ko, this message translates to:
  /// **'고도'**
  String get altitude;

  /// No description provided for @courseTime.
  ///
  /// In ko, this message translates to:
  /// **'코스 시간'**
  String get courseTime;

  /// No description provided for @courseDistance.
  ///
  /// In ko, this message translates to:
  /// **'코스 거리'**
  String get courseDistance;

  /// No description provided for @recordSaved.
  ///
  /// In ko, this message translates to:
  /// **'기록이 저장되었습니다'**
  String get recordSaved;

  /// No description provided for @hours.
  ///
  /// In ko, this message translates to:
  /// **'시간'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In ko, this message translates to:
  /// **'분'**
  String get minutes;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
