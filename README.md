# 우리산

함께 산을 오르는 즐거움을 기록하는 등산 앱

## 주요 기능

### 홈
- 이번 주 추천 등산 코스 (난이도, 소요시간 등)
- 함께한 산행 통계 (산행 횟수, 총 거리, 획득 도장)
- 최근 산행 기록

### 계획
- 등산 계획 추가 (산 선택 + 날짜)
- 계획 상태 관리 (확정 / 조율 중)
- 스와이프로 계획 삭제
- 준비물 체크리스트

### 도장 컬렉션
- 명산 도전 진행률
- 혼자 도장 / 함께 도장 구분
- 함께 오른 산 별도 표시

## 기술 스택

| 항목 | 내용 |
|------|------|
| 프레임워크 | Flutter (Dart SDK ^3.11.1) |
| 상태관리 | Provider |
| 로컬 저장소 | SharedPreferences |
| 디자인 | Material 3 |

## 프로젝트 구조

```
lib/
├── main.dart                  # 앱 진입점, 하단 네비게이션
├── theme/
│   └── app_theme.dart         # 테마 및 색상 정의
├── models/
│   ├── mountain.dart          # 산 코스 모델
│   ├── stamp_mountain.dart    # 도장 모델
│   ├── plan.dart              # 계획 및 체크리스트 모델
│   └── hiking_record.dart     # 산행 기록 모델
├── services/
│   └── storage_service.dart   # 로컬 데이터 영속화
├── providers/
│   └── app_state.dart         # 전역 상태관리
└── screens/
    ├── home_screen.dart       # 홈 화면
    ├── plan_screen.dart       # 계획 화면
    └── stamp_screen.dart      # 도장 화면
```

## 시작하기

```bash
# 의존성 설치
flutter pub get

# 실행
flutter run

# 분석
flutter analyze

# 테스트
flutter test
```
