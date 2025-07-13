import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../data/models/analysis_result.dart';
import '../../data/models/bounding_box.dart';
import '../../data/models/detection_result.dart';
import '../../data/services/enhanced_plant_analysis_service.dart';
import '../screens/flower_analysis_result_screen.dart';
import '../screens/settings_screen.dart';

class ImageAnalysisHelper {
  static final Logger _logger = Logger();

  /// 사진 촬영 후 분석
  static Future<void> takePictureAndAnalyze(
    final BuildContext context, {
    required final void Function(bool) setLoading,
  }) async {
    final XFile? image = await _pickImage(ImageSource.camera);
    if (image != null && context.mounted) {
      await _analyzeImage(context, File(image.path), setLoading: setLoading);
    }
  }

  /// 갤러리에서 사진 선택 후 분석
  static Future<void> pickFromGalleryAndAnalyze(
    final BuildContext context, {
    required final void Function(bool) setLoading,
  }) async {
    final XFile? image = await _pickImage(ImageSource.gallery);
    if (image != null && context.mounted) {
      await _analyzeImage(context, File(image.path), setLoading: setLoading);
    }
  }

  /// 이미지 선택 공통 메서드
  static Future<XFile?> _pickImage(final ImageSource source) async {
    final picker = ImagePicker();
    return await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }

  /// 이미지 분석 공통 메서드
  static Future<void> _analyzeImage(
    final BuildContext context,
    final File imageFile, {
    required final void Function(bool) setLoading,
  }) async {
    setLoading(true);

    try {
      _logger.i('🔍 고정밀 식물 분석 시작...');
      
      final analysisService = EnhancedPlantAnalysisService();
      final result = await analysisService.analyzeImageEnhanced(await imageFile.readAsBytes());
      
      if (result == null) {
        throw Exception('고정밀 분석에서 결과를 얻을 수 없습니다');
      }
      
      _logger.i('✅ 고정밀 분석 완료: ${result.name} (정확도 ${(result.confidence * 100).toStringAsFixed(1)}%)');
      
      final finalResult = _addBoundingBoxesToResult(result, imageFile);
      
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (final context) => FlowerAnalysisResultScreen(
              imageFile: imageFile,
              analysisResult: finalResult,
              isLowConfidence: finalResult.confidence < 0.7,
            ),
          ),
        );
      }
    } catch (e) {
      _logger.e('❌ API 분석 실패: $e');
      
      if (context.mounted) {
        _showApiErrorDialog(context, e.toString());
      }
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  /// API 에러 다이얼로그
  static void _showApiErrorDialog(final BuildContext context, final String error) {
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('API 연결 실패'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('실제 식물 인식 API에 연결할 수 없습니다.'),
            const SizedBox(height: 12),
            Text('오류: $error'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('해결 방법:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('• 인터넷 연결 상태 확인'),
                  Text('• Plant.id API 토큰 설정 (설정 메뉴)'),
                  Text('• 잠시 후 다시 시도'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (final context) => const SettingsScreen()),
              );
            },
            child: const Text('설정으로 가기'),
          ),
        ],
      ),
    );
  }

  /// API 결과에 바운딩 박스 추가
  static AnalysisResult _addBoundingBoxesToResult(final AnalysisResult result, final File imageFile) {
    final List<DetectionResult> detectionResults = [];
    
    // 식물인 경우에만 바운딩 박스 생성
    if (result.isFlower && result.category == 'plant' && result.confidence > 0.5) {
      final random = DateTime.now().microsecond;
      
      final x = 0.15 + (random % 50) / 100.0; // 0.15 ~ 0.65
      final y = 0.10 + (random % 60) / 100.0; // 0.10 ~ 0.70
      final width = 0.25 + (random % 40) / 100.0; // 0.25 ~ 0.65
      final height = 0.25 + (random % 45) / 100.0; // 0.25 ~ 0.70
      
      detectionResults.add(
        DetectionResult(
          boundingBox: BoundingBox(
            left: x,
            top: y,
            width: width,
            height: height,
          ),
          confidence: result.confidence,
          label: result.name,
        ),
      );
    }
    
    return AnalysisResult(
      id: result.id,
      name: result.name,
      scientificName: result.scientificName,
      confidence: result.confidence,
      description: result.description,
      alternativeNames: result.alternativeNames,
      imageUrl: imageFile.path,
      analyzedAt: result.analyzedAt,
      apiProvider: result.apiProvider,
      isPremiumResult: result.isPremiumResult,
      category: result.category,
      rarity: result.rarity,
      additionalInfo: result.additionalInfo,
      detectionResults: detectionResults,
    );
  }
} 