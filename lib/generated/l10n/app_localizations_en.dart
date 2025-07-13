// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FloraSnap';

  @override
  String get homeTitle => '🌿 FloraSnap';

  @override
  String get takePhoto => 'Snap Plant';

  @override
  String get takePhotoDescription =>
      'Snap a photo of any plant you\'re curious about!\nAI will identify it and provide detailed information.';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get todayFlower => 'Today\'s Flower';

  @override
  String get myFlowerNote => 'My Flower Note';

  @override
  String get seeMore => 'See More';

  @override
  String get noFlowerTaken => 'No flowers taken yet';

  @override
  String get tryTakePhoto => 'Try tapping the [Take Photo] button above!';

  @override
  String get unknownFlower => 'Unknown Flower';

  @override
  String confidence(String percentage) {
    return 'Confidence: $percentage%';
  }

  @override
  String get noFlowerSaved =>
      'No flowers saved yet.\nFlowers will be automatically saved to your note when you take photos.';

  @override
  String totalFlowerCount(int count) {
    return 'You\'ve recorded $count flowers in total!';
  }

  @override
  String get welcomeMessage =>
      '🌸 Discover the names of flowers you meet during your walks';

  @override
  String get welcomeSubMessage =>
      'Just take a photo with your camera and we\'ll tell you the flower\'s name and description right away';

  @override
  String photoError(String error) {
    return 'An error occurred while taking a photo: $error';
  }

  @override
  String get flowerNoteComingSoon =>
      'The flower note screen will be added soon!';

  @override
  String get settings => 'Settings';

  @override
  String get analysisResult => 'Analysis Result';

  @override
  String get freeAnalysisResult => 'Free Analysis Result';

  @override
  String get preciseAnalysisAvailable => 'Precise Analysis Available';

  @override
  String get preciseAnalysisDescription =>
      'If you want to know this flower more accurately, try precise analysis.\nYou can use analysis tokens or watch ads to use it.';

  @override
  String get useAnalysisToken => 'Use Analysis Token';

  @override
  String get watchAdForToken => 'Watch Ad for Token';

  @override
  String get preciseAnalysisResult => 'Precise Analysis Result';

  @override
  String get saveToFlowerNote => 'Save to Flower Note';

  @override
  String get takeAnotherPhoto => 'Take Another Photo';

  @override
  String get adNotReady => 'Ad is not ready. Please try again later.';

  @override
  String get dailyAdLimitReached =>
      'You\'ve reached today\'s ad viewing limit.';

  @override
  String get tokenEarned => 'You earned 1 analysis token!';

  @override
  String get noTokenAvailable => 'No analysis tokens available.';

  @override
  String get preciseAnalysisCompleted => 'Precise analysis completed!';

  @override
  String analysisError(String error) {
    return 'Analysis error occurred: $error';
  }

  @override
  String get savedToFlowerNote => 'Saved to flower note!';

  @override
  String saveError(String error) {
    return 'Save error occurred: $error';
  }
}
