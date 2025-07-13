import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ja'),
    Locale('ko'),
  ];

  /// 애플리케이션 제목
  ///
  /// In ko, this message translates to:
  /// **'FloraSnap'**
  String get appTitle;

  /// 홈 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'🌿 FloraSnap'**
  String get homeTitle;

  /// 식물 사진 촬영 버튼
  ///
  /// In ko, this message translates to:
  /// **'식물 찍기'**
  String get takePhoto;

  /// 식물 사진 촬영 설명
  ///
  /// In ko, this message translates to:
  /// **'궁금한 식물을 찍어보세요!\nAI가 이름과 정보를 알려드려요.'**
  String get takePhotoDescription;

  /// 카메라 버튼
  ///
  /// In ko, this message translates to:
  /// **'카메라'**
  String get camera;

  /// 갤러리 버튼
  ///
  /// In ko, this message translates to:
  /// **'갤러리'**
  String get gallery;

  /// 오늘 배운 꽃 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'오늘 배운 꽃'**
  String get todayFlower;

  /// 내 꽃 노트 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'내 꽃 노트'**
  String get myFlowerNote;

  /// 더보기 버튼
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get seeMore;

  /// 꽃을 찍지 않았을 때 메시지
  ///
  /// In ko, this message translates to:
  /// **'아직 꽃을 찍지 않았어요'**
  String get noFlowerTaken;

  /// 꽃 사진 촬영 유도 메시지
  ///
  /// In ko, this message translates to:
  /// **'위의 [꽃 찍기] 버튼을 눌러보세요!'**
  String get tryTakePhoto;

  /// 알 수 없는 꽃 이름
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 꽃'**
  String get unknownFlower;

  /// 신뢰도 표시
  ///
  /// In ko, this message translates to:
  /// **'신뢰도: {percentage}%'**
  String confidence(String percentage);

  /// 저장된 꽃이 없을 때 메시지
  ///
  /// In ko, this message translates to:
  /// **'아직 저장된 꽃이 없어요.\n꽃을 찍으면 자동으로 노트에 저장됩니다.'**
  String get noFlowerSaved;

  /// 총 꽃 개수 표시
  ///
  /// In ko, this message translates to:
  /// **'총 {count}개의 꽃을 기록했어요!'**
  String totalFlowerCount(int count);

  /// 환영 메시지
  ///
  /// In ko, this message translates to:
  /// **'🌸 산책하며 만나는 꽃들의 이름을 알아보세요'**
  String get welcomeMessage;

  /// 환영 서브 메시지
  ///
  /// In ko, this message translates to:
  /// **'카메라로 찍기만 하면 꽃의 이름과 설명을 바로 알려드려요'**
  String get welcomeSubMessage;

  /// 사진 촬영 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'사진 촬영 중 오류가 발생했습니다: {error}'**
  String photoError(String error);

  /// 꽃 노트 화면 준비 중 메시지
  ///
  /// In ko, this message translates to:
  /// **'꽃 노트 화면은 곧 추가될 예정입니다!'**
  String get flowerNoteComingSoon;

  /// 설정 버튼
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// 분석 결과 화면 제목
  ///
  /// In ko, this message translates to:
  /// **'분석 결과'**
  String get analysisResult;

  /// 무료 분석 결과 섹션 제목
  ///
  /// In ko, this message translates to:
  /// **'무료 분석 결과'**
  String get freeAnalysisResult;

  /// 정밀 분석 가능 알림 제목
  ///
  /// In ko, this message translates to:
  /// **'정밀 분석 가능'**
  String get preciseAnalysisAvailable;

  /// 정밀 분석 설명
  ///
  /// In ko, this message translates to:
  /// **'이 꽃을 더 정확하게 알고 싶다면 정밀 분석을 해보세요.\n분석권을 사용하거나 광고를 시청하면 이용할 수 있습니다.'**
  String get preciseAnalysisDescription;

  /// 분석권 사용 버튼
  ///
  /// In ko, this message translates to:
  /// **'분석권 사용'**
  String get useAnalysisToken;

  /// 광고 시청 버튼
  ///
  /// In ko, this message translates to:
  /// **'광고 보고 분석권 받기'**
  String get watchAdForToken;

  /// 정밀 분석 결과 제목
  ///
  /// In ko, this message translates to:
  /// **'정밀 분석 결과'**
  String get preciseAnalysisResult;

  /// 꽃 노트 저장 버튼
  ///
  /// In ko, this message translates to:
  /// **'꽃 노트에 저장'**
  String get saveToFlowerNote;

  /// 다른 꽃 찍기 버튼
  ///
  /// In ko, this message translates to:
  /// **'다른 꽃 찍기'**
  String get takeAnotherPhoto;

  /// 광고 준비 안됨 메시지
  ///
  /// In ko, this message translates to:
  /// **'광고가 준비되지 않았습니다. 잠시 후 다시 시도해주세요.'**
  String get adNotReady;

  /// 일일 광고 시청 제한 메시지
  ///
  /// In ko, this message translates to:
  /// **'오늘 광고 시청 횟수를 모두 사용했습니다.'**
  String get dailyAdLimitReached;

  /// 분석권 획득 메시지
  ///
  /// In ko, this message translates to:
  /// **'분석권 1개를 획득했습니다!'**
  String get tokenEarned;

  /// 분석권 없음 메시지
  ///
  /// In ko, this message translates to:
  /// **'사용할 수 있는 분석권이 없습니다.'**
  String get noTokenAvailable;

  /// 정밀 분석 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'정밀 분석이 완료되었습니다!'**
  String get preciseAnalysisCompleted;

  /// 분석 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'분석 중 오류가 발생했습니다: {error}'**
  String analysisError(String error);

  /// 저장 완료 메시지
  ///
  /// In ko, this message translates to:
  /// **'꽃 노트에 저장되었습니다!'**
  String get savedToFlowerNote;

  /// 저장 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'저장 중 오류가 발생했습니다: {error}'**
  String saveError(String error);
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
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
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
