import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/senior_theme.dart';
import '../../data/models/analysis_result.dart';
import '../../data/services/analysis_token_service.dart';
import '../screens/flower_analysis_result_screen.dart';

class DeveloperMenu {
  /// 개발자 메뉴 표시 (디버그 모드에서만)
  static void showDeveloperMenu(
    final BuildContext context, {
    required final AnalysisTokenService tokenService,
    required final VoidCallback onTokenCountUpdate,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개발자 테스트 메뉴'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh, color: SeniorTheme.primaryColor),
              title: const Text('토큰 초기화'),
              subtitle: const Text('토큰을 0개로 초기화'),
              onTap: () async {
                Navigator.pop(context);
                await tokenService.resetTokens();
                onTokenCountUpdate();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('모든 토큰이 초기화되었습니다.')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.diamond, color: SeniorTheme.accentColor),
              title: const Text('프리미엄 데모 토큰'),
              subtitle: const Text('토큰 100개 지급으로 프리미엄 기능 체험'),
              onTap: () async {
                Navigator.pop(context);
                await tokenService.addTokens(100);
                onTokenCountUpdate();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('개발 프리미엄 데모 토큰 100개를 지급했습니다'),
                      backgroundColor: SeniorTheme.accentColor,
                    ),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: SeniorTheme.primaryColor),
              title: const Text('테스트 분석'),
              subtitle: const Text('갤러리에서 사진 선택하여 테스트 분석'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _pickImage(ImageSource.gallery);
                if (image != null && context.mounted) {
                  final imageFile = File(image.path);
                  final result = _generateSimpleTestResult(imageFile);
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => FlowerAnalysisResultScreen(
                        imageFile: imageFile,
                        analysisResult: result,
                        isLowConfidence: result.confidence < 0.7,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  /// 이미지 선택 공통 메서드
  static Future<XFile?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    return await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// 간단한 테스트 결과 생성
  static AnalysisResult _generateSimpleTestResult(File imageFile) {
    final testPlants = [
      {
        'name': '몬스테라 델리시오사',
        'scientificName': 'Monstera deliciosa',
        'confidence': 0.92,
        'description': '잎에 구멍이 특징적인 인기 관엽식물입니다. 실내에서 기르기 쉽고 공기정화 효과가 뛰어납니다.',
        'alternativeNames': ['몬스테라', '구멍난 몬스테라'],
      },
      {
        'name': '산세베리아',
        'scientificName': 'Sansevieria trifasciata',
        'confidence': 0.89,
        'description': '스네이크 플랜트로도 불리는 다육질 관엽식물입니다. 관리가 매우 쉽습니다.',
        'alternativeNames': ['스네이크 플랜트', '시랑의 꼬리'],
      },
      {
        'name': '고무나무',
        'scientificName': 'Ficus elastica',
        'confidence': 0.85,
        'description': '광택 나는 큰 잎이 특징인 대표적인 실내 관엽식물입니다.',
        'alternativeNames': ['피쿠스 엘라스티카'],
      },
    ];

    final random = DateTime.now().millisecondsSinceEpoch % testPlants.length;
    final data = testPlants[random];

    return AnalysisResult(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      name: data['name'] as String,
      scientificName: data['scientificName'] as String,
      confidence: data['confidence'] as double,
      description: data['description'] as String,
      alternativeNames: data['alternativeNames'] as List<String>,
      imageUrl: imageFile.path,
      analyzedAt: DateTime.now(),
      apiProvider: 'test',
      isPremiumResult: false,
      category: 'plant',
      boundingBoxes: const [],
    );
  }
} 