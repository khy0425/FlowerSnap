// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'FloraSnap';

  @override
  String get homeTitle => '🌿 FloraSnap';

  @override
  String get takePhoto => '植物を撮る';

  @override
  String get takePhotoDescription => '気になる植物を撮影してください！\nAIが名前と詳細情報をお教えします。';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get todayFlower => '今日の花';

  @override
  String get myFlowerNote => '私の花ノート';

  @override
  String get seeMore => 'もっと見る';

  @override
  String get noFlowerTaken => 'まだ花を撮影していません';

  @override
  String get tryTakePhoto => '上の［花を撮る］ボタンを押してみてください！';

  @override
  String get unknownFlower => '不明な花';

  @override
  String confidence(String percentage) {
    return '信頼度: $percentage%';
  }

  @override
  String get noFlowerSaved => 'まだ保存された花がありません。\n花を撮影すると自動的にノートに保存されます。';

  @override
  String totalFlowerCount(int count) {
    return '合計$count個の花を記録しました！';
  }

  @override
  String get welcomeMessage => '🌸 散歩で出会う花の名前を調べましょう';

  @override
  String get welcomeSubMessage => 'カメラで撮影するだけで、花の名前と説明をすぐにお教えします';

  @override
  String photoError(String error) {
    return '写真撮影中にエラーが発生しました: $error';
  }

  @override
  String get flowerNoteComingSoon => '花ノート画面は近日追加予定です！';

  @override
  String get settings => '設定';

  @override
  String get analysisResult => '分析結果';

  @override
  String get freeAnalysisResult => '無料分析結果';

  @override
  String get preciseAnalysisAvailable => '精密分析可能';

  @override
  String get preciseAnalysisDescription =>
      'この花をより正確に知りたい場合は、精密分析をお試しください。\n分析権を使用するか、広告を視聴することでご利用いただけます。';

  @override
  String get useAnalysisToken => '分析権を使用';

  @override
  String get watchAdForToken => '広告を見て分析権を取得';

  @override
  String get preciseAnalysisResult => '精密分析結果';

  @override
  String get saveToFlowerNote => '花ノートに保存';

  @override
  String get takeAnotherPhoto => '別の花を撮影';

  @override
  String get adNotReady => '広告の準備ができていません。しばらくしてからもう一度お試しください。';

  @override
  String get dailyAdLimitReached => '本日の広告視聴回数をすべて使用しました。';

  @override
  String get tokenEarned => '分析権1個を獲得しました！';

  @override
  String get noTokenAvailable => '使用可能な分析権がありません。';

  @override
  String get preciseAnalysisCompleted => '精密分析が完了しました！';

  @override
  String analysisError(String error) {
    return '分析中にエラーが発生しました：$error';
  }

  @override
  String get savedToFlowerNote => '花ノートに保存されました！';

  @override
  String saveError(String error) {
    return '保存中にエラーが発生しました：$error';
  }
}
