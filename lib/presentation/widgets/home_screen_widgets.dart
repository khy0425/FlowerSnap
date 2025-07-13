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
  }) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 타이틀
            Expanded(
              child: Text(
                AppLocalizations.of(context).homeTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // 분석 토큰 개수
            AnimatedContainer(
              duration: SeniorConstants.animationDurationFast,
              child: _buildTokenCountWidget(context, tokenCount),
            ),
            
            const SizedBox(width: SeniorConstants.spacingSmall),
            
            // 개발자 메뉴 버튼 (디버그 모드에서만)
            if (showDeveloperMenu)
              IconButton(
                onPressed: onDeveloperMenu,
                icon: const Icon(
                  Icons.bug_report,
                  color: Colors.white,
                  size: SeniorConstants.iconSizeLarge,
                ),
                tooltip: '개발자 테스트 메뉴',
              ),
            
            // 설정 버튼
            IconButton(
              onPressed: onSettings,
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: SeniorConstants.iconSizeLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 분석 토큰 개수 위젯
  static Widget _buildTokenCountWidget(final BuildContext context, final int tokenCount) {
    return AnimatedContainer(
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
  }

  /// 메인 카메라 섹션
  static Widget buildMainCameraSection(
    final BuildContext context, {
    required final bool isLoading,
    required final VoidCallback onTakePhoto,
    required final VoidCallback onSelectFromGallery,
  }) {
    return Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          children: [
            // 아이콘과 제목
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SeniorTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: SeniorTheme.primaryColor,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: SeniorConstants.iconSizeXLarge,
                color: SeniorTheme.primaryColor,
              ),
            ),
            const SizedBox(height: SeniorConstants.spacing),
            
            Text(
              AppLocalizations.of(context).takePhoto,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: SeniorTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SeniorConstants.spacingSmall),
            
            Text(
              AppLocalizations.of(context).takePhotoDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: SeniorTheme.textSecondaryColor,
              ),
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
                    color: SeniorTheme.primaryColor,
                    onPressed: onTakePhoto,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(width: SeniorConstants.spacing),
                Expanded(
                  child: _buildCameraButton(
                    context,
                    icon: Icons.photo_library,
                    label: AppLocalizations.of(context).gallery,
                    color: SeniorTheme.secondaryColor,
                    onPressed: onSelectFromGallery,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 카메라 버튼 위젯
  static Widget _buildCameraButton(
    final BuildContext context, {
    required final IconData icon,
    required final String label,
    required final Color color,
    required final VoidCallback onPressed,
    required final bool isLoading,
  }) {
    return AnimatedContainer(
      duration: SeniorConstants.animationDurationFast,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
          ? const SizedBox(
              width: SeniorConstants.iconSizeMedium,
              height: SeniorConstants.iconSizeMedium,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: SeniorConstants.iconSizeMedium),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: SeniorConstants.spacing,
            vertical: SeniorConstants.spacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
          ),
          elevation: SeniorConstants.elevationMedium,
        ),
      ),
    );
  }

  /// 오늘 배운 꽃 섹션
  static Widget buildTodayFlowerSection(
    final BuildContext context, 
    final List<AnalysisResult> analysisHistory,
  ) {
    return Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              icon: Icons.local_florist,
              title: AppLocalizations.of(context).todayFlower,
              color: SeniorTheme.primaryColor,
            ),
            const SizedBox(height: SeniorConstants.spacing),
            
            analysisHistory.isEmpty
                ? _buildEmptyState(
                    context,
                    icon: Icons.camera_alt_outlined,
                    title: AppLocalizations.of(context).noFlowerTaken,
                    subtitle: AppLocalizations.of(context).tryTakePhoto,
                  )
                : _buildTodayFlowerCard(context, analysisHistory.first),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 위젯
  static Widget _buildSectionHeader(
    final BuildContext context, {
    required final IconData icon,
    required final String title,
    required final Color color,
  }) {
    return Row(
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
  }

  /// 빈 상태 위젯
  static Widget _buildEmptyState(
    final BuildContext context, {
    required final IconData icon,
    required final String title,
    required final String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
      child: Column(
        children: [
          Icon(
            icon,
            size: SeniorConstants.iconSizeXLarge,
            color: SeniorTheme.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: SeniorConstants.spacing),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: SeniorTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: SeniorConstants.spacingSmall),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SeniorTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 오늘 배운 꽃 카드
  static Widget _buildTodayFlowerCard(final BuildContext context, final AnalysisResult flower) {
    return Container(
      decoration: SeniorTheme.specialCardDecoration(SeniorTheme.accentColor),
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacing),
        child: Row(
          children: [
            // 꽃 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
              child: Container(
                width: 80,
                height: 80,
                color: SeniorTheme.backgroundColor,
                child: flower.imageUrl.isNotEmpty
                    ? Image.network(
                        flower.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.local_florist, size: 40),
                      )
                    : const Icon(Icons.local_florist, size: 40),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (flower.scientificName.isNotEmpty) ...[
                    const SizedBox(height: SeniorConstants.spacingXSmall),
                    Text(
                      flower.scientificName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: SeniorTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: SeniorConstants.spacingSmall),
                  _buildConfidenceChip(context, flower.confidence),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 신뢰도 칩 위젯
  static Widget _buildConfidenceChip(final BuildContext context, final double confidence) {
    final color = SeniorTheme.getConfidenceColor(confidence);
    final icon = SeniorTheme.getConfidenceIcon(confidence);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SeniorConstants.spacingSmall,
        vertical: SeniorConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: SeniorConstants.spacingXSmall),
          Text(
            AppLocalizations.of(context).confidence((confidence * 100).toStringAsFixed(1)),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 환영 메시지
  static Widget buildWelcomeMessage(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SeniorTheme.primaryColor.withValues(alpha: 0.1),
            SeniorTheme.secondaryColor.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).welcomeMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: SeniorTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SeniorConstants.spacingSmall),
          Text(
            AppLocalizations.of(context).welcomeSubMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SeniorTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
} 