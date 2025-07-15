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

/// 이미지 분석을 위한 헬퍼 클래스 (의존성 주입 패턴 적용)
class ImageAnalysisHelper {
  final Logger _logger;
  final ImagePicker _imagePicker;
  final EnhancedPlantAnalysisService _analysisService;

  /// 생성자 (의존성 주입)
  ImageAnalysisHelper({
    final Logger? logger,
    final ImagePicker? imagePicker,
    final EnhancedPlantAnalysisService? analysisService,
  }) : _logger = logger ?? Logger(),
        _imagePicker = imagePicker ?? ImagePicker(),
        _analysisService = analysisService ?? EnhancedPlantAnalysisService();

  /// 기본 인스턴스 생성 (싱글톤 패턴)
  static ImageAnalysisHelper? _instance;
  static ImageAnalysisHelper get instance => _instance ??= ImageAnalysisHelper();

  /// 사진 촬영 후 분석
  Future<void> takePictureAndAnalyze(
    final BuildContext context, {
    required final void Function(bool) setLoading,
  }) async {
    final XFile? image = await _pickImage(ImageSource.camera);
    if (image != null && context.mounted) {
      await _analyzeImage(context, File(image.path), setLoading: setLoading);
    }
  }

  /// 갤러리에서 사진 선택 후 분석
  Future<void> pickFromGalleryAndAnalyze(
    final BuildContext context, {
    required final void Function(bool) setLoading,
  }) async {
    final XFile? image = await _pickImage(ImageSource.gallery);
    if (image != null && context.mounted) {
      await _analyzeImage(context, File(image.path), setLoading: setLoading);
    }
  }

  /// 이미지 선택 공통 메서드
  Future<XFile?> _pickImage(final ImageSource source) async => await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

  /// 이미지 분석 공통 메서드
  Future<void> _analyzeImage(
    final BuildContext context,
    final File imageFile, {
    required final void Function(bool) setLoading,
  }) async {
    setLoading(true);
    
    try {
      _logger.i('🔍 이미지 분석 시작...');
      
      // 향상된 분석 서비스 사용
      final AnalysisResult? analysisResult = await _analysisService.analyzeImageEnhanced(
        await imageFile.readAsBytes(),
      );

      if (context.mounted) {
        if (analysisResult != null) {
          _logger.i('✅ 분석 성공: ${analysisResult.name}');
          
          // 바운딩 박스 추가 (만약 있다면)
          final AnalysisResult resultWithBoundingBox = _addBoundingBoxesToResult(
            analysisResult,
            imageFile,
          );
          
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (final context) => FlowerAnalysisResultScreen(
                imageFile: imageFile,
                analysisResult: resultWithBoundingBox,
              ),
            ),
          );
        } else {
          _logger.e('❌ 분석 실패: 결과가 null');
          _showApiErrorDialog(context, '식물을 인식할 수 없습니다.');
        }
      }
    } catch (e) {
      _logger.e('❌ 분석 중 오류 발생: $e');
      if (context.mounted) {
        _showApiErrorDialog(context, e.toString());
      }
    } finally {
      setLoading(false);
    }
  }

  /// API 오류 다이얼로그 표시
  void _showApiErrorDialog(final BuildContext context, final String error) {
    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('분석 실패'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이미지 분석에 실패했습니다.'),
            const SizedBox(height: 8),
            Text(
              '오류: $error',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '다음 사항을 확인해주세요:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• 인터넷 연결 상태'),
            const Text('• 이미지 품질 (흐림, 너무 어두움)'),
            const Text('• 식물이 명확하게 보이는지'),
            const Text('• API 토큰 잔여량'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (final context) => const SettingsScreen(),
                ),
              );
            },
            child: const Text('설정'),
          ),
        ],
      ),
    );
  }

  /// 바운딩 박스를 결과에 추가
  AnalysisResult _addBoundingBoxesToResult(
    final AnalysisResult result,
    final File imageFile,
  ) {
    // 실제 바운딩 박스 데이터가 있다면 추가
    // 현재는 임시로 전체 이미지를 바운딩 박스로 설정
    const boundingBox = BoundingBox(
      left: 0.1,
      top: 0.1,
      width: 0.8,
      height: 0.8,
    );
    
    final detection = DetectionResult(
      boundingBox: boundingBox,
      confidence: result.confidence,
      label: result.name,
    );
    
    return AnalysisResult(
      id: result.id,
      name: result.name,
      scientificName: result.scientificName,
      confidence: result.confidence,
      description: result.description,
      alternativeNames: result.alternativeNames,
      imageUrl: result.imageUrl,
      analyzedAt: result.analyzedAt,
      apiProvider: result.apiProvider,
      isPremiumResult: result.isPremiumResult,
      category: result.category,
      rarity: result.rarity,
      additionalInfo: result.additionalInfo,
      detectionResults: [detection],
    );
  }

  /// 이 헬퍼에서 사용하는 종전 static 메서드들 호환성 유지
  @Deprecated('Use instance.takePictureAndAnalyze instead')
  static Future<void> takePictureAndAnalyzeStatic(
    final BuildContext context, {
    required final void Function(bool) setLoading,
  }) async => await instance.takePictureAndAnalyze(context, setLoading: setLoading);

  @Deprecated('Use instance.pickFromGalleryAndAnalyze instead')
  static Future<void> pickFromGalleryAndAnalyzeStatic(
    final BuildContext context, {
    required final void Function(bool) setLoading,
  }) async => await instance.pickFromGalleryAndAnalyze(context, setLoading: setLoading);
} 