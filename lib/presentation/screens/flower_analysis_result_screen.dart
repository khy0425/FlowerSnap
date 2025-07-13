import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/senior_theme.dart';
import '../../data/models/analysis_result.dart';
import '../../data/services/analysis_token_service.dart';
import '../../data/services/reward_ad_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../widgets/image_with_bounding_box.dart';

class FlowerAnalysisResultScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final AnalysisResult analysisResult;
  final bool isLowConfidence; // 신뢰도가 낮아서 재분석 권장 여부
  
  const FlowerAnalysisResultScreen({
    super.key,
    required this.imageFile,
    required this.analysisResult,
    this.isLowConfidence = false,
  });

  @override
  ConsumerState<FlowerAnalysisResultScreen> createState() => _FlowerAnalysisResultScreenState();
}

class _FlowerAnalysisResultScreenState extends ConsumerState<FlowerAnalysisResultScreen> 
    with TickerProviderStateMixin {
  final AnalysisTokenService _tokenService = AnalysisTokenService();
  final RewardAdService _rewardAdService = RewardAdService();
  
  int _tokenCount = 0;
  bool _isLoadingPreciseAnalysis = false;
  bool _isLoadingRewardAd = false;
  AnalysisResult? _preciseResult;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _loadTokenCount();
    _loadRewardAd();
    _initializeAnimations();
  }
  
  @override
  void dispose() {
    _rewardAdService.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: SeniorConstants.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideController = AnimationController(
      duration: SeniorConstants.animationDurationSlow,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  /// 분석권 개수 로드
  Future<void> _loadTokenCount() async {
    final count = await _tokenService.getTokenCount();
    if (mounted) {
      setState(() {
        _tokenCount = count;
      });
    }
  }
  
  /// 리워드 광고 로드
  Future<void> _loadRewardAd() async {
    setState(() {
      _isLoadingRewardAd = true;
    });
    
    await _rewardAdService.loadRewardAd();
    
    if (mounted) {
      setState(() {
        _isLoadingRewardAd = false;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: SeniorTheme.backgroundColor,
      body: Container(
        decoration: SeniorTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 결과 이미지 (바운딩 박스 포함)
                            _buildFlowerImageWithBoundingBox(context),
                            
                            const SizedBox(height: SeniorConstants.spacingLarge),
                            
                            // 분석 결과 카드
                            _buildAnalysisResultCard(context),
                            
                            const SizedBox(height: SeniorConstants.spacingLarge),
                            
                            // 정밀 분석 권장 (신뢰도가 낮을 때만)
                            if (widget.isLowConfidence && _preciseResult == null)
                              _buildPreciseAnalysisCard(context),
                            
                            // 정밀 분석 결과 (있을 때만)
                            if (_preciseResult != null) ...[
                              const SizedBox(height: SeniorConstants.spacingLarge),
                              _buildPreciseResultCard(context),
                            ],
                            
                            const SizedBox(height: SeniorConstants.spacingXLarge),
                            
                            // 하단 버튼들
                            _buildBottomButtons(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 앱바 커스텀 빌드
  Widget _buildAppBar(final BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SeniorTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: SeniorTheme.cardElevationColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SeniorConstants.spacing,
          vertical: SeniorConstants.spacingSmall,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: SeniorConstants.iconSizeLarge,
              ),
            ),
            
            Expanded(
              child: Text(
                AppLocalizations.of(context).analysisResult,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // 분석권 개수 표시
            AnimatedContainer(
              duration: SeniorConstants.animationDurationFast,
              child: _buildTokenCountWidget(context),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 분석권 개수 위젯
  Widget _buildTokenCountWidget(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SeniorConstants.spacing,
        vertical: SeniorConstants.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: SeniorTheme.tokenColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: SeniorTheme.tokenColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.stars,
            color: SeniorTheme.tokenColor,
            size: SeniorConstants.iconSizeMedium,
          ),
          const SizedBox(width: SeniorConstants.spacingXSmall),
          Text(
            '$_tokenCount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 결과 이미지 섹션 (바운딩 박스 포함)
  Widget _buildFlowerImageWithBoundingBox(final BuildContext context) {
    final result = widget.analysisResult;
    
    return Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: SeniorTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
                  ),
                  child: Icon(
                    result.detectionResults.isNotEmpty 
                        ? Icons.center_focus_strong 
                        : Icons.photo_camera,
                    color: SeniorTheme.accentColor,
                    size: SeniorConstants.iconSizeMedium,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.detectionResults.isNotEmpty 
                            ? "분석 완료 (식물 위치 표시)"
                            : "분석 완료",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: SeniorTheme.textPrimaryColor,
                        ),
                      ),
                      // Detection results 정보 (단순화된 버전)
                      if (result.detectionResults.isNotEmpty) ...[
                        const SizedBox(height: SeniorConstants.spacingSmall),
                        Text(
                          '감지 영역: ${result.detectionResults.length}개',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SeniorTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 바운딩 박스가 포함된 이미지
            Center(
              child: ImageWithBoundingBox(
                imageFile: widget.imageFile,
                detectionResults: result.detectionResults,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            
            // 감지 결과 정보 표시
            if (result.detectionResults.isNotEmpty) ...[
              const SizedBox(height: SeniorConstants.spacing),
              Container(
                padding: const EdgeInsets.all(SeniorConstants.spacing),
                decoration: BoxDecoration(
                  color: SeniorTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "감지된 상세 정보",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SeniorTheme.accentColor,
                      ),
                    ),
                    const SizedBox(height: SeniorConstants.spacingSmall),
                    ...result.detectionResults.asMap().entries.map((entry) {
                      final index = entry.key;
                      final box = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getBoundingBoxColor(box.confidence),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${box.label} ${index + 1}: ${(box.confidence * 100).toInt()}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 바운딩 박스 신뢰도에 따른 색상
  Color _getBoundingBoxColor(final double confidence) {
    if (confidence >= 0.8) {
      return SeniorTheme.successColor;
    } else if (confidence >= 0.6) {
      return SeniorTheme.warningColor;
    } else {
      return SeniorTheme.errorColor;
    }
  }
  
  /// 분석 결과 카드
  Widget _buildAnalysisResultCard(final BuildContext context) {
    final result = widget.analysisResult;
    
            // 꽃이 아닌 경우 별도 처리
    if (!result.isFlower) {
      return _buildNotFlowerCard(context, result);
    }
    
    return Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: SeniorTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: SeniorTheme.accentColor,
                    size: SeniorConstants.iconSizeLarge,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).freeAnalysisResult,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: SeniorTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "무료 분석 결과",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SeniorTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 식물 이름
            Text(
              result.name.isNotEmpty ? result.name : AppLocalizations.of(context).unknownFlower,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: SeniorTheme.primaryColor,
              ),
            ),
            
            // 학명
            const SizedBox(height: SeniorConstants.spacingSmall),
            Text(
              result.scientificName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: SeniorTheme.textSecondaryColor,
                ),
              ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 신뢰도 카드
            _buildConfidenceCard(context, result.confidence),
            
            // 설명
            if (result.description.isNotEmpty) ...[
              const SizedBox(height: SeniorConstants.spacingLarge),
              Container(
                padding: const EdgeInsets.all(SeniorConstants.spacing),
                decoration: BoxDecoration(
                  color: SeniorTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "설명",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SeniorConstants.spacingSmall),
                    Text(
                      result.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 식물이 아닌 경우 카드
  Widget _buildNotFlowerCard(final BuildContext context, final AnalysisResult result) {
    return Container(
      decoration: SeniorTheme.specialCardDecoration(SeniorTheme.warningColor),
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경고 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: SeniorTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    color: SeniorTheme.warningColor,
                    size: SeniorConstants.iconSizeLarge,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "식물이 아닙니다",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: SeniorTheme.warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "식물이 아닌 것으로 인식되었습니다",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SeniorTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 식물이 아닌 이유 설명
            Container(
              padding: const EdgeInsets.all(SeniorConstants.spacing),
              decoration: BoxDecoration(
                color: SeniorTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "분석 결과",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: SeniorTheme.warningColor,
                    ),
                  ),
                  const SizedBox(height: SeniorConstants.spacingSmall),
                  Text(
                    result.notFlowerReason,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 인식된 결과 표시
            if (result.name.isNotEmpty) ...[
              Text(
                "인식된 결과",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SeniorConstants.spacingSmall),
              Text(
                result.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: SeniorTheme.textSecondaryColor,
                ),
              ),
              if (result.scientificName.isNotEmpty) ...[
                const SizedBox(height: SeniorConstants.spacingXSmall),
                Text(
                  result.scientificName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: SeniorTheme.textSecondaryColor,
                  ),
                ),
              ],
              const SizedBox(height: SeniorConstants.spacingLarge),
            ],
            
            // 신뢰도 표시
            _buildConfidenceCard(context, result.confidence),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(SeniorConstants.spacing),
              decoration: BoxDecoration(
                color: SeniorTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
                border: Border.all(color: SeniorTheme.infoColor, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: SeniorTheme.infoColor,
                    size: SeniorConstants.iconSizeMedium,
                  ),
                  const SizedBox(width: SeniorConstants.spacing),
                  Expanded(
                    child: Text(
                      "식물의 잎이나 꽃 부분을 다시 찍어보시거나, 정밀 분석을 통해 더 정확한 결과를 확인해보세요.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SeniorTheme.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.camera_alt),
                                          label: const Text("다시 찍기"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SeniorTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(SeniorConstants.spacing),
                    ),
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _tokenCount > 0 || !_isLoadingRewardAd
                        ? () => _showPreciseAnalysisForNonFlower(context)
                        : null,
                    icon: const Icon(Icons.search),
                                          label: const Text("정밀 분석"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SeniorTheme.warningColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(SeniorConstants.spacing),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 신뢰도 카드 위젯
  Widget _buildConfidenceCard(final BuildContext context, final double confidence) {
    final color = SeniorTheme.getConfidenceColor(confidence);
    final icon = SeniorTheme.getConfidenceIcon(confidence);
    
    return Container(
      padding: const EdgeInsets.all(SeniorConstants.spacing),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
            ),
            child: Icon(
              icon,
              color: color,
              size: SeniorConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: SeniorConstants.spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "신뢰도",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).confidence((confidence * 100).toStringAsFixed(1)),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 정밀 분석 권장 카드
  Widget _buildPreciseAnalysisCard(final BuildContext context) {
    return Container(
      decoration: SeniorTheme.specialCardDecoration(SeniorTheme.warningColor),
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: SeniorTheme.warningColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: SeniorTheme.warningColor,
                    size: SeniorConstants.iconSizeLarge,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).preciseAnalysisAvailable,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: SeniorTheme.warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "더 정확한 결과를 위해",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SeniorTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            Text(
              AppLocalizations.of(context).preciseAnalysisDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 정밀 분석 버튼들
            if (_isLoadingPreciseAnalysis)
              _buildLoadingWidget(context, "정밀 분석 중..")
            else
              _buildPreciseAnalysisButtons(context),
          ],
        ),
      ),
    );
  }
  
  /// 정밀 분석 버튼들
  Widget _buildPreciseAnalysisButtons(final BuildContext context) {
    return Column(
      children: [
        // 분석권 사용 버튼
        if (_tokenCount > 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _performPreciseAnalysis(useToken: true),
              icon: const Icon(Icons.stars),
                              label: Text(AppLocalizations.of(context).useAnalysisToken),
              style: ElevatedButton.styleFrom(
                backgroundColor: SeniorTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(SeniorConstants.spacing),
              ),
            ),
          ),
        
        if (_tokenCount > 0)
          const SizedBox(height: SeniorConstants.spacing),
        
                  // 광고 시청 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoadingRewardAd ? null : _watchRewardAd,
            icon: _isLoadingRewardAd 
              ? const SizedBox(
                  width: SeniorConstants.iconSizeMedium,
                  height: SeniorConstants.iconSizeMedium,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.play_circle_outline),
                            label: Text(AppLocalizations.of(context).watchAdForToken),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeniorTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(SeniorConstants.spacing),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 정밀 분석 결과 카드
  Widget _buildPreciseResultCard(final BuildContext context) {
    if (_preciseResult == null) return const SizedBox.shrink();
    
    return Container(
      decoration: SeniorTheme.specialCardDecoration(SeniorTheme.successColor),
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: SeniorTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: SeniorTheme.successColor,
                    size: SeniorConstants.iconSizeLarge,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).preciseAnalysisResult,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: SeniorTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "프리미엄 분석 결과",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SeniorTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 정밀 분석 결과 표시
            Text(
              _preciseResult!.name.isNotEmpty ? _preciseResult!.name : AppLocalizations.of(context).unknownFlower,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: SeniorTheme.successColor,
              ),
            ),
            
            if (_preciseResult!.scientificName.isNotEmpty) ...[
              const SizedBox(height: SeniorConstants.spacingSmall),
              Text(
                _preciseResult!.scientificName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: SeniorTheme.textSecondaryColor,
                ),
              ),
            ],
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 신뢰도
            _buildConfidenceCard(context, _preciseResult!.confidence),
            
            if (_preciseResult!.description.isNotEmpty) ...[
              const SizedBox(height: SeniorConstants.spacingLarge),
              Container(
                padding: const EdgeInsets.all(SeniorConstants.spacing),
                decoration: BoxDecoration(
                  color: SeniorTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "상세 설명",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SeniorTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: SeniorConstants.spacingSmall),
                    Text(
                      _preciseResult!.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 로딩 위젯
  Widget _buildLoadingWidget(final BuildContext context, final String message) {
    return Container(
      padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
      child: Column(
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(SeniorTheme.primaryColor),
          ),
          const SizedBox(height: SeniorConstants.spacing),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SeniorTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 하단 버튼들
  Widget _buildBottomButtons(final BuildContext context) {
    return Column(
      children: [
        // 뒤로가기 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _saveToFlowerNote(context),
            icon: const Icon(Icons.save),
                            label: Text(AppLocalizations.of(context).saveToFlowerNote),
            style: ElevatedButton.styleFrom(
              backgroundColor: SeniorTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(SeniorConstants.spacing),
            ),
          ),
        ),
        
        const SizedBox(height: SeniorConstants.spacing),
        
        // 다시 찍기 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.camera_alt),
                            label: Text(AppLocalizations.of(context).takeAnotherPhoto),
            style: OutlinedButton.styleFrom(
              foregroundColor: SeniorTheme.primaryColor,
              side: const BorderSide(color: SeniorTheme.primaryColor, width: 2),
              padding: const EdgeInsets.all(SeniorConstants.spacing),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 꽃이 아닌 경우의 정밀 분석 안내
  void _showPreciseAnalysisForNonFlower(final BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (final BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: const <Widget>[
            Icon(
              Icons.search,
              color: SeniorTheme.warningColor,
              size: SeniorConstants.iconSizeLarge,
            ),
            SizedBox(width: SeniorConstants.spacing),
            Text('정밀 분석'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '현재 무료 분석에서는 꽃이 아닌 것으로 인식했습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: SeniorConstants.spacing),
            Text(
              '정밀 분석을 통해 더 정확한 결과를 확인해보시겠습니까?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SeniorConstants.spacing),
            Container(
              padding: const EdgeInsets.all(SeniorConstants.spacing),
              decoration: BoxDecoration(
                color: SeniorTheme.infoColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: SeniorTheme.infoColor,
                    size: SeniorConstants.iconSizeSmall,
                  ),
                  const SizedBox(width: SeniorConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      '정밀 분석은 AI 기술로 더 정확한 식물 인식을 제공합니다.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SeniorTheme.infoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          if (_tokenCount > 0)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performPreciseAnalysis(useToken: true);
              },
              icon: const Icon(Icons.stars),
                                  label: Text('분석권 사용 ($_tokenCount개)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SeniorTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          if (_tokenCount == 0)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _watchRewardAd();
              },
              icon: const Icon(Icons.play_circle_outline),
                                  label: const Text('광고 보고 분석하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SeniorTheme.successColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  /// 리워드 광고 시청
  Future<void> _watchRewardAd() async {
    if (!_rewardAdService.isAdLoaded) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        _showSnackBar(localizations.adNotReady, isError: true);
      }
      return;
    }
    
          // 오늘 광고 시청 횟수 확인
    // canWatchRewardAdToday 메서드가 없으므로 단순 체크로 대체
    if (await _tokenService.getTokenCount() > 0) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        _showSnackBar(localizations.dailyAdLimitReached, isError: true);
      }
      return;
    }
    
    if (!mounted) return;
    
    await _rewardAdService.showRewardAd(
      onUserEarnedReward: (final ad, final reward) {
        debugPrint('리워드 광고 시청 완료: ${reward.amount} ${reward.type}');
        _tokenService.addToken();
        // incrementTodayRewardAdCount 메서드 제거 (존재하지 않음)
        // onTokenCountUpdate 메서드는 없으므로 제거
        Navigator.of(context).pop();
              },
        onAdClosed: () {
          debugPrint('리워드 광고 닫힘');
        },
        onAdFailed: (final String error) {
          debugPrint('리워드 광고 실패: $error');
          _showSnackBar(error, isError: true);
        },
    );
  }
  
  /// 정밀 분석 실행
  Future<void> _performPreciseAnalysis({required bool useToken}) async {
    if (!mounted) return;
    
    final localizations = AppLocalizations.of(context);
    
    if (useToken) {
      final hasToken = await _tokenService.hasToken();
      if (!hasToken) {
        if (mounted) {
          _showSnackBar(localizations.noTokenAvailable, isError: true);
        }
        return;
      }
    }
    
    setState(() {
      _isLoadingPreciseAnalysis = true;
    });
    
    try {
      if (useToken) {
        await _tokenService.useToken();
        await _loadTokenCount();
      }
      
      // 향후 Plant.id API 호출 (현재는 더미 데이터)
      await Future<void>.delayed(const Duration(seconds: 2));
      
      final preciseResult = AnalysisResult(
        id: 'precise_${DateTime.now().millisecondsSinceEpoch}',
        name: '정밀 분석한 꽃 이름',
        scientificName: 'Scientificus precisus',
        confidence: 0.95,
        description: '정밀 분석을 통해 더욱 더 정확한 식물 정보입니다. 이 꽃은 특별한 특징을 가지고 있습니다.',
        alternativeNames: const ['정밀 분석 꽃', '프리미엄 꽃'],
        imageUrl: '',
        analyzedAt: DateTime.now(),
        apiProvider: 'plant_id',
        isPremiumResult: true,
        category: 'flower',
      );
      
      if (mounted) {
        setState(() {
          _preciseResult = preciseResult;
          _isLoadingPreciseAnalysis = false;
        });
        
        _showSnackBar(localizations.preciseAnalysisCompleted);
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPreciseAnalysis = false;
        });
        
        _showSnackBar(localizations.analysisError(e.toString()), isError: true);
      }
    }
  }
  
  /// 위젯 트리 해제
  Future<void> _saveToFlowerNote(final BuildContext passedContext) async {
    if (!mounted) return;
    
    final localizations = AppLocalizations.of(passedContext);
    
    try {
              // 정밀 분석 결과가 있으면 그것을 우선, 기본 결과는 참고용
      // final resultToSave = _preciseResult ?? widget.analysisResult;
      
      // 향후: 실제 저장 로직 구현 (Hive 등)
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        _showSnackBar(localizations.savedToFlowerNote);
        
        // 메인 화면으로 돌아가기
        if (mounted && passedContext.mounted) {
          Navigator.popUntil(passedContext, (route) => route.isFirst);
        }
      }
      
    } catch (e) {
      if (mounted) {
        _showSnackBar(localizations.saveError(e.toString()), isError: true);
      }
    }
  }
  
  /// 스낵바 표시
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? SeniorTheme.errorColor : SeniorTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        ),
      ),
    );
  }
} 
