import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/home_viewmodel.dart';

/// 🌸 식물 촬영 카메라 버튼 위젯
class CameraButton extends ConsumerWidget {
  const CameraButton({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final homeViewModel = ref.watch(homeViewModelProvider);
    final isAnalyzing = ref.watch(isAnalyzingProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 카메라 아이콘 (분석 중일 때 애니메이션)
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: isAnalyzing 
                ? Colors.orange 
                : Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isAnalyzing
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                )
              : const Icon(Icons.camera_alt, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 16),
        
        // 분석 상태 텍스트
        if (isAnalyzing)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '🤖 AI가 식물을 분석하고 있습니다...',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

        // 에러 메시지 표시
        if (homeViewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '❌ ${homeViewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.read(homeViewModelProvider.notifier).clearErrorCommand(),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ),
          ),

        // 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: isAnalyzing
                  ? null
                  : () => ref.read(homeViewModelProvider.notifier).captureFromCameraCommand(),
              icon: const Icon(Icons.camera),
              label: const Text('촬영'),
            ),
            ElevatedButton.icon(
              onPressed: isAnalyzing
                  ? null
                  : () => ref.read(homeViewModelProvider.notifier).selectFromGalleryCommand(),
              icon: const Icon(Icons.photo_library),
              label: const Text('갤러리'),
            ),
          ],
        ),

        // 성공 메시지 (최근 분석 결과가 있을 때)
        if (homeViewModel.hasHistory && !isAnalyzing && homeViewModel.errorMessage == null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    '✅ 분석 완료!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '총 ${homeViewModel.historyCount}개의 식물을 발견했습니다.',
                    style: TextStyle(
                      color: Colors.green.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '📖 "도감" 탭에서 확인해보세요!',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
