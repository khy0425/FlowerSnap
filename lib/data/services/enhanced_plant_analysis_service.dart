import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../models/analysis_result.dart';
import 'ensemble_analyzer.dart';

/// 향상된 식물 분석 서비스
/// 다중 API 호출 및 앙상블 기법으로 정확도 향상
class EnhancedPlantAnalysisService {
  final Logger _logger;
  final EnsembleAnalyzer _ensembleAnalyzer;
  
  /// 생성자 (의존성 주입)
  EnhancedPlantAnalysisService({
    final Logger? logger,
    final EnsembleAnalyzer? ensembleAnalyzer,
  }) : _logger = logger ?? Logger(),
       _ensembleAnalyzer = ensembleAnalyzer ?? EnsembleAnalyzer();
  
  /// 향상된 식물 분석 (다중 API 앙상블)
  Future<AnalysisResult?> analyzeImageEnhanced(final Uint8List imageBytes) async {
    try {
      _logger.i('🔬 향상된 식물 분석 시작...');
      
      // 다중 API 병렬 호출
      final results = await _performParallelAnalysis(imageBytes);
      
      // null이 아닌 결과만 필터링
      final validResults = results.where((final result) => result != null).cast<AnalysisResult>().toList();
      
      if (validResults.isEmpty) {
        _logger.w('모든 API에서 분석 실패');
        return null;
      }
      
      // 앙상블 결과 생성
      return _ensembleAnalyzer.createEnsembleResult(validResults);
      
    } catch (e, stackTrace) {
      _logger.e('향상된 분석 중 오류 발생', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// 실제 분석 결과를 반환하는 메서드 (mockup)
  Future<List<AnalysisResult?>> _performParallelAnalysis(final Uint8List imageBytes) async {
    // 실제 환경에서는 다중 API 호출
    
    // PlantNet API 호출 (mockup)
    final plantnetResult = await Future<AnalysisResult?>.delayed(
      const Duration(seconds: 1),
      () => AnalysisResult.createMock(
        name: 'PlantNet Mock',
        scientificName: 'Mockus plantneticus',
        confidence: 0.85,
        apiProvider: 'plantnet',
        category: 'plant',
      ),
    );
    
    // Plant.id API 호출 (mockup)
    final plantIdResult = await Future<AnalysisResult?>.delayed(
      const Duration(seconds: 2),
      () => AnalysisResult.createMock(
        name: 'Plant.ID Mock',
        scientificName: 'Mockus plantidicus',
        confidence: 0.92,
        apiProvider: 'plantid',
        category: 'plant',
      ),
    );
    
    // iNaturalist API 호출 (mockup)
    final iNaturalistResult = await Future<AnalysisResult?>.delayed(
      const Duration(seconds: 1),
      () => AnalysisResult.createMock(
        name: 'iNaturalist Mock',
        scientificName: 'Mockus inaturalisticus',
        confidence: 0.78,
        apiProvider: 'inaturalist',
        category: 'plant',
      ),
    );
    
    return [plantnetResult, plantIdResult, iNaturalistResult];
  }
} 