import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/analysis_result.dart';
import '../viewmodels/home_viewmodel.dart';

/// 🌿 사용자의 디지털 정원 그리드
class GardenGrid extends ConsumerWidget {
  const GardenGrid({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final analysisHistory = ref.watch(analysisHistoryProvider);
    
    if (analysisHistory.isEmpty) {
      return const _EmptyGardenView();
    }

    return Column(
      children: [
        // 정원 상태 헤더
        _GardenStatsHeader(plantsCount: analysisHistory.length),
        const SizedBox(height: 16),
        
        // 식물 그리드
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: analysisHistory.length,
            itemBuilder: (context, index) {
              final plant = analysisHistory[index];
              return _PlantCard(plant: plant, index: index);
            },
          ),
        ),
      ],
    );
  }
}

/// 빈 정원 상태 표시
class _EmptyGardenView extends StatelessWidget {
  const _EmptyGardenView();

  @override
  Widget build(final BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 빈 정원 일러스트
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.yard_outlined,
            size: 60,
            color: Colors.green.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '🌱 텅 빈 정원이에요',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '첫 번째 식물을 심어보세요!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '📸 카메라로 식물을 촬영하면\n🌸 아름다운 디지털 정원이 만들어집니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

/// 정원 통계 헤더
class _GardenStatsHeader extends StatelessWidget {
  final int plantsCount;
  
  const _GardenStatsHeader({required this.plantsCount});

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green.withValues(alpha: 0.1),
          Colors.blue.withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.green.withValues(alpha: 0.2),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌿 내 정원',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$plantsCount개의 식물이 자라고 있어요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.park,
            color: Colors.green.shade600,
            size: 24,
          ),
        ),
      ],
    ),
  );
}

/// 개별 식물 카드
class _PlantCard extends ConsumerWidget {
  final AnalysisResult plant;
  final int index;
  
  const _PlantCard({required this.plant, required this.index});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) => Card(
    elevation: 2,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: InkWell(
      onTap: () => _showPlantDetail(context, plant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 식물 이미지 영역
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _getGradientByRarity(plant.rarity),
              ),
              child: Stack(
                children: [
                  // 메인 아이콘
                  Center(
                    child: Icon(
                      _getIconByCategory(plant.category),
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  
                  // 희귀도 표시
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          plant.rarity,
                          (index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // API 제공자 표시
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: plant.isPremiumResult 
                            ? Colors.purple.withValues(alpha: 0.8)
                            : Colors.green.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        plant.isPremiumResult ? 'PRO' : 'FREE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 식물 정보 영역
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 식물 이름
                  Text(
                    plant.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // 학명
                  if (plant.scientificName.isNotEmpty)
                    Text(
                      plant.scientificName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  const Spacer(),
                  
                  // 신뢰도 및 날짜
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 신뢰도
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(plant.confidence),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(plant.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      // 발견 시간
                      Text(
                        _getRelativeTime(plant.analyzedAt),
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
          ),
        ],
      ),
    ),
  );

  // 헬퍼 메서드들
  LinearGradient _getGradientByRarity(final int rarity) {
    switch (rarity) {
      case 5:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade400, Colors.pink.shade400],
        );
      case 4:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.cyan.shade400],
        );
      case 3:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.teal.shade400],
        );
      case 2:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.amber.shade400],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade400, Colors.grey.shade500],
        );
    }
  }

  IconData _getIconByCategory(final String category) {
    switch (category.toLowerCase()) {
      case 'plant':
      case 'flower':
        return Icons.local_florist;
      case 'tree':
        return Icons.park;
      default:
        return Icons.nature;
    }
  }

  Color _getConfidenceColor(final double confidence) {
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.8) return Colors.lightGreen;
    if (confidence >= 0.6) return Colors.orange;
    if (confidence >= 0.4) return Colors.deepOrange;
    return Colors.red;
  }

  String _getRelativeTime(final DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  void _showPlantDetail(final BuildContext context, final AnalysisResult plant) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getIconByCategory(plant.category)),
            const SizedBox(width: 8),
            Expanded(child: Text(plant.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 희귀도 표시
              Row(
                children: [
                  const Text('희귀도: '),
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < plant.rarity ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 기본 정보
              if (plant.scientificName.isNotEmpty) ...[
                const Text('학명', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(plant.scientificName, style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 8),
              ],
              
              if (plant.description.isNotEmpty) ...[
                const Text('설명', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(plant.description),
                const SizedBox(height: 8),
              ],
              
              // 분석 정보
              const Text('분석 정보', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('신뢰도: ${plant.confidenceText} (${(plant.confidence * 100).toStringAsFixed(1)}%)'),
              Text('API: ${plant.providerDisplayName}'),
              Text('발견 시간: ${_formatDateTime(plant.analyzedAt)}'),
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
