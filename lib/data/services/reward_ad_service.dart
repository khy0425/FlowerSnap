import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// 리워드 광고 서비스
class RewardAdService {
  final Logger _logger = Logger();
  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  bool get isAdLoaded => _isAdLoaded;

  /// 리워드 광고 로드
  Future<void> loadRewardAd() async {
    final String adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917' // 테스트 광고 ID
        : 'ca-app-pub-3940256099942544/1712485313'; // iOS 테스트 광고 ID

    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (final RewardedAd ad) {
          _logger.i('리워드 광고 로드 완료');
          _rewardedAd = ad;
          _isAdLoaded = true;
          _setAdCallbacks();
        },
        onAdFailedToLoad: (final LoadAdError error) {
          _logger.e('리워드 광고 로드 실패: ${error.message}');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// 광고 콜백 설정
  void _setAdCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (final RewardedAd ad) {
        _logger.i('리워드 광고 전체화면 표시');
      },
      onAdDismissedFullScreenContent: (final RewardedAd ad) {
        _logger.i('리워드 광고 닫힘');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        loadRewardAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (final RewardedAd ad, final AdError error) {
        _logger.e('리워드 광고 표시 실패: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
      },
    );
  }

  /// 리워드 광고 표시
  Future<void> showRewardAd({
    final void Function(AdWithoutView, RewardItem)? onUserEarnedReward,
    final VoidCallback? onAdClosed,
    final void Function(String)? onAdFailed,
  }) async {
    if (!_isAdLoaded || _rewardedAd == null) {
      onAdFailed?.call('광고가 아직 로드되지 않았습니다');
      return;
    }

    _rewardedAd!.setImmersiveMode(true);

    await _rewardedAd!.show(
      onUserEarnedReward: (final AdWithoutView ad, final RewardItem reward) {
        _logger.i('리워드 획득: ${reward.amount} ${reward.type}');
        onUserEarnedReward?.call(ad, reward);
      },
    );

    // 광고 종료 후 콜백 호출
    onAdClosed?.call();
  }

  /// 리소스 해제
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
    _logger.d('리워드 광고 서비스 해제');
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