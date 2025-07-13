import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/analysis_result.dart';
import '../viewmodels/home_viewmodel.dart';

/// 📖 식물 도감 탭 위젯
class CollectionTab extends ConsumerWidget {
  const CollectionTab({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final analysisHistory = ref.watch(analysisHistoryProvider);
    
    if (analysisHistory.isEmpty) {
      return const _EmptyCollectionView();
    }

    return Column(
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🌸 발견한 식물들 (${analysisHistory.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => ref.read(homeViewModelProvider.notifier).clearAllHistoryCommand(),
                icon: const Icon(Icons.delete_outline),
                tooltip: '전체 삭제',
              ),
            ],
          ),
        ),
        
        // 식물 목록
        Expanded(
          child: ListView.builder(
            itemCount: analysisHistory.length,
            itemBuilder: (context, index) {
              final result = analysisHistory[index];
              return _PlantResultCard(result: result);
            },
          ),
        ),
      ],
    );
  }
}

/// 빈 컬렉션 상태 표시
class _EmptyCollectionView extends StatelessWidget {
  const _EmptyCollectionView();

  @override
  Widget build(final BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.park_outlined,
          size: 80,
          color: Colors.grey.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          '아직 발견한 식물이 없습니다',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '카메라 탭에서 식물을 촬영해보세요!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.withValues(alpha: 0.6),
          ),
        ),
      ],
    ),
  );
}

/// 개별 식물 결과 카드
class _PlantResultCard extends ConsumerWidget {
  final AnalysisResult result;
  
  const _PlantResultCard({required this.result});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: InkWell(
      onTap: () => _showDetailDialog(context, result),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 식물 이미지 (placeholder)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getColorByRarity(result.rarity),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconByCategory(result.category),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            
            // 식물 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.scientificName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // 신뢰도 표시
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(result.confidence),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          result.confidenceText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // API 제공자
                      Text(
                        result.providerDisplayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 액션 버튼들
            Column(
              children: [
                // 희귀도 표시
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < result.rarity ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => ref.read(homeViewModelProvider.notifier)
                      .deleteAnalysisResultCommand(result.id),
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  tooltip: '삭제',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  // 헬퍼 메서드들
  Color _getColorByRarity(final int rarity) {
    switch (rarity) {
      case 5: return Colors.purple;
      case 4: return Colors.blue;
      case 3: return Colors.green;
      case 2: return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getIconByCategory(final String category) {
    switch (category.toLowerCase()) {
      case 'plant': return Icons.local_florist;
      case 'flower': return Icons.local_florist;
      case 'tree': return Icons.park;
      default: return Icons.nature;
    }
  }

  Color _getConfidenceColor(final double confidence) {
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.8) return Colors.lightGreen;
    if (confidence >= 0.6) return Colors.orange;
    if (confidence >= 0.4) return Colors.deepOrange;
    return Colors.red;
  }

  void _showDetailDialog(final BuildContext context, final AnalysisResult result) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 학명
              if (result.scientificName.isNotEmpty) ...[
                Text(
                  '학명',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  result.scientificName,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
              ],
              
              // 설명
              if (result.description.isNotEmpty) ...[
                Text(
                  '설명',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(result.description),
                const SizedBox(height: 12),
              ],
              
              // 다른 이름들
              if (result.alternativeNames.isNotEmpty) ...[
                Text(
                  '다른 이름',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(result.alternativeNames.join(', ')),
                const SizedBox(height: 12),
              ],
              
              // 분석 정보
              Text(
                '분석 정보',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('신뢰도: ${result.confidenceText} (${(result.confidence * 100).toStringAsFixed(1)}%)'),
              Text('API: ${result.providerDisplayName}'),
              Text('분석 시간: ${_formatDateTime(result.analyzedAt)}'),
              
              // 희귀도
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('희귀도: '),
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < result.rarity ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(final DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
