# 우리산

함께 산을 오르는 즐거움을 기록하는 등산 앱

## 주요 기능

### 홈
- 이번 주 추천 등산 코스 (난이도, 소요시간 등)
- 날씨 카드 (실시간 GPS 기반 날씨, 조건별 동적 메시지)
- 함께한 산행 통계 (산행 횟수, 총 거리, 획득 도장)
- 최근 산행 기록 + 기록 추가 버튼
- Pull-to-refresh 지원
- 로딩/에러/빈 상태 UI
- 검색 / 프로필 바로가기

### 산 상세
- 산 정보 (고도, 난이도, 코스 거리/시간, 위치 좌표)
- 코스 정보 카드
- "등산 시작" 버튼 → 실시간 추적 화면 연결
- 잘못된 산 ID 접근 시 에러 화면

### 검색
- 산 이름 / 지역 검색
- 난이도 필터 (초급 / 중급 / 상급)
- 지역 필터 (산 데이터에서 동적 추출)

### 계획
- 등산 계획 추가 (산 선택 + 날짜)
- 계획 상태 토글 (확정 / 조율 중) — 탭으로 전환
- 스와이프로 계획 삭제
- 준비물 체크리스트

### 도장 컬렉션
- 명산 도전 진행률
- 혼자 도장 / 함께 도장 구분
- 함께 오른 산 별도 표시
- 정상 도착 시 GPS 인증 자동 도장
- 빈 상태 UI

### 지도
- 네이버 지도 기반 산 위치 표시
- 마커 탭으로 산 상세 정보 확인 → 상세 화면 이동
- 현재 위치 이동

### 실시간 등산 추적
- 네이티브: NaverMap 실시간 경로 폴리라인 + 산 마커 (웹: 그라데이션 폴백)
- GPS 기반 경로 추적 (위치 포인트 기록)
- 경과 시간, 거리, 속도 실시간 표시
- 일시정지 / 재개 / 종료
- 정상 도착 자동 감지 → 도장 자동 부여 (Provider 레벨 중복 방지)
- 종료 시 HikingRecord 자동 생성
- 위치 권한 거부 시 에러 화면

### 기록 추가
- 수동 산행 기록 입력 (산 선택, 날짜, 시간, 거리)
- 사진 첨부 (갤러리에서 다중 선택, 미리보기, 삭제)
- 소요 시간 / 거리 입력 검증
- 키보드 자동 해제
- 기존 기록 목록에 즉시 반영

### 프로필 / 설정
- 사용자 정보 (닉네임, 이메일, 가입일)
- 프로필 사진 변경 (갤러리/카메라 선택)
- 산행 통계 요약
- 프로필 편집 (닉네임 변경)
- 다크 모드 토글 (수동 전환, Hive 영속화)
- 알림 설정 토글 (Hive 영속화)
- 언어 전환 (한국어/English, Hive 영속화)
- 로그아웃

### 인증
- 이메일/비밀번호 로그인, 회원가입
- 이메일 정규식 검증
- JWT 토큰 자동 갱신 (QueuedInterceptorsWrapper)
- 토큰 응답 null 안전 검증
- GoRouter 기반 인증 리다이렉트
- 화면 전환 시 에러 메시지 자동 초기화

### 알림
- Firebase Cloud Messaging 푸시 알림
- 포그라운드: flutter_local_notifications로 표시
- 알림 탭 시 GoRouter 기반 화면 이동 (라우트 유효성 검증)
- 토픽 구독 (weather_alerts, hiking_tips)

---

### Client 기술 스택

| 분류 | 라이브러리 | 용도 |
|------|-----------|------|
| 프레임워크 | `Flutter 3.x` | UI 렌더링 |
| 상태관리 | `Provider 6.x` | 전역 상태 관리 (8개 Provider) |
| 라우팅 | `go_router 14.x` | 선언적 라우팅, 인증 리다이렉트, StatefulShellRoute |
| HTTP 통신 | `Dio 5.x` | REST API 호출, JWT 인터셉터, 토큰 자동 갱신 |
| 지도 | `flutter_naver_map` | 지도 렌더링, 마커, 경로 폴리라인 |
| GPS | `geolocator 13.x` | 위치 추적, 정상 인증 |
| 로컬 DB | `Hive 2.x` | 오프라인 캐싱, 도장 기록, 앱 설정 영속화 |
| 이미지 | `cached_network_image` | 산 썸네일 캐싱 |
| 사진 | `image_picker` | 갤러리/카메라 이미지 선택, 프로필/기록 사진 첨부 |
| 알림 | `firebase_messaging` + `flutter_local_notifications` | FCM 푸시 + 포그라운드 로컬 알림 |
| 다국어 | `flutter_localizations` + `intl` | 한국어/영어 l10n, 날짜 포맷 통일 |
| 환경 변수 | `flutter_dotenv` | `.env.example` 파일에서 API 키 로드 |
| 보안 저장소 | `flutter_secure_storage` | JWT 토큰 암호화 저장 (Keychain / EncryptedSharedPreferences) |
| 유틸 | `permission_handler` | 권한 관리 |

---

### 보안

| 항목 | 전략 |
|------|------|
| API 키 | `.env.example`에서 로드, CI/CD에서 실제 키 주입 |
| JWT 토큰 | `flutter_secure_storage`로 암호화 저장 (iOS Keychain, Android EncryptedSharedPreferences) |
| 토큰 갱신 | `QueuedInterceptorsWrapper`로 401 발생 시 자동 갱신, 갱신 실패 시 토큰 삭제 |
| API 응답 | 모든 Remote DataSource에서 응답 타입 검증 (`is! List` 가드, 명시적 캐스팅) |

---

### 에러 처리 전략

모든 레이어에서 일관된 에러 처리를 적용합니다.

| 레이어 | 전략 | 세부 사항 |
|--------|------|-----------|
| DataSource | 예외 발생 | `DioException` → 커스텀 `AppException` 변환, 응답 타입 검증 |
| Repository | `debugPrint` + 폴백 | 원격 실패 시 로컬 캐시/기본값으로 폴백, 동기화 실패 로깅 |
| Provider | `isLoading` / `error` 상태 관리 | UI에서 Consumer로 상태별 렌더링 |
| Screen | 로딩/에러/빈 상태 UI | `CircularProgressIndicator`, `EmptyState`, 에러 메시지 |
| Service | `debugPrint` + 안전한 실패 | FCM 토큰 등록, 알림 라우팅 실패 시 앱 크래시 방지 |

**커스텀 예외 클래스**

| 예외 | 용도 |
|------|------|
| `AppException` | 기본 예외 (message + statusCode) |
| `AuthException` | 인증 실패 (토큰 없음, 만료 등) |
| `NetworkException` | 네트워크 연결 실패 |
| `ServerException` | 서버 오류 (4xx/5xx) |
| `CacheException` | 로컬 캐시 읽기 실패 |

---

### 폴더 구조

```
lib/
├── main.dart                          # 앱 진입점, dotenv 로드, Provider 등록, 동적 테마/로케일
│
├── core/
│   ├── api_client.dart                # Dio + FlutterSecureStorage, JWT 인터셉터, 토큰 갱신
│   ├── constants.dart                 # dotenv 기반 설정 로드, Hive box 이름, Cache TTL
│   └── exceptions.dart                # 커스텀 에러 클래스 (Auth/Network/Server/Cache)
│
├── router/
│   └── app_router.dart                # GoRouter 설정, 인증 리다이렉트, ShellScaffold, 안전한 파라미터 처리
│
├── models/                            # Domain 모델
│   ├── mountain.dart                  # 산 정보 + Difficulty enum + 좌표
│   ├── hiking_plan.dart               # 등산 계획 + 체크리스트
│   ├── hiking_record.dart             # 산행 기록 (GPS 경로, 사진, 고도 포함)
│   ├── stamp.dart                     # 도장 기록
│   ├── user.dart                      # 유저 정보
│   └── weather.dart                   # 날씨 데이터
│
├── repositories/                      # Data Layer — 서버/로컬 추상화, 동기화 실패 로깅
│   ├── auth_repository.dart           # 로그인, 가입, 프로필 업데이트, 토큰 검증
│   ├── mountain_repository.dart       # 산 목록 (캐시 → 원격 → 기본값 폴백)
│   ├── plan_repository.dart           # 계획/체크리스트/기록 CRUD
│   ├── stamp_repository.dart          # 도장 저장/조회
│   └── weather_repository.dart        # 날씨 캐시 → 원격 폴백
│
├── datasources/
│   ├── remote/                        # REST API 호출 (응답 타입 검증 포함)
│   │   ├── auth_remote.dart           # 인증 + 프로필 업데이트
│   │   ├── mountain_remote.dart
│   │   ├── plan_remote.dart
│   │   ├── stamp_remote.dart
│   │   └── weather_remote.dart        # OpenWeatherMap API
│   └── local/                         # Hive 로컬 캐시
│       ├── mountain_local.dart        # 24시간 TTL
│       ├── plan_local.dart
│       ├── stamp_local.dart
│       └── weather_local.dart         # 3시간 TTL
│
├── providers/                         # 상태관리 (ChangeNotifier) — isLoading/error 패턴
│   ├── auth_provider.dart             # 로그인, 가입, 프로필 업데이트
│   ├── mountain_provider.dart         # 추천 코스, 산행 기록, 검색, 로딩/에러 상태
│   ├── plan_provider.dart             # 계획, 체크리스트, 상태 토글
│   ├── stamp_provider.dart            # 도장 현황, 범위 검사
│   ├── weather_provider.dart          # 날씨 데이터, 로딩/에러 상태
│   ├── settings_provider.dart         # 다크 모드, 알림, 언어 설정 (Hive 영속화)
│   ├── location_provider.dart         # GPS 위치, 추적 상태, 스트림 중복 방어, 에러 로깅
│   └── tracking_provider.dart         # 실시간 등산 추적 (경로, 시간, 거리, 정상 감지, 다이얼로그 상태)
│
├── services/
│   ├── location_service.dart          # Geolocator 래퍼, 정상 인증 (isNearSummit)
│   ├── notification_service.dart      # FCM + 로컬 알림, GoRouter 기반 화면 이동
│   └── image_service.dart             # image_picker 래퍼 (갤러리/카메라)
│
├── screens/
│   ├── home_screen.dart               # 코스 추천 + 날씨 + 통계 + 기록 + 로딩/에러 상태
│   ├── plan_screen.dart               # 등산 계획 + 상태 토글 + 체크리스트 + DateFormat
│   ├── stamp_screen.dart              # 도장 컬렉션 + 빈 상태
│   ├── map_screen.dart                # 네이버 지도 + 산 마커 + 상세 연결
│   ├── login_screen.dart              # 로그인 (이메일 정규식, 에러 초기화)
│   ├── signup_screen.dart             # 회원가입 (이메일 정규식, 에러 초기화)
│   ├── mountain_detail_screen.dart    # 산 상세 정보 + 등산 시작
│   ├── profile_screen.dart            # 프로필 사진 변경 + 설정 토글 (다크모드/알림/언어)
│   ├── record_create_screen.dart      # 수동 기록 추가 + 사진 첨부 (웹/네이티브 분기)
│   ├── tracking_screen.dart           # NaverMap 실시간 경로 (네이티브) + 폴백 (웹) + Listener 다이얼로그
│   └── search_screen.dart             # 산 검색 + 난이도/지역 동적 필터
│
├── widgets/                           # 재사용 컴포넌트
│   ├── mountain_card.dart             # 산 카드 + DifficultyTag + CachedNetworkImage
│   ├── plan_card.dart                 # 계획 카드 (Dismissible + 상태 토글)
│   ├── stamp_tile.dart                # 도장 타일 + 상세 모달
│   ├── weather_card.dart              # 날씨 카드 (동적 메시지, 로딩/에러 표시)
│   ├── empty_state.dart               # 공유 빈 상태 위젯
│   └── checklist_card.dart            # 준비물 체크리스트 (애니메이션)
│
├── theme/
│   └── app_theme.dart                 # Light/Dark 테마, 색상, 버튼 스타일, cardTheme
│
└── l10n/
    ├── app_ko.arb                     # 한국어 (80+ 키)
    └── app_en.arb                     # 영어

test/                                  # 123개 테스트, 17개 파일
├── core/
│   └── exceptions_test.dart
├── models/
│   ├── mountain_test.dart
│   ├── weather_test.dart
│   ├── user_test.dart
│   ├── hiking_record_test.dart
│   └── hiking_record_extended_test.dart
├── providers/
│   ├── auth_provider_test.dart
│   ├── mountain_provider_test.dart     # isLoading/error 테스트 포함
│   ├── mountain_provider_search_test.dart
│   ├── plan_provider_test.dart         # updatePlanStatus 테스트 포함
│   ├── stamp_provider_test.dart        # 범위 검사 테스트 포함
│   ├── weather_provider_test.dart
│   └── tracking_provider_test.dart
├── repositories/
│   ├── auth_repository_test.dart
│   ├── mountain_repository_test.dart
│   └── weather_repository_test.dart
└── widget_test.dart
```

---

### 네비게이션 (GoRouter)

| 경로 | 화면 | 설명 |
|------|------|------|
| `/login` | LoginScreen | 로그인 |
| `/signup` | SignupScreen | 회원가입 |
| `/home` | HomeScreen | 홈 (Shell 탭 0) |
| `/plan` | PlanScreen | 계획 (Shell 탭 1) |
| `/stamp` | StampScreen | 도장 (Shell 탭 2) |
| `/map` | MapScreen | 지도 (Shell 탭 3) |
| `/mountain/:id` | MountainDetailScreen | 산 상세 (파라미터 null 안전 처리) |
| `/profile` | ProfileScreen | 프로필/설정 |
| `/record/new` | RecordCreateScreen | 기록 추가 + 사진 첨부 |
| `/tracking?mountainId=` | TrackingScreen | 실시간 추적 + NaverMap 경로 |
| `/search` | SearchScreen | 산 검색 + 동적 필터 |

인증 리다이렉트: 미로그인 시 → `/login`, 로그인 후 `/login` 접근 시 → `/home`

---

### 레이어 설계

Clean Architecture 3-레이어 구조를 따릅니다.

```
┌──────────────────────────────────┐
│       Presentation Layer         │  screens/ + widgets/ + providers/
│  UI 렌더링, 사용자 이벤트 처리     │
└──────────────┬───────────────────┘
               │ 데이터 요청
┌──────────────▼───────────────────┐
│         Domain Layer             │  models/ + services/
│  비즈니스 로직, 데이터 모델 정의   │
└──────────────┬───────────────────┘
               │ 저장/조회
┌──────────────▼───────────────────┐
│          Data Layer              │  repositories/ + datasources/
│  API 통신, 로컬 캐시 추상화        │
└──────────────────────────────────┘
```

**핵심 원칙**
- 상위 레이어는 하위 레이어에 의존하지 않음
- Repository가 Remote/Local 중 어디서 데이터를 가져올지 결정
- 오프라인 상태에서는 Hive 로컬 캐시로 폴백
- 모든 레이어에서 에러를 `debugPrint`로 기록하고 안전하게 폴백

---

### 상태관리 흐름

```
사용자 액션 (버튼 탭)
        │
        ▼
   Provider.notifyListeners()
        │
   ┌────┴────┐
   │         │
isLoading  error
   │         │
   ▼         ▼
   Repository.getData()
        │
   ┌────┴────┐
   │         │
   ▼         ▼
Remote     Local
(Dio)     (Hive)
   │         │
   └────┬────┘
        │
        ▼
   모델 변환 (JSON → Dart)
        │
        ▼
   UI 자동 리빌드 (Consumer<Provider>)
        │
   ┌────┴────┬────────┐
   ▼         ▼        ▼
로딩 UI   에러 UI   데이터 UI
```

**Provider 목록**

| Provider | 관리 상태 | 로딩/에러 |
|----------|---------|-----------|
| `AuthProvider` | 로그인 상태, JWT 토큰, 프로필 업데이트 | O |
| `MountainProvider` | 추천 코스 목록, 산행 기록, 통계, 검색 | O |
| `PlanProvider` | 예정된 계획 목록, 체크리스트, 상태 토글 | - |
| `StampProvider` | 도장 현황, 함께 도장 목록, 범위 검사 | - |
| `WeatherProvider` | 날씨 데이터 (3시간 캐싱) | O |
| `SettingsProvider` | 다크 모드, 알림, 언어 설정 (Hive 영속화) | - |
| `LocationProvider` | GPS 위치, 추적 상태, 스트림 에러 핸들링 | - |
| `TrackingProvider` | 실시간 추적 (경로, 시간, 거리, 속도, 정상 감지, 다이얼로그 상태) | O (권한 에러) |

---

### 다크 모드 지원

모든 화면과 컴포넌트가 Light/Dark 테마를 지원합니다.
프로필 > 설정에서 수동 전환 가능하며, 설정값은 Hive에 영속화됩니다.

| 항목 | Light | Dark |
|------|-------|------|
| 배경 | `#F8F6F1` | `#121212` |
| 표면 | `#FFFFFF` | `#1E1E1E` |
| 텍스트 (주) | `#1C1C1E` | `#E0E0E0` |
| 텍스트 (보조) | `#6B7280` | `#9E9E9E` |
| 바텀시트 | `scaffoldBackgroundColor` 동적 적용 |
| 바텀네비 | 테마 brightness 기반 분기 |

---

### 입력 검증

| 화면 | 검증 항목 |
|------|-----------|
| 로그인/회원가입 | 이메일 정규식 (`^[a-zA-Z0-9._%+-]+@...`) |
| 회원가입 | 닉네임 2자 이상, 비밀번호 6자 이상 |
| 기록 추가 | 산 선택 필수, 날짜 필수, 거리 > 0, 소요시간 > 0 |
| 계획 추가 | 산 선택 필수, 날짜 필수 |

---

### 로컬 저장소 전략

| 데이터 | 저장소 | 만료 |
|--------|--------|------|
| JWT 토큰 | `flutter_secure_storage` | 로그아웃 시 삭제 |
| 앱 설정 (테마, 언어, 알림) | `Hive` (settings) | 영구 |
| 산 목록 캐시 | `Hive` | 24시간 |
| 도장 기록 | `Hive` | 영구 (서버 동기화) |
| 계획/기록 | `Hive` | 영구 |
| 날씨 데이터 | `Hive` | 3시간 |

---

### 웹 호환성

| 기능 | 네이티브 (iOS/Android) | 웹 (Chrome) |
|------|----------------------|-------------|
| 지도 | NaverMap 렌더링 | 미지원 (NaverMap SDK 미지원) |
| 추적 지도 | NaverMap + 실시간 폴리라인 | 그라데이션 폴백 UI |
| 사진 첨부 | `Image.file` (로컬 경로) | `Image.network` (blob URL) |
| GPS | Geolocator (네이티브) | 브라우저 Geolocation API |
| 보안 저장소 | Keychain / EncryptedSharedPreferences | sessionStorage (제한적) |

---

### 설정 필요 항목

앱 실행 전 아래 설정이 필요합니다:

**1. 환경 변수 설정**

`.env.example` 파일의 플레이스홀더를 실제 값으로 교체:

```
API_BASE_URL=http://localhost:8000
NAVER_MAP_CLIENT_ID=실제_네이버_클라이언트_ID
WEATHER_API_KEY=실제_OpenWeatherMap_API_키
```

> `.env.example`은 에셋 번들에 포함되어 앱에서 직접 로드합니다. 실제 키를 커밋하지 않으려면 CI/CD에서 빌드 전 파일을 교체하세요.

**2. 플랫폼별 설정**

| 항목 | 파일 | 설명 |
|------|------|------|
| Naver Map Client ID | `AndroidManifest.xml`, `Info.plist` | 네이버 클라우드 콘솔에서 발급 |
| Firebase | `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist` | Firebase Console에서 다운로드 |

---

## 시작하기

```bash
# 의존성 설치
flutter pub get

# 실행 (모바일)
flutter run

# 실행 (웹)
flutter run -d chrome

# 분석
flutter analyze

# 테스트 (123개)
flutter test
```
