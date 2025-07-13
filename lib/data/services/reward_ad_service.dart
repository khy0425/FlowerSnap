import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// 리워드 광고 관리 서비스
/// Google Mobile Ads를 활용하여 리워드 광고 표시 및 보상 처리
class RewardAdService {
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _androidAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // 실제 배포 시 변경 필요
  static const String _iosAdUnitId = 'ca-app-pub-3940256099942544/1712485313'; // 실제 배포 시 변경 필요
  
  final Logger _logger = Logger();
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  
  /// 광고 Unit ID 가져오기
  String get _adUnitId {
    if (Platform.isAndroid) {
      return _androidAdUnitId;
    } else if (Platform.isIOS) {
      return _iosAdUnitId;
    } else {
      return _testAdUnitId;
    }
  }
  
  /// 리워드 광고 로드
  Future<bool> loadRewardedAd() async {
    try {
      _logger.i('리워드 광고 로드 시작...');
      
      await RewardedAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (final RewardedAd ad) {
            _logger.i('리워드 광고 로드 완료');
            _rewardedAd = ad;
            _isAdLoaded = true;
            _setAdCallbacks();
          },
          onAdFailedToLoad: (final LoadAdError error) {
            _logger.e('리워드 광고 로드 실패: $error');
            _isAdLoaded = false;
            _rewardedAd = null;
          },
        ),
      );
      
      // 로드 완료까지 최대 10초 대기
      for (int i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (_isAdLoaded) break;
      }
      
      return _isAdLoaded;
    } catch (e) {
      _logger.e('리워드 광고 로드 중 오류: $e');
      _isAdLoaded = false;
      return false;
    }
  }
  
  /// 광고 콜백 설정
  void _setAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        _logger.i('리워드 광고 표시됨');
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _logger.i('리워드 광고 닫힘');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        _logger.e('리워드 광고 표시 실패: $error');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
      },
    );
  }
  
  /// 리워드 광고 표시
  /// [onUserEarnedReward] 광고 시청 완료 시 호출되는 콜백
  /// [onAdClosed] 광고 닫힘 시 호출되는 콜백
  Future<void> showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    void Function()? onAdClosed,
    void Function(String error)? onAdFailed,
  }) async {
    if (!_isAdLoaded || _rewardedAd == null) {
      _logger.w('리워드 광고가 로드되지 않았습니다.');
      onAdFailed?.call('광고가 준비되지 않았습니다. 잠시 후 다시 시도해주세요.');
      return;
    }
    
    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          _logger.i('리워드 광고 보상 획득: ${reward.type}, ${reward.amount}');
          onUserEarnedReward(reward);
        },
      );
      
      // 광고 표시 후 콜백 설정
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          _logger.i('리워드 광고 닫힘');
          ad.dispose();
          _rewardedAd = null;
          _isAdLoaded = false;
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          _logger.e('리워드 광고 표시 실패: $error');
          ad.dispose();
          _rewardedAd = null;
          _isAdLoaded = false;
          onAdFailed?.call('광고 표시 중 오류가 발생했습니다: ${error.message}');
        },
      );
    } catch (e) {
      _logger.e('리워드 광고 표시 중 오류: $e');
      onAdFailed?.call('광고 표시 중 오류가 발생했습니다.');
    }
  }
  
  /// 광고가 로드되었는지 확인
  bool isAdLoaded() => _isAdLoaded && _rewardedAd != null;
  
  /// 리소스 해제
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
  }
  
  /// Google Mobile Ads 초기화
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      Logger().i('Google Mobile Ads 초기화 완료');
    } catch (e) {
      Logger().e('Google Mobile Ads 초기화 실패: $e');
    }
  }
  
  /// 개인정보 보호 설정 (GDPR 대응)
  static Future<void> setPrivacySettings() async {
    try {
      // 개발 환경에서는 테스트 모드로 설정
      final RequestConfiguration requestConfiguration = RequestConfiguration(
        testDeviceIds: ['33BE2250B43518CCDA7DE426D04EE231'], // 테스트 기기 ID
      );
      
      await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
      Logger().i('개인정보 보호 설정 완료');
    } catch (e) {
      Logger().e('개인정보 보호 설정 실패: $e');
    }
  }
} 