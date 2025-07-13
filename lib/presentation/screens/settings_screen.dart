import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/token_management_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.settings,
            size: 28,
            color: Colors.grey,
          ),
          SizedBox(width: 8),
          Text('FloraSnap 설정'),
        ],
      ),
      centerTitle: true,
    ),
    body: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // API 토큰 관리 섹션
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.vpn_key,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'API 토큰 관리',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '프리미엄 식물 인식을 위해 Plant.id API 토큰을 추가하세요.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                const TokenManagementWidget(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // API 비교 정보
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.compare_arrows,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'API 비교',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildApiComparisonTable(context),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Plant.id 토큰 구매 안내
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      'Plant.id 토큰 구매 방법',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPurchaseGuide(context),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 앱 정보
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '앱 정보',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.local_florist),
                  title: const Text('Bloomiary'),
                  subtitle: const Text('버전 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildApiComparisonTable(final BuildContext context) => Table(
    border: TableBorder.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    ),
    columnWidths: const {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(3),
      2: FlexColumnWidth(3),
    },
    children: [
      TableRow(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        children: [
          _buildTableHeader(context, '항목'),
          _buildTableHeader(context, 'PlantNet (무료)'),
          _buildTableHeader(context, 'Plant.id (유료)'),
        ],
      ),
      TableRow(
        children: [
          _buildTableCell(context, '정확도'),
          _buildTableCell(context, '⭐⭐⭐ 중간-높음'),
          _buildTableCell(context, '⭐⭐⭐⭐⭐ 매우 높음'),
        ],
      ),
      TableRow(
        children: [
          _buildTableCell(context, '응답시간'),
          _buildTableCell(context, '2-5초'),
          _buildTableCell(context, '1-3초'),
        ],
      ),
      TableRow(
        children: [
          _buildTableCell(context, '상세정보'),
          _buildTableCell(context, '기본'),
          _buildTableCell(context, '매우 상세'),
        ],
      ),
      TableRow(
        children: [
          _buildTableCell(context, '비용'),
          _buildTableCell(context, '무료'),
          _buildTableCell(context, '\$0.10/요청'),
        ],
      ),
    ],
  );

  Widget _buildTableHeader(final BuildContext context, final String text) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      );

  Widget _buildTableCell(final BuildContext context, final String text) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      );

  Widget _buildPurchaseGuide(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildGuideStep(
        context,
        '1',
        'Plant.id 웹사이트 방문',
        'https://web.plant.id/',
      ),
      const SizedBox(height: 8),
      _buildGuideStep(context, '2', '계정 생성 및 로그인', ''),
      const SizedBox(height: 8),
      _buildGuideStep(context, '3', 'API 크레딧 구매', '월 100회 무료, 추가는 \$0.10/요청'),
      const SizedBox(height: 8),
      _buildGuideStep(context, '4', 'API 키 복사', 'Profile > API Keys에서 확인'),
      const SizedBox(height: 8),
      _buildGuideStep(context, '5', '앱에 토큰 입력', '위의 토큰 관리에서 추가'),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () {
          // Plant.id 웹사이트 열기 기능
          _showInfoDialog(
            context,
            'Plant.id 웹사이트',
            'Plant.id 웹사이트에서 API 토큰을 구매하세요:\nhttps://web.plant.id/',
          );
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text('Plant.id 웹사이트 방문'),
      ),
    ],
  );

  Widget _buildGuideStep(
    final BuildContext context,
    final String step,
    final String title,
    final String subtitle,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    ],
  );

  void _showAboutDialog(final BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Bloomiary',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_florist, size: 48),
      children: [
        const Text('🌸 이미지 인식 기반 감성 정원 앱'),
        const SizedBox(height: 8),
        const Text('식물과 꽃을 촬영하여 AI로 인식하고, 나만의 정원을 만들어보세요!'),
      ],
    );
  }

  void _showInfoDialog(
    final BuildContext context,
    final String title,
    final String content,
  ) {
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
