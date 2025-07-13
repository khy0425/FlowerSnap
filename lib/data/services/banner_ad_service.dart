import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// 배너 광고 서비스
class BannerAdService {
  final Logger _logger = Logger();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  bool get isAdLoaded => _isAdLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// 배너 광고 로드
  Future<void> loadBannerAd({
    final AdSize? adSize,
    final void Function(Ad)? onAdLoaded,
    final void Function(Ad, LoadAdError)? onAdFailedToLoad,
    final void Function(Ad)? onAdClicked,
  }) async {
    final String adUnitId = Platform.isAndroid 
        ? 'ca-app-pub-3940256099942544/6300978111' // 테스트 광고 ID
        : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 광고 ID

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (final Ad ad) {
          _logger.i('💡 배너 광고 로드 완료');
          _isAdLoaded = true;
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (final Ad ad, final LoadAdError error) {
          _logger.e('❌ 배너 광고 로드 실패: ${error.message}');
          _isAdLoaded = false;
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
        onAdClicked: (final Ad ad) {
          _logger.i('배너 광고 클릭됨');
          onAdClicked?.call(ad);
        },
        onAdImpression: (final Ad ad) {
          _logger.d('배너 광고 노출');
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// 광고 해제
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
    _logger.d('배너 광고 서비스 해제');
  }

  /// 광고 표시를 위한 위젯 반환
  Widget buildAdWidget() {
    if (_bannerAd != null && _isAdLoaded) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }

  /// 광고 클릭 핸들러
  void onAdClick(final BuildContext context) {
    _logger.i('배너 광고 클릭 처리');
    // 클릭 후 처리 로직이 필요하면 여기에 추가
  }

  /// 테스트용 광고 데이터 설정
  void setTestMode() {
    _logger.d('🧪 배너 광고 테스트 모드 활성화');
  }
}

/// 무료 버전용 배너 광고 위젯
class FreeBannerAdWidget extends StatefulWidget {
  final String? title;
  final EdgeInsetsGeometry? margin;
  
  const FreeBannerAdWidget({
    super.key,
    this.title,
    this.margin,
  });

  @override
  State<FreeBannerAdWidget> createState() => _FreeBannerAdWidgetState();
}

class _FreeBannerAdWidgetState extends State<FreeBannerAdWidget> {
  final BannerAdService _bannerAdService = BannerAdService();
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    await _bannerAdService.loadBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (final Ad ad) {
        setState(() {
          _bannerAd = ad as BannerAd;
          _isLoaded = true;
        });
      },
      onAdFailedToLoad: (final Ad ad, final LoadAdError error) {
        setState(() {
          _isLoaded = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _bannerAdService.dispose();
    super.dispose();
  }

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(final BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          if (_isLoaded && _bannerAd != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            )
          else
            Container(
              width: 320,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text(
                  '광고 로딩 중...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 