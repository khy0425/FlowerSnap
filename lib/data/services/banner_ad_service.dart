import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import 'dart:io';

/// 배너 광고 관리 서비스
/// 무료 버전에서 지속적인 수익 창출을 위한 배너 광고 표시
class BannerAdService {
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // 실제 배포 시 변경 필요
  static const String _iosAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // 실제 배포 시 변경 필요
  
  final Logger _logger = Logger();
  BannerAd? _bannerAd;
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
  
  /// 배너 광고 로드
  Future<BannerAd?> loadBannerAd({
    AdSize adSize = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
    void Function(Ad)? onAdClicked,
  }) async {
    try {
      _logger.i('배너 광고 로드 시작...');
      
      _bannerAd = BannerAd(
        adUnitId: _adUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            _logger.i('💡 배너 광고 로드 완료');
            _isAdLoaded = true;
            onAdLoaded?.call(ad);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            _logger.e('배너 광고 로드 실패: $error');
            _isAdLoaded = false;
            ad.dispose();
            _bannerAd = null;
            onAdFailedToLoad?.call(ad, error);
          },
          onAdClicked: (Ad ad) {
            _logger.i('배너 광고 클릭됨');
            onAdClicked?.call(ad);
          },
          onAdImpression: (Ad ad) {
            _logger.i('배너 광고 노출됨');
          },
        ),
      );
      
      await _bannerAd!.load();
      return _bannerAd;
    } catch (e) {
      _logger.e('배너 광고 로드 중 오류: $e');
      _isAdLoaded = false;
      return null;
    }
  }
  
  /// 배너 광고 위젯 생성
  Widget? createBannerWidget() {
    if (_bannerAd != null && _isAdLoaded) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }
  
  /// 광고가 로드되었는지 확인
  bool isAdLoaded() => _isAdLoaded && _bannerAd != null;
  
  /// 리소스 해제
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isAdLoaded = false;
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
    _bannerAd = await _bannerAdService.loadBannerAd(
      adSize: AdSize.banner,
      onAdLoaded: (Ad ad) {
        setState(() {
          _isLoaded = true;
        });
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
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
  Widget build(BuildContext context) {
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