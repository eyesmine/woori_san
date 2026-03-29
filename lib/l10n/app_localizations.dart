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
  /// **'8자 이상, 영문+숫자 포함'**
  String get passwordValidation;

  /// No description provided for @passwordRequirement.
  ///
  /// In ko, this message translates to:
  /// **'8자 이상, 영문+숫자'**
  String get passwordRequirement;

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

  /// No description provided for @noStampsYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 도장이 없어요\n산 정상에서 첫 도장을 받아보세요!'**
  String get noStampsYet;

  /// No description provided for @noRecordsYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록이 없어요\n첫 산행을 시작해보세요!'**
  String get noRecordsYet;

  /// No description provided for @loadingCourses.
  ///
  /// In ko, this message translates to:
  /// **'추천 코스를 불러오는 중...'**
  String get loadingCourses;

  /// No description provided for @mountainNotFound.
  ///
  /// In ko, this message translates to:
  /// **'산 정보를 찾을 수 없습니다.'**
  String get mountainNotFound;

  /// No description provided for @introduction.
  ///
  /// In ko, this message translates to:
  /// **'소개'**
  String get introduction;

  /// No description provided for @courseInfo.
  ///
  /// In ko, this message translates to:
  /// **'코스 정보'**
  String get courseInfo;

  /// No description provided for @location.
  ///
  /// In ko, this message translates to:
  /// **'위치'**
  String get location;

  /// No description provided for @tag.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get tag;

  /// No description provided for @language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get language;

  /// No description provided for @appInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// No description provided for @imagePickError.
  ///
  /// In ko, this message translates to:
  /// **'이미지를 선택할 수 없습니다'**
  String get imagePickError;

  /// No description provided for @durationRequired.
  ///
  /// In ko, this message translates to:
  /// **'소요 시간을 입력해주세요'**
  String get durationRequired;

  /// No description provided for @photo.
  ///
  /// In ko, this message translates to:
  /// **'사진'**
  String get photo;

  /// No description provided for @addButton.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get addButton;

  /// No description provided for @stopConfirm.
  ///
  /// In ko, this message translates to:
  /// **'등산을 종료하고 기록을 저장하시겠습니까?'**
  String get stopConfirm;

  /// No description provided for @goBack.
  ///
  /// In ko, this message translates to:
  /// **'돌아가기'**
  String get goBack;

  /// No description provided for @continueHiking.
  ///
  /// In ko, this message translates to:
  /// **'계속하기'**
  String get continueHiking;

  /// No description provided for @stopAndSave.
  ///
  /// In ko, this message translates to:
  /// **'종료 및 저장'**
  String get stopAndSave;

  /// No description provided for @freeHiking.
  ///
  /// In ko, this message translates to:
  /// **'자유 등산'**
  String get freeHiking;

  /// No description provided for @searchPrompt.
  ///
  /// In ko, this message translates to:
  /// **'산 이름이나 지역으로 검색해보세요'**
  String get searchPrompt;

  /// No description provided for @noSearchResults.
  ///
  /// In ko, this message translates to:
  /// **'검색 결과가 없습니다'**
  String get noSearchResults;

  /// No description provided for @invalidAccess.
  ///
  /// In ko, this message translates to:
  /// **'잘못된 접근입니다.'**
  String get invalidAccess;

  /// No description provided for @notClimbedYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 오르지 않은 산이에요 🌱\n함께 도전해 볼까요?'**
  String get notClimbedYet;

  /// No description provided for @soloStamp.
  ///
  /// In ko, this message translates to:
  /// **'혼자 도장'**
  String get soloStamp;

  /// No description provided for @togetherStamp.
  ///
  /// In ko, this message translates to:
  /// **'함께 도장'**
  String get togetherStamp;

  /// No description provided for @cancelStamp.
  ///
  /// In ko, this message translates to:
  /// **'도장 취소'**
  String get cancelStamp;

  /// No description provided for @climbedDate.
  ///
  /// In ko, this message translates to:
  /// **'완등한 날'**
  String get climbedDate;

  /// No description provided for @togetherClimbedDate.
  ///
  /// In ko, this message translates to:
  /// **'함께 오른 날'**
  String get togetherClimbedDate;

  /// No description provided for @weatherDefault.
  ///
  /// In ko, this message translates to:
  /// **'등산하기 딱 좋은 날씨!'**
  String get weatherDefault;

  /// No description provided for @weatherRain.
  ///
  /// In ko, this message translates to:
  /// **'비 소식이 있어요. 우비를 챙기세요!'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In ko, this message translates to:
  /// **'눈이 올 예정이에요. 방한 장비 필수!'**
  String get weatherSnow;

  /// No description provided for @weatherThunder.
  ///
  /// In ko, this message translates to:
  /// **'천둥번개 예보! 산행을 미루는 게 좋겠어요.'**
  String get weatherThunder;

  /// No description provided for @weatherFog.
  ///
  /// In ko, this message translates to:
  /// **'안개가 낄 수 있어요. 시야에 주의하세요.'**
  String get weatherFog;

  /// No description provided for @weatherVeryHot.
  ///
  /// In ko, this message translates to:
  /// **'매우 더운 날씨! 충분한 수분 섭취 필수!'**
  String get weatherVeryHot;

  /// No description provided for @weatherHot.
  ///
  /// In ko, this message translates to:
  /// **'더운 날씨에요. 물을 넉넉히 챙기세요.'**
  String get weatherHot;

  /// No description provided for @weatherVeryCold.
  ///
  /// In ko, this message translates to:
  /// **'매우 추운 날씨! 방한 장비를 꼭 챙기세요.'**
  String get weatherVeryCold;

  /// No description provided for @weatherCold.
  ///
  /// In ko, this message translates to:
  /// **'쌀쌀한 날씨에요. 따뜻하게 입으세요.'**
  String get weatherCold;

  /// No description provided for @weatherCloudy.
  ///
  /// In ko, this message translates to:
  /// **'구름이 있지만 산행하기 좋아요!'**
  String get weatherCloudy;

  /// No description provided for @weatherLoading.
  ///
  /// In ko, this message translates to:
  /// **'날씨 확인 중...'**
  String get weatherLoading;

  /// No description provided for @weatherError.
  ///
  /// In ko, this message translates to:
  /// **'날씨 정보를 불러올 수 없어요'**
  String get weatherError;

  /// No description provided for @weatherFallback.
  ///
  /// In ko, this message translates to:
  /// **'맑음 · 12°C · 바람 약함'**
  String get weatherFallback;

  /// No description provided for @rateLimitError.
  ///
  /// In ko, this message translates to:
  /// **'요청이 너무 많습니다. 잠시 후 다시 시도해주세요.'**
  String get rateLimitError;

  /// No description provided for @imageTooLarge.
  ///
  /// In ko, this message translates to:
  /// **'이미지 크기는 10MB 이하여야 합니다'**
  String get imageTooLarge;

  /// No description provided for @addChecklistItem.
  ///
  /// In ko, this message translates to:
  /// **'준비물 추가'**
  String get addChecklistItem;

  /// No description provided for @deleteChecklistItem.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get deleteChecklistItem;

  /// No description provided for @checklistItemHint.
  ///
  /// In ko, this message translates to:
  /// **'새 준비물을 입력하세요'**
  String get checklistItemHint;

  /// No description provided for @favorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get favorites;

  /// No description provided for @addToFavorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 추가'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 해제'**
  String get removeFromFavorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 즐겨찾기한 산이 없어요\n마음에 드는 산을 추가해보세요!'**
  String get noFavoritesYet;

  /// No description provided for @partner.
  ///
  /// In ko, this message translates to:
  /// **'파트너'**
  String get partner;

  /// No description provided for @registerPartner.
  ///
  /// In ko, this message translates to:
  /// **'파트너 등록'**
  String get registerPartner;

  /// No description provided for @removePartner.
  ///
  /// In ko, this message translates to:
  /// **'파트너 해제'**
  String get removePartner;

  /// No description provided for @partnerRegistered.
  ///
  /// In ko, this message translates to:
  /// **'파트너가 등록되었습니다'**
  String get partnerRegistered;

  /// No description provided for @partnerRemoved.
  ///
  /// In ko, this message translates to:
  /// **'파트너가 해제되었습니다'**
  String get partnerRemoved;

  /// No description provided for @partnerSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'파트너 ID를 입력하세요'**
  String get partnerSearchHint;

  /// No description provided for @noPartnerYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 등록된 파트너가 없어요\n함께 등산할 파트너를 등록해보세요!'**
  String get noPartnerYet;

  /// No description provided for @removePartnerConfirm.
  ///
  /// In ko, this message translates to:
  /// **'파트너를 해제하시겠습니까?'**
  String get removePartnerConfirm;

  /// No description provided for @elevationProfile.
  ///
  /// In ko, this message translates to:
  /// **'고도 프로필'**
  String get elevationProfile;

  /// No description provided for @maxElevation.
  ///
  /// In ko, this message translates to:
  /// **'최고 고도'**
  String get maxElevation;

  /// No description provided for @minElevation.
  ///
  /// In ko, this message translates to:
  /// **'최저 고도'**
  String get minElevation;

  /// No description provided for @elevationGainLabel.
  ///
  /// In ko, this message translates to:
  /// **'누적 상승'**
  String get elevationGainLabel;

  /// No description provided for @recordDetail.
  ///
  /// In ko, this message translates to:
  /// **'기록 상세'**
  String get recordDetail;

  /// No description provided for @routeMap.
  ///
  /// In ko, this message translates to:
  /// **'경로 지도'**
  String get routeMap;

  /// No description provided for @startPoint.
  ///
  /// In ko, this message translates to:
  /// **'출발'**
  String get startPoint;

  /// No description provided for @endPoint.
  ///
  /// In ko, this message translates to:
  /// **'도착'**
  String get endPoint;

  /// No description provided for @noRouteData.
  ///
  /// In ko, this message translates to:
  /// **'경로 데이터가 없습니다'**
  String get noRouteData;

  /// No description provided for @statistics.
  ///
  /// In ko, this message translates to:
  /// **'통계'**
  String get statistics;

  /// No description provided for @monthlyHikes.
  ///
  /// In ko, this message translates to:
  /// **'월별 등산 횟수'**
  String get monthlyHikes;

  /// No description provided for @cumulativeDistance.
  ///
  /// In ko, this message translates to:
  /// **'누적 거리'**
  String get cumulativeDistance;

  /// No description provided for @averageDuration.
  ///
  /// In ko, this message translates to:
  /// **'평균 소요 시간'**
  String get averageDuration;

  /// No description provided for @hikesThisYear.
  ///
  /// In ko, this message translates to:
  /// **'올해 등산'**
  String get hikesThisYear;

  /// No description provided for @distanceThisYear.
  ///
  /// In ko, this message translates to:
  /// **'올해 거리'**
  String get distanceThisYear;

  /// No description provided for @noDataForYear.
  ///
  /// In ko, this message translates to:
  /// **'해당 연도의 데이터가 없습니다'**
  String get noDataForYear;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'나의 등산 기록을 한눈에'**
  String get statisticsSubtitle;

  /// No description provided for @emergencyContact.
  ///
  /// In ko, this message translates to:
  /// **'비상 연락처'**
  String get emergencyContact;

  /// No description provided for @emergencySos.
  ///
  /// In ko, this message translates to:
  /// **'긴급 SOS'**
  String get emergencySos;

  /// No description provided for @sosConfirm.
  ///
  /// In ko, this message translates to:
  /// **'현재 위치를 비상 연락처로 전송하시겠습니까?'**
  String get sosConfirm;

  /// No description provided for @sosSent.
  ///
  /// In ko, this message translates to:
  /// **'SOS 메시지가 전송되었습니다'**
  String get sosSent;

  /// No description provided for @emergencyName.
  ///
  /// In ko, this message translates to:
  /// **'연락처 이름'**
  String get emergencyName;

  /// No description provided for @emergencyPhone.
  ///
  /// In ko, this message translates to:
  /// **'전화번호'**
  String get emergencyPhone;

  /// No description provided for @emergencySettings.
  ///
  /// In ko, this message translates to:
  /// **'비상 연락처 설정'**
  String get emergencySettings;

  /// No description provided for @noEmergencyContact.
  ///
  /// In ko, this message translates to:
  /// **'비상 연락처를 먼저 설정해주세요'**
  String get noEmergencyContact;

  /// No description provided for @sunrise.
  ///
  /// In ko, this message translates to:
  /// **'일출'**
  String get sunrise;

  /// No description provided for @sunset.
  ///
  /// In ko, this message translates to:
  /// **'일몰'**
  String get sunset;

  /// No description provided for @reviews.
  ///
  /// In ko, this message translates to:
  /// **'리뷰'**
  String get reviews;

  /// No description provided for @writeReview.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 작성'**
  String get writeReview;

  /// No description provided for @reviewHint.
  ///
  /// In ko, this message translates to:
  /// **'등산 후기를 남겨보세요 (최대 500자)'**
  String get reviewHint;

  /// No description provided for @submitReview.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 등록'**
  String get submitReview;

  /// No description provided for @deleteReview.
  ///
  /// In ko, this message translates to:
  /// **'리뷰 삭제'**
  String get deleteReview;

  /// No description provided for @noReviewsYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 리뷰가 없어요\n첫 리뷰를 남겨보세요!'**
  String get noReviewsYet;

  /// No description provided for @loginRequired.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다'**
  String get loginRequired;

  /// No description provided for @reviewSubmitted.
  ///
  /// In ko, this message translates to:
  /// **'리뷰가 등록되었습니다'**
  String get reviewSubmitted;

  /// No description provided for @reviewDeleted.
  ///
  /// In ko, this message translates to:
  /// **'리뷰가 삭제되었습니다'**
  String get reviewDeleted;

  /// No description provided for @rating.
  ///
  /// In ko, this message translates to:
  /// **'평점'**
  String get rating;

  /// No description provided for @deleteReviewConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 리뷰를 삭제하시겠습니까?'**
  String get deleteReviewConfirm;

  /// No description provided for @shareRecord.
  ///
  /// In ko, this message translates to:
  /// **'기록 공유'**
  String get shareRecord;

  /// No description provided for @shareText.
  ///
  /// In ko, this message translates to:
  /// **'우리산 등산 기록'**
  String get shareText;

  /// No description provided for @offlineMaps.
  ///
  /// In ko, this message translates to:
  /// **'오프라인 지도'**
  String get offlineMaps;

  /// No description provided for @downloadMaps.
  ///
  /// In ko, this message translates to:
  /// **'지도 미리 불러오기'**
  String get downloadMaps;

  /// No description provided for @clearMapCache.
  ///
  /// In ko, this message translates to:
  /// **'캐시 삭제'**
  String get clearMapCache;

  /// No description provided for @offlineMapsInfo.
  ///
  /// In ko, this message translates to:
  /// **'지도를 미리 보면 오프라인에서도 사용할 수 있어요'**
  String get offlineMapsInfo;

  /// No description provided for @preloadMap.
  ///
  /// In ko, this message translates to:
  /// **'미리 보기'**
  String get preloadMap;

  /// No description provided for @cacheCleared.
  ///
  /// In ko, this message translates to:
  /// **'캐시가 삭제되었습니다'**
  String get cacheCleared;

  /// No description provided for @badges.
  ///
  /// In ko, this message translates to:
  /// **'배지'**
  String get badges;

  /// No description provided for @earnedBadges.
  ///
  /// In ko, this message translates to:
  /// **'획득한 배지'**
  String get earnedBadges;

  /// No description provided for @lockedBadges.
  ///
  /// In ko, this message translates to:
  /// **'미획득 배지'**
  String get lockedBadges;

  /// No description provided for @badgeEarned.
  ///
  /// In ko, this message translates to:
  /// **'배지 획득!'**
  String get badgeEarned;

  /// No description provided for @noBadgesYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 획득한 배지가 없어요\n등산을 시작해보세요!'**
  String get noBadgesYet;

  /// No description provided for @badgeProgress.
  ///
  /// In ko, this message translates to:
  /// **'{earned}/{total} 배지 획득'**
  String badgeProgress(Object earned, Object total);

  /// No description provided for @earnedOn.
  ///
  /// In ko, this message translates to:
  /// **'획득일'**
  String get earnedOn;

  /// No description provided for @weatherFeelsLike.
  ///
  /// In ko, this message translates to:
  /// **'체감 온도'**
  String get weatherFeelsLike;

  /// No description provided for @weatherHumidity.
  ///
  /// In ko, this message translates to:
  /// **'습도'**
  String get weatherHumidity;

  /// No description provided for @weatherWind.
  ///
  /// In ko, this message translates to:
  /// **'바람'**
  String get weatherWind;

  /// No description provided for @weatherPressure.
  ///
  /// In ko, this message translates to:
  /// **'기압'**
  String get weatherPressure;

  /// No description provided for @weatherVisibility.
  ///
  /// In ko, this message translates to:
  /// **'가시거리'**
  String get weatherVisibility;

  /// No description provided for @myLocation.
  ///
  /// In ko, this message translates to:
  /// **'내 위치'**
  String get myLocation;

  /// No description provided for @allHeight.
  ///
  /// In ko, this message translates to:
  /// **'전체 높이'**
  String get allHeight;

  /// No description provided for @heightUnder500.
  ///
  /// In ko, this message translates to:
  /// **'500m 이하'**
  String get heightUnder500;

  /// No description provided for @height500to1000.
  ///
  /// In ko, this message translates to:
  /// **'500~1000m'**
  String get height500to1000;

  /// No description provided for @heightOver1000.
  ///
  /// In ko, this message translates to:
  /// **'1000m 이상'**
  String get heightOver1000;

  /// No description provided for @sortByName.
  ///
  /// In ko, this message translates to:
  /// **'이름순'**
  String get sortByName;

  /// No description provided for @sortByHeight.
  ///
  /// In ko, this message translates to:
  /// **'높이순'**
  String get sortByHeight;

  /// No description provided for @sortByDifficulty.
  ///
  /// In ko, this message translates to:
  /// **'난이도순'**
  String get sortByDifficulty;

  /// No description provided for @mountainCount.
  ///
  /// In ko, this message translates to:
  /// **'개의 산'**
  String get mountainCount;

  /// No description provided for @bestRecords.
  ///
  /// In ko, this message translates to:
  /// **'최고 기록'**
  String get bestRecords;

  /// No description provided for @longestDistance.
  ///
  /// In ko, this message translates to:
  /// **'최장 거리'**
  String get longestDistance;

  /// No description provided for @highestElevation.
  ///
  /// In ko, this message translates to:
  /// **'최고 고도'**
  String get highestElevation;

  /// No description provided for @longestDuration.
  ///
  /// In ko, this message translates to:
  /// **'최장 시간'**
  String get longestDuration;

  /// No description provided for @hikingCalendar.
  ///
  /// In ko, this message translates to:
  /// **'등산 캘린더'**
  String get hikingCalendar;

  /// No description provided for @nextBadge.
  ///
  /// In ko, this message translates to:
  /// **'다음 배지'**
  String get nextBadge;

  /// No description provided for @badgeCategory_count.
  ///
  /// In ko, this message translates to:
  /// **'횟수'**
  String get badgeCategory_count;

  /// No description provided for @badgeCategory_distance.
  ///
  /// In ko, this message translates to:
  /// **'거리'**
  String get badgeCategory_distance;

  /// No description provided for @badgeCategory_region.
  ///
  /// In ko, this message translates to:
  /// **'지역'**
  String get badgeCategory_region;

  /// No description provided for @badgeCategory_stamp.
  ///
  /// In ko, this message translates to:
  /// **'도장'**
  String get badgeCategory_stamp;

  /// No description provided for @badgeCategory_special.
  ///
  /// In ko, this message translates to:
  /// **'특수'**
  String get badgeCategory_special;

  /// No description provided for @newBadgeEarned.
  ///
  /// In ko, this message translates to:
  /// **'새 배지 획득!'**
  String get newBadgeEarned;

  /// No description provided for @noRecordYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 기록이 없어요'**
  String get noRecordYet;

  /// No description provided for @badgeTitle.
  ///
  /// In ko, this message translates to:
  /// **'뱃지'**
  String get badgeTitle;

  /// No description provided for @achievementComplete.
  ///
  /// In ko, this message translates to:
  /// **'달성 완료!'**
  String get achievementComplete;

  /// No description provided for @achievementIncomplete.
  ///
  /// In ko, this message translates to:
  /// **'미달성'**
  String get achievementIncomplete;

  /// No description provided for @summitArrived.
  ///
  /// In ko, this message translates to:
  /// **'정상에 도착했습니다!'**
  String get summitArrived;

  /// No description provided for @gpsPoints.
  ///
  /// In ko, this message translates to:
  /// **'GPS 포인트'**
  String get gpsPoints;

  /// No description provided for @latitude.
  ///
  /// In ko, this message translates to:
  /// **'위도'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In ko, this message translates to:
  /// **'경도'**
  String get longitude;

  /// No description provided for @homeButton.
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get homeButton;

  /// No description provided for @pageNotFound.
  ///
  /// In ko, this message translates to:
  /// **'페이지를 찾을 수 없습니다'**
  String get pageNotFound;

  /// No description provided for @error.
  ///
  /// In ko, this message translates to:
  /// **'오류'**
  String get error;

  /// No description provided for @stampedStatus.
  ///
  /// In ko, this message translates to:
  /// **'도장 획득'**
  String get stampedStatus;

  /// No description provided for @unstampedStatus.
  ///
  /// In ko, this message translates to:
  /// **'미획득'**
  String get unstampedStatus;

  /// No description provided for @pauseButton.
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get pauseButton;

  /// No description provided for @resumeButton.
  ///
  /// In ko, this message translates to:
  /// **'재개'**
  String get resumeButton;
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
