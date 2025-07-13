import 'package:flutter/material.dart';

import '../../core/theme/senior_theme.dart';
import '../../data/services/analysis_token_service.dart';

class PremiumWidgets {
  /// 프리미엄 기능 안내 섹션
  static Widget buildPremiumPromoSection(
    BuildContext context, {
    required VoidCallback onRewardAd,
    required VoidCallback onPurchase,
  }) {
    return Container(
      margin: const EdgeInsets.all(SeniorConstants.spacing),
      padding: const EdgeInsets.all(SeniorConstants.spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SeniorTheme.accentColor.withValues(alpha: 0.1),
            SeniorTheme.primaryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(
          color: SeniorTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
                decoration: BoxDecoration(
                  color: SeniorTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
                ),
                child: const Icon(
                  Icons.stars,
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
                      "Plant.id 프리미엄 분석",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SeniorTheme.accentColor,
                      ),
                    ),
                    Text(
                      "정확도 95%+ 전문 AI 분석",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SeniorTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SeniorConstants.spacing),
          
          // 간단한 액션 버튼들
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRewardAd,
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text("광고 보고 토큰 받기"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SeniorTheme.accentColor,
                    side: const BorderSide(color: SeniorTheme.accentColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: SeniorConstants.spacingSmall,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SeniorConstants.spacingSmall),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPurchase,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("토큰 구매"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SeniorTheme.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: SeniorConstants.spacingSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 토큰 획득 완료 다이얼로그
  static void showTokenEarnedDialog(BuildContext context, int tokens) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.stars, color: SeniorTheme.accentColor),
            SizedBox(width: 8),
            Text('토큰 획득!'),
          ],
        ),
        content: Text('총 $tokens개의 프리미엄 분석 토큰을 획득했습니다!\n이제 Plant.id 고정밀 분석을 사용할 수 있어요'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 테스트용 토큰 지급 다이얼로그
  static void showTestTokenDialog(
    BuildContext context, {
    required AnalysisTokenService tokenService,
    required VoidCallback onTokenCountUpdate,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: SeniorTheme.accentColor),
            SizedBox(width: 8),
            Text('테스트 모드'),
          ],
        ),
        content: const Text('개발 테스트 모드입니다.\n테스트 시나리오를 선택하세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(context);
              await tokenService.addTokens(1);
              onTokenCountUpdate();
              
              if (context.mounted) {
                showTokenEarnedDialog(context, 1);
              }
            },
            child: const Text('토큰 1개 받기'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await tokenService.addTokens(5);
              onTokenCountUpdate();
              
              if (context.mounted) {
                showTokenEarnedDialog(context, 5);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SeniorTheme.accentColor,
            ),
            child: const Text('토큰 5개 받기'),
          ),
        ],
      ),
    );
  }

  /// 간단한 프리미엄 구매 다이얼로그
  static void showSimplePurchaseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.diamond, color: SeniorTheme.accentColor),
            SizedBox(width: 8),
            Text('프리미엄 토큰 구매'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Plant.id 고정밀 분석 토큰을 구매하세요'),
            SizedBox(height: 16),
            Text('• 토큰 10개: 2,900원 (290원/개)'),
            Text('• 정확도 95% 이상'),
            Text('• 상세한 식물 정보 제공'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('결제 시스템 준비 중입니다. 지금은 광고를 보고 무료 토큰을 받아보세요'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SeniorTheme.accentColor,
            ),
            child: const Text('구매하기'),
          ),
        ],
      ),
    );
  }
} 