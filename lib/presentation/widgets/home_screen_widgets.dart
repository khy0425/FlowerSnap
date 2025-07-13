import 'package:flutter/material.dart';

import '../../core/theme/senior_theme.dart';
import '../../data/models/analysis_result.dart';
import '../../generated/l10n/app_localizations.dart';

class HomeScreenWidgets {
  /// 앱바 커스텀 빌드
  static Widget buildAppBar(
    final BuildContext context, {
    required final int tokenCount,
    required final VoidCallback onDeveloperMenu,
    required final VoidCallback onSettings,
    required final bool showDeveloperMenu,
  }) => Container(
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
            // 로고와 타이틀
            const Icon(
              Icons.local_florist,
              color: Colors.white,
              size: SeniorConstants.iconSizeLarge,
            ),
            const SizedBox(width: SeniorConstants.spacingSmall),
            Text(
              AppLocalizations.of(context).appTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const Spacer(),
            
            // 토큰 카운터
            _buildTokenCountWidget(context, tokenCount),
            
            const SizedBox(width: SeniorConstants.spacingSmall),
            
            // 개발자 메뉴 버튼 (개발 모드에서만 표시)
            if (showDeveloperMenu)
              IconButton(
                onPressed: onDeveloperMenu,
                icon: const Icon(Icons.developer_mode, color: Colors.white),
                tooltip: '개발자 메뉴',
              ),
            
            // 설정 버튼
            IconButton(
              onPressed: onSettings,
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: AppLocalizations.of(context).settings,
            ),
          ],
        ),
      ),
    );

  /// 분석 토큰 개수 위젯
  static Widget _buildTokenCountWidget(final BuildContext context, final int tokenCount) => AnimatedContainer(
      duration: SeniorConstants.animationDurationFast,
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
            '$tokenCount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

  /// 메인 카메라 섹션
  static Widget buildMainCameraSection(
    final BuildContext context, {
    required final bool isLoading,
    required final VoidCallback onTakePhoto,
    required final VoidCallback onSelectFromGallery,
  }) => Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
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
                  child: const Icon(
                    Icons.camera_alt,
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
                        AppLocalizations.of(context).takePhoto,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: SeniorTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).takePhotoDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SeniorTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: SeniorConstants.spacingLarge),
            
            // 카메라 버튼들
            Row(
              children: [
                Expanded(
                  child: _buildCameraButton(
                    context,
                    icon: Icons.camera_alt,
                    label: AppLocalizations.of(context).camera,
                    onPressed: isLoading ? null : onTakePhoto,
                    isLoading: isLoading,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: _buildCameraButton(
                    context,
                    icon: Icons.photo_library,
                    label: AppLocalizations.of(context).gallery,
                    onPressed: isLoading ? null : onSelectFromGallery,
                    isLoading: false,
                    isPrimary: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  /// 카메라 버튼 위젯
  static Widget _buildCameraButton(
    final BuildContext context, {
    required final IconData icon,
    required final String label,
    required final VoidCallback? onPressed,
    required final bool isLoading,
    required final bool isPrimary,
  }) => Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: isPrimary 
            ? LinearGradient(
                colors: [
                  SeniorTheme.accentColor,
                  SeniorTheme.accentColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  SeniorTheme.primaryColor.withValues(alpha: 0.1),
                  SeniorTheme.primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(
          color: isPrimary 
              ? SeniorTheme.accentColor 
              : SeniorTheme.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 32,
                  color: isPrimary ? Colors.white : SeniorTheme.primaryColor,
                ),
              
              const SizedBox(height: SeniorConstants.spacingSmall),
              
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isPrimary ? Colors.white : SeniorTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

  /// 오늘 배운 꽃 섹션
  static Widget buildTodayFlowerSection(
    final BuildContext context, 
    final List<AnalysisResult> analysisHistory,
  ) => Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              icon: Icons.eco,
              title: AppLocalizations.of(context).todayFlower,
              color: SeniorTheme.secondaryColor,
            ),
            const SizedBox(height: SeniorConstants.spacing),
            
            analysisHistory.isEmpty
                ? _buildEmptyState(context)
                : Column(
                    children: analysisHistory
                        .take(3)
                        .map((final flower) => Padding(
                              padding: const EdgeInsets.only(bottom: SeniorConstants.spacing),
                              child: _buildTodayFlowerCard(context, flower),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );

  /// 섹션 헤더
  static Widget _buildSectionHeader(
    final BuildContext context, {
    required final IconData icon,
    required final String title,
    required final Color color,
  }) => Row(
      children: [
        Container(
          padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
          ),
          child: Icon(
            icon,
            color: color,
            size: SeniorConstants.iconSizeLarge,
          ),
        ),
        const SizedBox(width: SeniorConstants.spacing),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );

  /// 빈 상태 위젯
  static Widget _buildEmptyState(final BuildContext context) => Container(
      padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
      decoration: BoxDecoration(
        color: SeniorTheme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(
          color: SeniorTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.eco,
            size: 48,
            color: SeniorTheme.textSecondaryColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: SeniorConstants.spacing),
          Text(
            AppLocalizations.of(context).noFlowerTaken,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: SeniorTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SeniorConstants.spacingSmall),
          Text(
            AppLocalizations.of(context).tryTakePhoto,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SeniorTheme.textSecondaryColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  /// 오늘 배운 꽃 카드
  static Widget _buildTodayFlowerCard(final BuildContext context, final AnalysisResult flower) => Container(
      decoration: BoxDecoration(
        color: SeniorTheme.backgroundColor,
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(
          color: SeniorTheme.primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: const [
          BoxShadow(
            color: SeniorTheme.cardElevationColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacing),
        child: Row(
          children: [
            // 꽃 이미지
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: SeniorTheme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
                border: Border.all(
                  color: SeniorTheme.secondaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.local_florist,
                color: SeniorTheme.secondaryColor,
                size: SeniorConstants.iconSizeLarge,
              ),
            ),
            
            const SizedBox(width: SeniorConstants.spacing),
            
            // 꽃 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flower.name.isNotEmpty ? flower.name : AppLocalizations.of(context).unknownFlower,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (flower.confidence > 0)
                    _buildConfidenceChip(context, flower.confidence),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  /// 신뢰도 칩
  static Widget _buildConfidenceChip(final BuildContext context, final double confidence) => Container(
      margin: const EdgeInsets.only(top: SeniorConstants.spacingXSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: SeniorConstants.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getConfidenceColor(confidence).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getConfidenceColor(confidence).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        '${(confidence * 100).toStringAsFixed(1)}%',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _getConfidenceColor(confidence),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

  /// 환영 메시지
  static Widget buildWelcomeMessage(final BuildContext context) => Container(
      padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SeniorTheme.primaryColor.withValues(alpha: 0.1),
            SeniorTheme.accentColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(
          color: SeniorTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.favorite,
            color: SeniorTheme.primaryColor,
            size: SeniorConstants.iconSizeLarge,
          ),
          const SizedBox(height: SeniorConstants.spacing),
          Text(
            AppLocalizations.of(context).welcomeMessage,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: SeniorTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

  /// 신뢰도 색상 결정
  static Color _getConfidenceColor(final double confidence) =>
      confidence >= 0.8 ? Colors.green :
      confidence >= 0.6 ? Colors.orange :
      Colors.red;

  /// 에러 위젯
  // ignore: prefer_expression_function_bodies
  static Widget buildErrorWidget(final BuildContext context, final Object error, final StackTrace? stackTrace) {
    return Container(
      padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: SeniorConstants.spacing),
          Text(
            '오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SeniorConstants.spacingSmall),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 로딩 위젯
  static Widget buildLoadingWidget(final BuildContext context) => Container(
      padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
      decoration: SeniorTheme.cardDecoration,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: SeniorTheme.primaryColor,
          ),
          SizedBox(height: SeniorConstants.spacing),
          Text(
            '분석 중...',
            style: TextStyle(
              color: SeniorTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
} 