# 🌿 FloraSnap - AI Plant Recognition App

AI 기반 식물 인식과 디지털 정원 관리 앱

## 🚀 주요 기능

### 📸 스마트 식물 인식
- **AI 기반 식물 인식**: Plant.id와 PlantNet API를 활용한 정확한 식물 식별
- **이중 분석 시스템**: 무료 기본 분석과 프리미엄 정밀 분석 제공
- **바운딩 박스 표시**: 인식된 식물의 정확한 위치 시각화
- **신뢰도 표시**: 분석 결과의 신뢰도를 시각적으로 표시

### 🌱 포괄적 식물 데이터베이스
- **다양한 식물 종류**: 꽃, 나무, 잎, 풀, 다육식물 등 모든 식물 종류 지원
- **상세한 정보**: 식물명, 학명, 설명, 대체명 등 풍부한 정보 제공
- **다국어 지원**: 한국어, 영어, 일본어 완벽 지원

### 👥 시니어 친화적 UI
- **큰 글씨와 아이콘**: 가독성을 높인 UI/UX 디자인
- **직관적인 인터페이스**: 복잡하지 않은 단순한 화면 구성
- **접근성 최적화**: 모든 연령대가 쉽게 사용할 수 있도록 설계

### 🏡 디지털 정원 관리
- **분석 기록 저장**: 사용자가 인식한 모든 식물 기록 보관
- **꽃 노트 기능**: 개인만의 식물 컬렉션 관리
- **통계 및 현황**: 분석한 식물 수와 정원 현황 표시

### 💎 프리미엄 기능
- **토큰 기반 시스템**: 프리미엄 분석을 위한 토큰 관리
- **리워드 광고**: 광고 시청으로 무료 토큰 획득
- **API 토큰 관리**: Plant.id API 토큰 등록 및 관리

## 🛠 기술 스택

### Frontend
- **Flutter 3.x**: 크로스 플랫폼 앱 개발
- **Riverpod**: 상태 관리 및 의존성 주입
- **Camera**: 카메라 기능 및 이미지 처리
- **Image Picker**: 갤러리 및 카메라 이미지 선택

### Backend & APIs
- **Plant.id API**: 프리미엄 AI 식물 인식
- **PlantNet API**: 무료 기본 식물 인식
- **HTTP/Dio**: REST API 통신
- **JSON Serialization**: 데이터 직렬화/역직렬화

### Data & Storage
- **SharedPreferences**: 로컬 설정 및 토큰 저장
- **Hive**: 로컬 데이터베이스 (분석 기록)
- **JSON**: 구조화된 데이터 처리

### UI/UX
- **Material Design**: 안드로이드 네이티브 디자인
- **Senior Theme**: 시니어 친화적 테마 시스템
- **Localization**: 다국어 지원 (한국어, 영어, 일본어)

### Development & Testing
- **Dart**: 메인 개발 언어
- **Widget Testing**: 유닛 테스트
- **Flutter Analyze**: 코드 품질 분석

## 📱 설치 및 실행

### 요구사항
- Flutter SDK 3.x 이상
- Dart SDK 3.x 이상
- Android Studio 또는 VS Code

### 설치 방법
```bash
# 프로젝트 클론
git clone https://github.com/khy0425/FlowerSnap.git
cd FlowerSnap

# 의존성 설치
flutter pub get

# 코드 생성 (필요시)
flutter packages pub run build_runner build

# 앱 실행
flutter run
```

## 📂 프로젝트 구조

```
lib/
├── core/                     # 핵심 설정 및 유틸리티
│   ├── exceptions/          # 예외 처리
│   └── theme/              # 테마 및 스타일
├── data/                    # 데이터 레이어
│   ├── models/             # 데이터 모델
│   └── services/           # API 서비스
├── domain/                  # 도메인 레이어
│   ├── entities/           # 엔티티
│   └── repositories/       # 리포지토리
├── presentation/           # 프레젠테이션 레이어
│   ├── screens/           # 화면
│   ├── widgets/           # 재사용 가능한 위젯
│   ├── viewmodels/        # 뷰모델
│   └── services/          # 프레젠테이션 서비스
├── generated/             # 생성된 파일들
│   └── l10n/             # 다국어 파일
└── l10n/                  # 다국어 리소스
```

## 🔧 개발 노트

### 코드 품질 개선 사항
- **Flutter Analyze**: 250개 → 206개 문제 해결 (44개 개선)
- **타입 안전성**: 명시적 타입 지정으로 타입 추론 실패 해결
- **null 안전성**: 불필요한 null 단정문 제거
- **성능 최적화**: const 생성자 사용으로 위젯 리빌드 최적화

### 아키텍처 개선
- **코드 분리**: 1,266줄 → 350줄로 파일 분할
- **단일 책임 원칙**: 기능별 모듈화
- **재사용성 향상**: 공통 위젯 및 서비스 분리

## 🌟 주요 특징

1. **엔터프라이즈급 코드 품질**: 엄격한 코드 분석 및 최적화
2. **모듈화된 아키텍처**: 유지보수성과 확장성을 고려한 설계
3. **다국어 지원**: 완벽한 i18n 구현
4. **접근성 최적화**: 모든 사용자를 위한 포용적 디자인
5. **성능 최적화**: 효율적인 상태 관리 및 메모리 사용

## 🤝 기여하기

1. 이 저장소를 포크합니다
2. 새로운 기능 브랜치를 생성합니다 (`git checkout -b feature/AmazingFeature`)
3. 변경사항을 커밋합니다 (`git commit -m 'Add some AmazingFeature'`)
4. 브랜치에 푸시합니다 (`git push origin feature/AmazingFeature`)
5. Pull Request를 생성합니다

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 문의

프로젝트 관련 문의사항이 있으시면 Issue를 생성해 주세요.
