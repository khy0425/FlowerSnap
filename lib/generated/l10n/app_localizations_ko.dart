// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'FloraSnap';

  @override
  String get homeTitle => '🌿 FloraSnap';

  @override
  String get takePhoto => '식물 찍기';

  @override
  String get takePhotoDescription => '궁금한 식물을 찍어보세요!\nAI가 이름과 정보를 알려드려요.';

  @override
  String get camera => '카메라';

  @override
  String get gallery => '갤러리';

  @override
  String get todayFlower => '오늘 배운 꽃';

  @override
  String get myFlowerNote => '내 꽃 노트';

  @override
  String get seeMore => '더보기';

  @override
  String get noFlowerTaken => '아직 꽃을 찍지 않았어요';

  @override
  String get tryTakePhoto => '위의 [꽃 찍기] 버튼을 눌러보세요!';

  @override
  String get unknownFlower => '알 수 없는 꽃';

  @override
  String confidence(String percentage) {
    return '신뢰도: $percentage%';
  }

  @override
  String get noFlowerSaved => '아직 저장된 꽃이 없어요.\n꽃을 찍으면 자동으로 노트에 저장됩니다.';

  @override
  String totalFlowerCount(int count) {
    return '총 $count개의 꽃을 기록했어요!';
  }

  @override
  String get welcomeMessage => '🌸 산책하며 만나는 꽃들의 이름을 알아보세요';

  @override
  String get welcomeSubMessage => '카메라로 찍기만 하면 꽃의 이름과 설명을 바로 알려드려요';

  @override
  String photoError(String error) {
    return '사진 촬영 중 오류가 발생했습니다: $error';
  }

  @override
  String get flowerNoteComingSoon => '꽃 노트 화면은 곧 추가될 예정입니다!';

  @override
  String get settings => '설정';

  @override
  String get analysisResult => '분석 결과';

  @override
  String get freeAnalysisResult => '무료 분석 결과';

  @override
  String get preciseAnalysisAvailable => '정밀 분석 가능';

  @override
  String get preciseAnalysisDescription =>
      '이 꽃을 더 정확하게 알고 싶다면 정밀 분석을 해보세요.\n분석권을 사용하거나 광고를 시청하면 이용할 수 있습니다.';

  @override
  String get useAnalysisToken => '분석권 사용';

  @override
  String get watchAdForToken => '광고 보고 분석권 받기';

  @override
  String get preciseAnalysisResult => '정밀 분석 결과';

  @override
  String get saveToFlowerNote => '꽃 노트에 저장';

  @override
  String get takeAnotherPhoto => '다른 꽃 찍기';

  @override
  String get adNotReady => '광고가 준비되지 않았습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get dailyAdLimitReached => '오늘 광고 시청 횟수를 모두 사용했습니다.';

  @override
  String get tokenEarned => '분석권 1개를 획득했습니다!';

  @override
  String get noTokenAvailable => '사용할 수 있는 분석권이 없습니다.';

  @override
  String get preciseAnalysisCompleted => '정밀 분석이 완료되었습니다!';

  @override
  String analysisError(String error) {
    return '분석 중 오류가 발생했습니다: $error';
  }

  @override
  String get savedToFlowerNote => '꽃 노트에 저장되었습니다!';

  @override
  String saveError(String error) {
    return '저장 중 오류가 발생했습니다: $error';
  }
}
