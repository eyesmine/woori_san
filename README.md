# 우리산

함께 산을 오르는 즐거움을 기록하는 등산 앱

## 주요 기능

### 홈
- 이번 주 추천 등산 코스 (사용자 GPS 위치 기반 백엔드 추천 API 연동)
- 날씨 카드 (실시간 GPS 기반 날씨, 조건별 동적 메시지, 일출/일몰 시간)
- 함께한 산행 통계 (산행 횟수, 총 거리, 획득 도장)
- 최근 산행 기록 → 탭하면 기록 상세 화면 (고도 프로필, 경로 지도)
- Pull-to-refresh 지원 (위치 기반 추천 + 날씨 새로고침)
- 로딩/에러/빈 상태 UI
- 검색 / 프로필 바로가기

### 산 상세
- 산 정보 (고도, 난이도, 코스 거리/시간, 위치 좌표)
- 코스 정보 카드
- 즐겨찾기 하트 아이콘 (우상단)
- 리뷰 섹션 (최근 3개 미리보기 + 전체보기)
- 위치 지도 (NaverMap terrain 모드, 마커 + 인터랙티브 제스처)
- "등산 시작" 버튼 → 실시간 추적 화면 연결
- 잘못된 산 ID 접근 시 에러 화면

### 검색
- 산 이름 / 지역 검색 (3,607개 전국 산 대상)
- 동명이산 구분: 지역명 함께 표시 (예: "국사봉" - 경기 / "국사봉" - 강원)
- 난이도 필터 (초급 / 중급 / 상급)
- 지역 필터 (산 데이터에서 동적 추출)

### 계획
- 등산 계획 추가 (산 선택 + 날짜)
- 계획 상태 토글 (확정 / 조율 중) — 탭으로 전환
- 스와이프로 계획 삭제
- 준비물 체크리스트 (항목 추가/삭제 가능, 스와이프 삭제)

### 도장 컬렉션
- 100대 명산 도전 진행률
- 혼자 도장 / 함께 도장 구분
- 함께 오른 산 별도 표시
- 정상 도착 시 GPS 인증 자동 도장 (`POST /api/stamps/` → 서버 100m 검증)
- 서버 실패 시 로컬 fallback 저장
- 함께 찍은 도장 / 100대 명산 진행률 API 연동
- 빈 상태 UI

### 지도
- 네이버 지도 기반 산 위치 표시 (100개 마커)
- 마커 탭으로 산 상세 정보 확인 → 상세 화면 이동
- 현재 위치 이동

### 실시간 등산 추적
- 네이티브: NaverMap 실시간 경로 폴리라인 + 산 마커 (웹: 그라데이션 폴백)
- GPS 기반 경로 추적 (위치 + 고도 포인트 기록)
- 경과 시간, 거리, 속도 실시간 표시
- 일시정지 / 재개 / 종료
- 긴급 SOS 버튼 (AppBar, 비상연락처로 현재 위치 SMS 전송)
- 정상 도착 자동 감지 → 서버 도장 API 호출 (GPS 검증) → 실패 시 로컬 fallback
- 종료 시 HikingRecord 자동 생성 (고도 데이터 포함)
- 위치 권한 거부 시 에러 화면

### 기록 상세
- 산 이름, 날짜, 거리, 소요 시간, 누적 상승 표시
- 고도 프로필 그래프 (fl_chart LineChart, 최고/최저 고도 표시)
- 경로 지도 (NaverMap 폴리라인 + 출발/도착 마커)
- SNS 공유 버튼 (기록 이미지 생성 → 공유)

### 기록 추가
- 수동 산행 기록 입력 (산 선택, 날짜, 시간, 거리)
- 사진 첨부 (갤러리에서 다중 선택, 미리보기, 삭제, 10MB 제한)
- 소요 시간 / 거리 입력 검증
- 기존 기록 목록에 즉시 반영

### 통계 대시보드
- 총 등산 횟수, 누적 거리, 평균 소요 시간 요약 카드
- 월별 등산 횟수 막대 차트 (fl_chart BarChart)
- 누적 거리 꺾은선 차트 (fl_chart LineChart)
- 연도별 필터 (ChoiceChip)

### 배지/업적
- 100종 배지 (횟수/거리/고도/지역/도장/함께/시간/꾸준함/도전/스페셜 10개 카테고리)
- 획득/미획득 그리드 표시 (2열)
- 배지 탭 → 상세 설명 바텀시트
- 진행도 바 + 진행 문자열 (예: "5 / 10")
- 등산 기록/도장 변경 시 자동 평가
- 새 배지 획득 시 홈 화면 스낵바 알림

### 즐겨찾기
- 산 상세 화면에서 하트 아이콘으로 즐겨찾기 토글
- 즐겨찾기 목록 화면 (프로필에서 접근)

### 파트너
- 파트너 등록/해제 (백엔드 API 연동)
- 파트너 정보 카드 표시
- 확인 다이얼로그로 안전한 해제

### 산 리뷰
- 산별 리뷰 목록 (별점, 내용, 사진, 작성일)
- 리뷰 작성 (별점 선택 + 텍스트 500자, 비로그인 시 안내)
- 본인 리뷰 삭제 (확인 다이얼로그)
- 실패 시 에러 메시지 SnackBar 표시
- Pull-to-refresh 지원

### 긴급 SOS
- 비상 연락처 설정 (이름, 전화번호)
- 등산 중 SOS 버튼 → 현재 GPS 좌표를 SMS로 전송
- Google Maps 링크 포함

### 오프라인 지도
- 산별 지도 미리 불러오기 (SDK 캐시 워밍)
- 캐시 상태 표시 및 삭제

### 프로필 / 설정
- 사용자 정보 (닉네임, 이메일, 가입일)
- 프로필 사진 변경 (갤러리/카메라, 10MB 제한)
- 산행 통계 요약
- 설정 타일: 통계, 배지, 즐겨찾기, 파트너, 알림, 다크 모드, 언어, 오프라인 지도, 비상 연락처, 앱 정보
- 로그아웃 (확인 다이얼로그)

### 인증
- 이메일/비밀번호 로그인, 회원가입 (username 자동 생성)
- 이메일 정규식 검증
- 로그인 흐름: `POST /auth/login/` → JWT 발급 → `GET /auth/me/` 프로필 조회
- JWT 토큰 자동 갱신 (QueuedInterceptorsWrapper)
- 429 Rate Limit 처리 (RateLimitException → 안내 메시지)
- GoRouter 기반 인증 리다이렉트

### 알림
- Firebase Cloud Messaging 푸시 알림 (FCM HTTP v1 API)
- 포그라운드: flutter_local_notifications로 표시
- 알림 탭 시 GoRouter 기반 화면 이동
- 토픽 구독/해제 (weather_alerts, hiking_tips)
- FCM 토큰 서버 등록 (`POST /api/devices/`)
- iOS APNS 토큰 대기 처리 (크래시 방지)

---

### Client 기술 스택

| 분류 | 라이브러리 | 용도 |
|------|-----------|------|
| 프레임워크 | `Flutter 3.x` | UI 렌더링 |
| 상태관리 | `Provider 6.x` | 전역 상태 관리 (12개 Provider) |
| 라우팅 | `go_router 14.x` | 선언적 라우팅, 인증 리다이렉트, StatefulShellRoute |
| HTTP 통신 | `Dio 5.x` | REST API 호출, JWT 인터셉터, 토큰 자동 갱신, 재시도 로직 |
| 지도 | `flutter_naver_map` | 지도 렌더링, 마커, 경로 폴리라인 |
| GPS | `geolocator 13.x` | 위치 추적, 정상 인증 |
| 로컬 DB | `Hive 2.x` | 오프라인 캐싱, 도장/즐겨찾기/배지/설정 영속화 |
| 차트 | `fl_chart` | 통계 막대/꺾은선 차트, 고도 프로필 그래프 |
| 이미지 | `cached_network_image` | 산 썸네일 캐싱 |
| 사진 | `image_picker` | 갤러리/카메라 이미지 선택, 10MB 제한 |
| 알림 | `firebase_messaging` + `flutter_local_notifications` | FCM 푸시 + 포그라운드 로컬 알림 (iOS APNS 대기 처리) |
| Firebase | `firebase_core` | Firebase 초기화 (`firebase_options.dart` 기반) |
| 공유 | `share_plus` + `screenshot` | 등산 기록 이미지 생성 → SNS 공유 |
| SMS | `url_launcher` | 긴급 SOS SMS 발송 |
| 다국어 | `flutter_localizations` + `intl` + `AppLocalizations` | 한국어/영어 l10n (~190키) |
| 환경 변수 | `flutter_dotenv` | `.env.example` 파일에서 API 키 로드 |
| 보안 저장소 | `flutter_secure_storage` | JWT 토큰 암호화 저장 |
| 유틸 | `permission_handler` | 권한 관리 |
| 앱 아이콘 | `flutter_launcher_icons` | iOS/Android 아이콘 자동 생성 |
| 스플래시 | `flutter_native_splash` | 네이티브 스플래시 화면 (Light/Dark) |

---

### 보안

| 항목 | 전략 |
|------|------|
| API 키 | `.env.example`에서 로드, CI/CD에서 실제 키 주입 |
| Firebase 키 | `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart` — `.gitignore`에 등록 |
| JWT 토큰 | `flutter_secure_storage`로 암호화 저장 |
| 토큰 갱신 | `QueuedInterceptorsWrapper`로 401 발생 시 자동 갱신, 실패 시 토큰 삭제 |
| 네트워크 재시도 | Exponential backoff (최대 3회), 408/429/5xx 대상 |
| Rate Limit | 429 응답 시 `RateLimitException` → 안내 메시지 |
| 이미지 업로드 | 클라이언트 10MB 제한 체크 |
| API 응답 | 모든 Remote DataSource에서 응답 타입 검증, DRF pagination 대응 |
| 에러 응답 | 구조화된 에러 포맷 파싱, 레거시 포맷 fallback |
| 에러 핸들링 | Provider별 `NetworkException`/`ValidationException`/`AuthException` 구분 처리 |
| 입력 검증 | `Validators` 유틸리티 — 이메일/비밀번호/닉네임 검증 + XSS sanitize |

---

### 백엔드 API 연동

Django REST Framework 기반 백엔드와 연동합니다. Base URL: `http://localhost:8000/api`

**인증 `/api/auth/`**

| Method | Endpoint | 설명 | Flutter 호출 |
|--------|----------|------|-------------|
| POST | `/api/auth/register/` | 회원가입 | `AuthRemoteDataSource.signup()` |
| POST | `/api/auth/login/` | 로그인 → JWT 발급 | `AuthRemoteDataSource.login()` |
| POST | `/api/auth/refresh/` | Access Token 갱신 | `ApiClient._refreshToken()` |
| POST | `/api/auth/logout/` | 로그아웃 (Refresh Token 블랙리스트) | `AuthRemoteDataSource.logout()` |
| GET | `/api/auth/me/` | 내 프로필 조회 (partner_id, partner_nickname 포함) | `AuthRemoteDataSource.getProfile()` |
| PATCH | `/api/auth/me/` | 프로필 수정 | `AuthRemoteDataSource.updateProfile()` |
| POST | `/api/auth/partner/` | 파트너 등록 | `AuthRemoteDataSource.registerPartner()` |
| DELETE | `/api/auth/partner/` | 파트너 해제 | `AuthRemoteDataSource.removePartner()` |

**산 & 코스 `/api/mountains/`**

| Method | Endpoint | 설명 | Flutter 호출 |
|--------|----------|------|-------------|
| GET | `/api/mountains/` | 산 목록 (필터: region, difficulty, min_height, max_height) | `MountainRemoteDataSource.getMountains()` |
| GET | `/api/mountains/{id}/` | 산 상세 | `MountainRemoteDataSource.getDetail()` |
| GET | `/api/mountains/recommend/?lat=&lng=&radius=` | 위치 기반 추천 (계절/미방문 산 고려, radius>0 필수) | `MountainRemoteDataSource.getRecommended()` |
| GET | `/api/mountains/{id}/courses/` | 코스 목록 (상세 응답 courses 배열에도 포함) | `MountainRemoteDataSource.getCourses()` |

**리뷰 `/api/mountains/{id}/reviews/`**

| Method | Endpoint | 설명 | Flutter 호출 |
|--------|----------|------|-------------|
| GET | `/api/mountains/{id}/reviews/` | 리뷰 목록 (DRF pagination) | `ReviewRemoteDataSource.getReviews()` |
| POST | `/api/mountains/{id}/reviews/` | 리뷰 작성 → 생성된 리뷰 객체 반환 | `ReviewRemoteDataSource.createReview()` |
| DELETE | `/api/reviews/{id}/` | 리뷰 삭제 (본인만) | `ReviewRemoteDataSource.deleteReview()` |

**등산 계획 `/api/plans/`**

| Method | Endpoint | 설명 | Flutter 호출 |
|--------|----------|------|-------------|
| GET | `/api/plans/` | 내 계획 목록 | `PlanRemoteDataSource.getPlans()` |
| POST | `/api/plans/` | 계획 생성 | `PlanRemoteDataSource.createPlan()` |
| GET | `/api/plans/{id}/` | 계획 상세 | `PlanRemoteDataSource.getPlan()` |
| PUT | `/api/plans/{id}/` | 계획 수정 | `PlanRemoteDataSource.updatePlan()` |
| DELETE | `/api/plans/{id}/` | 계획 삭제 (Soft Delete) | `PlanRemoteDataSource.deletePlan()` |
| POST | `/api/plans/{id}/invite/` | 파트너 초대 | `PlanRemoteDataSource.invitePartner()` |
| PATCH | `/api/plans/{id}/status/` | 상태 변경 | `PlanRemoteDataSource.updateStatus()` |
| GET | `/api/plans/{id}/checklist/` | 체크리스트 조회 | `PlanRemoteDataSource.getChecklist()` |
| POST | `/api/plans/{id}/checklist/` | 체크리스트 항목 추가 | `PlanRemoteDataSource.addChecklistItem()` |
| PATCH | `/api/plans/{id}/checklist/{item_id}/` | 체크 항목 토글 | `PlanRemoteDataSource.toggleChecklistItem()` |

**도장 `/api/stamps/`**

| Method | Endpoint | 설명 | Flutter 호출 |
|--------|----------|------|-------------|
| GET | `/api/stamps/` | 내 도장 전체 목록 | `StampRemoteDataSource.getStamps()` |
| POST | `/api/stamps/` | 도장 찍기 (GPS 100m 이내 검증, Soft Delete) | `StampRemoteDataSource.createStamp()` |
| GET | `/api/stamps/together/` | 함께 찍은 도장 | `StampRemoteDataSource.getTogetherStamps()` |
| GET | `/api/stamps/progress/` | 100대 명산 진행률 | `StampRemoteDataSource.getProgress()` |

**백엔드 ↔ Flutter 필드 매핑**

| 모델 | 백엔드 필드 | Flutter 필드 | 비고 |
|------|-----------|-------------|------|
| **JWT** | `access`, `refresh` | `accessToken`, `refreshToken` | 로그인/갱신 응답 |
| **User** | `profile_image`, `created_at`, `partner_id`, `partner_nickname` | `profileImageUrl`, `createdAt`, `partnerId`, `partnerNickname` | |
| **Mountain** | `region`, `lat`/`lng`, `thumbnail`, `easy`/`mid`/`hard`, `courses` | `location`, `latitude`/`longitude`, `imageUrl`, `초급`/`중급`/`상급`, `courses` | courses: 상세 응답에 포함 |
| **HikingPlan** | `planned_at`, `mountain` (int), `mountain_name` | `date`, `mountainId`, `mountain` | `status`: `pending`/`confirmed`/`done` |
| **Stamp** | `mountain_name`, `stamped_at`, `is_together` | `name`, `stampDate`, `isTogetherStamped` | `stamped_at` 존재 → `isStamped: true` |
| **Review** | `mountain_id`, `user_id`, `user_nickname`, `profile_image`, `photo_urls`, `created_at` | `mountainId`, `userId`, `userNickname`, `userProfileImageUrl`, `photoUrls`, `createdAt` | POST 응답: 생성된 리뷰 객체 반환 |
| **Weather** | OpenWeatherMap `sys.sunrise`/`sys.sunset` | `sunrise`, `sunset` (DateTime) | Unix timestamp → DateTime |
| **에러 응답** | `{"error": {"code", "message", "details"}}` | `AppException` 계열 | 레거시 포맷 호환 |

---

### 커스텀 예외 클래스

| 예외 | 필드 | 용도 |
|------|------|------|
| `AppException` | `message`, `statusCode`, `code` | 기본 예외 |
| `AuthException` | + `code` | 인증 실패 |
| `ValidationException` | + `fieldErrors`, `firstFieldError` | 필드별 유효성 검증 에러 |
| `ServerException` | + `code` | 서버 오류 |
| `NetworkException` | - | 네트워크 연결 실패 |
| `CacheException` | - | 로컬 캐시 읽기 실패 |
| `RateLimitException` | - | 429 Rate Limit 초과 |

---

### 폴더 구조

```
lib/
├── main.dart                          # 앱 진입점, Firebase/Hive/NaverMap 초기화
├── firebase_options.dart              # FlutterFire CLI 생성 (Firebase 앱 설정)
│
├── core/
│   ├── api_client.dart                # Dio, JWT 인터셉터, 재시도 로직, Rate Limit 처리
│   ├── badge_evaluator.dart           # 100종 배지 평가/진행도 로직 (순수 클래스)
│   ├── constants.dart                 # dotenv 설정, Hive box 이름 (8개), Cache TTL
│   ├── di.dart                        # DI 컨테이너 (DataSource/Repo/Provider 초기화)
│   ├── exceptions.dart                # 7개 커스텀 에러 클래스
│   ├── logger.dart                    # 구조화된 로거 (debug/info/warning/error)
│   └── validators.dart               # 입력 유효성 검증 + XSS sanitize
│
├── router/
│   └── app_router.dart                # GoRouter (22개 라우트), 인증 리다이렉트
│
├── models/
│   ├── mountain.dart                  # 산 정보 + Difficulty enum + 100대 명산 데이터
│   ├── hiking_plan.dart               # 등산 계획 + 체크리스트
│   ├── hiking_record.dart             # 산행 기록 (GPS 경로, 고도, 사진)
│   ├── stamp.dart                     # 도장 기록 + 100대 명산 스탬프 데이터
│   ├── user.dart                      # 유저 정보 (파트너 필드 포함)
│   ├── weather.dart                   # 날씨 데이터 (일출/일몰 포함)
│   ├── review.dart                    # 산 리뷰
│   └── badge.dart                     # 배지/업적 (100종 정의, 10개 카테고리)
│
├── repositories/
│   ├── auth_repository.dart           # 인증 + 파트너 관리
│   ├── mountain_repository.dart       # 산 목록 (위치 기반 추천)
│   ├── plan_repository.dart           # 계획/체크리스트/기록 CRUD
│   ├── stamp_repository.dart          # 도장 생성(GPS), 서버 동기화
│   ├── weather_repository.dart        # 날씨 캐시 → 원격 폴백
│   └── review_repository.dart         # 리뷰 CRUD (캐시 지원)
│
├── datasources/
│   ├── remote/                        # REST API 호출
│   │   ├── auth_remote.dart
│   │   ├── mountain_remote.dart
│   │   ├── plan_remote.dart
│   │   ├── stamp_remote.dart
│   │   ├── weather_remote.dart
│   │   └── review_remote.dart
│   └── local/                         # Hive 로컬 캐시
│       ├── mountain_local.dart
│       ├── plan_local.dart
│       ├── stamp_local.dart
│       ├── weather_local.dart
│       ├── favorite_local.dart
│       ├── review_local.dart
│       └── badge_local.dart
│
├── providers/                         # 상태관리 (12개 ChangeNotifier)
│   ├── auth_provider.dart             # 로그인, 가입, 파트너, 예외별 에러 메시지
│   ├── mountain_provider.dart         # 추천 코스 (위치 기반), 검색
│   ├── plan_provider.dart             # 계획, 체크리스트 (추가/삭제)
│   ├── stamp_provider.dart            # 도장 현황, GPS 도장 생성
│   ├── weather_provider.dart          # 날씨 데이터
│   ├── settings_provider.dart         # 다크 모드, 알림, 언어, 비상 연락처
│   ├── location_provider.dart         # GPS 위치
│   ├── tracking_provider.dart         # 실시간 등산 추적 (고도 기록)
│   ├── favorite_provider.dart         # 산 즐겨찾기
│   ├── statistics_provider.dart       # 통계 계산 (월별/연도별, 캘린더, 최고기록)
│   ├── review_provider.dart           # 산 리뷰 CRUD
│   └── badge_provider.dart            # 배지 상태관리 (평가 로직은 BadgeEvaluator에 위임)
│
├── services/
│   ├── location_service.dart          # Geolocator 래퍼, 정상 인증
│   ├── notification_service.dart      # FCM + 로컬 알림
│   ├── sos_service.dart               # 긴급 SOS SMS 발송
│   └── share_service.dart             # 등산 기록 이미지 공유
│
├── screens/                           # 19개 화면
│   ├── home_screen.dart               # 추천 코스 + 날씨 + 통계 + 기록
│   ├── plan_screen.dart               # 등산 계획 + 체크리스트
│   ├── stamp_screen.dart              # 도장 컬렉션
│   ├── map_screen.dart                # 네이버 지도 + 100개 마커
│   ├── login_screen.dart              # 로그인
│   ├── signup_screen.dart             # 회원가입
│   ├── mountain_detail_screen.dart    # 산 상세 + 즐겨찾기 + 리뷰
│   ├── profile_screen.dart            # 프로필 + 11개 설정 타일
│   ├── record_create_screen.dart      # 수동 기록 추가
│   ├── record_detail_screen.dart      # 기록 상세 (고도/경로/공유)
│   ├── tracking_screen.dart           # 실시간 추적 + SOS
│   ├── search_screen.dart             # 산 검색 + 필터
│   ├── statistics_screen.dart         # 통계 대시보드 (차트)
│   ├── favorites_screen.dart          # 즐겨찾기 목록
│   ├── partner_screen.dart            # 파트너 관리
│   ├── reviews_screen.dart            # 리뷰 목록 + 작성
│   ├── badge_screen.dart              # 배지 그리드
│   ├── sos_settings_screen.dart       # 비상 연락처 설정
│   └── offline_map_settings_screen.dart # 오프라인 지도 관리
│
├── widgets/                           # 16개 재사용 컴포넌트
│   ├── mountain_card.dart             # 산 카드 + DifficultyTag
│   ├── plan_card.dart                 # 계획 카드 (Dismissible)
│   ├── stamp_tile.dart                # 도장 타일 + 상세 모달
│   ├── weather_card.dart              # 날씨 카드 (일출/일몰 포함)
│   ├── empty_state.dart               # 공유 빈 상태 위젯
│   ├── checklist_card.dart            # 체크리스트 (추가/삭제/스와이프)
│   ├── elevation_chart.dart           # 고도 프로필 차트 (fl_chart)
│   ├── route_map_widget.dart          # 경로 지도 (NaverMap 폴리라인)
│   ├── stats_chart.dart               # 월별/누적 통계 차트 (fl_chart)
│   ├── review_card.dart               # 리뷰 카드 (별점, 사진)
│   ├── review_form.dart               # 리뷰 작성 바텀시트
│   ├── share_record_card.dart         # SNS 공유용 기록 이미지
│   ├── badge_tile.dart                # 배지 타일 (획득/잠금)
│   ├── home_header_banner.dart        # 홈 헤더 배너
│   ├── home_stats_card.dart           # 홈 통계 카드
│   └── recent_record_tile.dart        # 최근 기록 타일
│
├── theme/
│   └── app_theme.dart                 # Light/Dark 테마, AppThemeColors extension
│
└── l10n/
    ├── app_ko.arb                     # 한국어 (~190키)
    └── app_en.arb                     # 영어 (~190키)

assets/
├── app_icon.png                       # 앱 아이콘 원본 (1024x1024)
└── splash_logo.png                    # 스플래시 로고 (512x512)

test/                                  # 194개 테스트, 24개 파일
├── core/
│   ├── exceptions_test.dart
│   ├── api_client_error_test.dart
│   ├── badge_evaluator_test.dart
│   ├── logger_test.dart
│   └── validators_test.dart
├── models/
│   ├── mountain_test.dart
│   ├── weather_test.dart
│   ├── user_test.dart
│   ├── hiking_record_test.dart
│   └── hiking_record_extended_test.dart
├── providers/
│   ├── auth_provider_test.dart
│   ├── mountain_provider_test.dart
│   ├── mountain_provider_search_test.dart
│   ├── plan_provider_test.dart
│   ├── stamp_provider_test.dart
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
| `/mountain/:id` | MountainDetailScreen | 산 상세 (즐겨찾기 + 리뷰) |
| `/mountain/:id/reviews` | ReviewsScreen | 리뷰 목록 + 작성 |
| `/profile` | ProfileScreen | 프로필/설정 |
| `/record/new` | RecordCreateScreen | 기록 추가 |
| `/record/:id` | RecordDetailScreen | 기록 상세 (고도/경로/공유) |
| `/tracking?mountainId=` | TrackingScreen | 실시간 추적 + SOS |
| `/search` | SearchScreen | 산 검색 |
| `/statistics` | StatisticsScreen | 통계 대시보드 |
| `/favorites` | FavoritesScreen | 즐겨찾기 목록 |
| `/partner` | PartnerScreen | 파트너 관리 |
| `/badges` | BadgeScreen | 배지/업적 |
| `/sos-settings` | SosSettingsScreen | 비상 연락처 설정 |
| `/offline-maps` | OfflineMapSettingsScreen | 오프라인 지도 |

인증 리다이렉트: 미로그인 시 → `/login`, 로그인 후 `/login` 접근 시 → `/home`

---

### 데이터

- **3,607개 산**: 산림청 전국 산 데이터 (100대 명산 + 전국 산, GPS 좌표, 높이, 난이도, 설명)
- **365개 등산 코스**: 227개 산에 코스 정보 (거리, 소요시간, 난이도), 코스 없는 산은 고도 기반 추정값
- **동명이산 대응**: id 기반 식별, 지역명 함께 표시
- **100개 도장**: 100대 명산에 대응하는 도장 데이터
- **100종 배지**: 횟수/거리/고도/지역/도장/함께/시간/꾸준함/도전/스페셜 10개 카테고리
- **6개 기본 체크리스트**: 등산화, 물, 간식, 방풍자켓, 스틱, 구급약

---

### 앱 아이콘 & 스플래시

커스텀 앱 아이콘과 스플래시 화면이 적용되어 있습니다.

- **앱 아이콘**: `assets/app_icon.png` (1024x1024) — 산 + 태양 + "우리산" 디자인
- **스플래시**: `assets/splash_logo.png` — 베이지 배경(Light) / 다크 배경(Dark)
- 설정: `pubspec.yaml` 내 `flutter_launcher_icons`, `flutter_native_splash` 섹션

```bash
# 아이콘 교체 후 재생성
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

### 빌드 & 실행

```bash
# 의존성 설치
flutter pub get

# .env.example에 실제 키 설정 (로컬 개발)
# API_BASE_URL, NAVER_MAP_CLIENT_ID, WEATHER_API_KEY

# Firebase 설정 (최초 1회)
# 1. Firebase CLI 로그인
firebase login
# 2. FlutterFire CLI로 설정 파일 생성
dart pub global activate flutterfire_cli
export PATH="$PATH:$HOME/.pub-cache/bin"
flutterfire configure --project=woori-san --platforms=android,ios \
  --android-package-name=com.woorisan.app --ios-bundle-id=com.woorisan.app
# → google-services.json, GoogleService-Info.plist, firebase_options.dart 자동 생성

# 안드로이드 실행
flutter run

# iOS 시뮬레이터 빌드
flutter build ios --simulator

# 테스트
flutter test

# 정적 분석
flutter analyze
```

### CI/CD

GitHub Actions로 PR/push마다 자동 검증합니다. (`.github/workflows/ci.yml`)

```
push/PR → flutter pub get → flutter analyze → flutter test (194개)
```

### 푸시 알림 테스트

```bash
# Firebase access token 발급 후 FCM HTTP v1 API로 전송
curl -X POST \
  "https://fcm.googleapis.com/v1/projects/woori-san/messages:send" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "topic": "weather_alerts",
      "notification": {
        "title": "🏔️ 우리산",
        "body": "오늘 등산하기 좋은 날씨예요!"
      },
      "data": { "route": "/home" }
    }
  }'
```

### 앱 식별자

| 플랫폼 | App ID |
|--------|--------|
| Android | `com.woorisan.app` |
| iOS | `com.woorisan.app` |
| Firebase | `woori-san` |
