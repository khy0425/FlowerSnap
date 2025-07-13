import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../models/analysis_result.dart';

/// 향상된 식물 분석 서비스
/// 다중 API 호출 및 앙상블 기법으로 정확도 향상
class EnhancedPlantAnalysisService {
  final Logger _logger = Logger();
  
  // 신뢰도 임계값 (현재 미사용이지만 향후 앙상블 로직 확장 시 활용 예정)
  
  /// 향상된 식물 분석 (다중 API 앙상블)
  Future<AnalysisResult?> analyzeImageEnhanced(final Uint8List imageBytes) async {
    try {
      _logger.i('🔬 향상된 식물 분석 시작...');
      
      // 다중 API 병렬 호출
      final results = await Future.wait([
        _analyzePlantNet(imageBytes),
        _analyzePlantId(imageBytes),
        _analyzeGoogleVision(imageBytes),
      ]);
      
      // null이 아닌 결과만 필터링
      final validResults = results.where((final result) => result != null).cast<AnalysisResult>().toList();
      
      if (validResults.isEmpty) {
        _logger.w('모든 API에서 분석 실패');
        return null;
      }
      
      // 앙상블 결과 생성
      return _createEnsembleResult(validResults);
      
    } catch (e, stackTrace) {
      _logger.e('향상된 분석 중 오류 발생', error: e, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// PlantNet API 분석
  Future<AnalysisResult?> _analyzePlantNet(final Uint8List imageBytes) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500)); // 시뮬레이션
      
      // PlantNet API 호출 시뮬레이션
      return AnalysisResult(
        id: 'plantnet_${DateTime.now().millisecondsSinceEpoch}',
        name: '장미',
        scientificName: 'Rosa rubiginosa',
        confidence: 0.87,
        description: 'PlantNet에서 인식된 장미입니다.',
        alternativeNames: const ['Rose', 'Garden Rose'],
        imageUrl: '',
        analyzedAt: DateTime.now(),
        apiProvider: 'plantnet',
        isPremiumResult: false,
        category: 'flower',
        rarity: 3,
        additionalInfo: const {'source': 'plantnet', 'method': 'visual_recognition'},
      );
    } catch (e) {
      _logger.w('PlantNet API 호출 실패: $e');
      return null;
    }
  }
  
  /// PlantId API 분석
  Future<AnalysisResult?> _analyzePlantId(final Uint8List imageBytes) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 700)); // 시뮬레이션
      
      return AnalysisResult(
        id: 'plantid_${DateTime.now().millisecondsSinceEpoch}',
        name: '장미',
        scientificName: 'Rosa gallica',
        confidence: 0.91,
        description: 'PlantId에서 인식된 프랑스 장미입니다.',
        alternativeNames: const ['French Rose', 'Gallica Rose'],
        imageUrl: '',
        analyzedAt: DateTime.now(),
        apiProvider: 'plantid',
        isPremiumResult: true,
        category: 'flower',
        rarity: 4,
        additionalInfo: const {'source': 'plantid', 'method': 'deep_learning'},
      );
    } catch (e) {
      _logger.w('PlantId API 호출 실패: $e');
      return null;
    }
  }
  
  /// Google Vision API 분석
  Future<AnalysisResult?> _analyzeGoogleVision(final Uint8List imageBytes) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300)); // 시뮬레이션
      
      return AnalysisResult(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        name: '장미',
        scientificName: 'Rosa damascena',
        confidence: 0.83,
        description: 'Google Vision에서 인식된 다마스크 장미입니다.',
        alternativeNames: const ['Damascus Rose', 'Damask Rose'],
        imageUrl: '',
        analyzedAt: DateTime.now(),
        apiProvider: 'google_vision',
        isPremiumResult: false,
        category: 'flower',
        rarity: 5,
        additionalInfo: const {'source': 'google_vision', 'method': 'label_detection'},
        detectionResults: const [],
      );
    } catch (e) {
      _logger.w('Google Vision API 호출 실패: $e');
      return null;
    }
  }
  
  /// 앙상블 결과 생성
  AnalysisResult _createEnsembleResult(final List<AnalysisResult> validResults) {
    if (validResults.length == 1) {
      return validResults.first;
    }
    
    // 검증된 결과만 사용
    final verifiedResults = validResults.where(_isValidResult).toList();
    
    if (verifiedResults.isEmpty) {
      return validResults.first; // 최소한 하나는 반환
    }
    
    // 신뢰도 순으로 정렬
    verifiedResults.sort((final a, final b) => b.confidence.compareTo(a.confidence));
    
    // 가중평균 신뢰도 계산
    final double ensembleConfidence = _calculateWeightedConfidence(verifiedResults);
    
    // 가장 일치하는 이름 선택
    final String bestName = _selectBestName(verifiedResults);
    final String bestScientificName = _selectBestScientificName(verifiedResults);
    
    // 통합된 설명 생성
    final String combinedDescription = _generateCombinedDescription(verifiedResults);
    
    // 모든 대체 이름 통합
    final List<String> allAlternatives = verifiedResults
        .expand((final r) => r.alternativeNames)
        .toSet()
        .toList();
    
    return AnalysisResult(
      id: 'ensemble_${DateTime.now().millisecondsSinceEpoch}',
      name: bestName,
      scientificName: bestScientificName,
      confidence: ensembleConfidence,
      description: combinedDescription,
      alternativeNames: allAlternatives,
      imageUrl: verifiedResults.first.imageUrl,
      analyzedAt: DateTime.now(),
      apiProvider: 'ensemble_${verifiedResults.map((final r) => r.apiProvider).join('+')}',
      isPremiumResult: verifiedResults.any((final r) => r.isPremiumResult),
      category: verifiedResults.first.category,
      rarity: _calculateAverageRarity(verifiedResults),
      additionalInfo: {
        'ensemble_method': 'weighted_voting',
        'source_apis': verifiedResults.map((final r) => r.apiProvider).toList(),
        'individual_confidences': verifiedResults.map((final r) => r.confidence).toList(),
        'result_count': verifiedResults.length,
      },
      detectionResults: verifiedResults.first.detectionResults,
    );
  }
  
  /// 결과의 유효성 검증
  bool _isValidResult(final AnalysisResult result) {
    // 1. 신뢰도 검사
    if (result.confidence < 0.3) return false;
    
    // 2. 이름 검사
    if (result.name.isEmpty) return false;
    
    // 3. 학명 검사 (선택적)
    if (result.scientificName.isNotEmpty && 
        result.scientificName.split(' ').length < 2) return false;
    
    // 4. 이름의 유효성 검사
    if (result.name.toLowerCase().contains('unknown') || 
        result.name.toLowerCase().contains('불명') ||
        result.name.length < 3) {
      return false;
    }
    
    return true;
  }
  
  /// 가중평균 신뢰도 계산
  double _calculateWeightedConfidence(final List<AnalysisResult> results) {
    if (results.isEmpty) return 0.0;
    
    double totalWeight = 0.0;
    double weightedSum = 0.0;
    
    for (final result in results) {
      final double weight = _getApiWeight(result.apiProvider);
      totalWeight += weight;
      weightedSum += result.confidence * weight;
    }
    
    return totalWeight > 0 ? weightedSum / totalWeight : 0.0;
  }
  
  /// API별 가중치 반환
  double _getApiWeight(final String apiProvider) {
    switch (apiProvider.toLowerCase()) {
      case 'plantid':
        return 1.0; // 가장 높은 가중치
      case 'plantnet':
        return 0.8;
      case 'google_vision':
        return 0.6;
      default:
        return 0.5;
    }
  }
  
  /// 최적의 식물 이름 선택
  String _selectBestName(final List<AnalysisResult> results) {
    // 신뢰도 가중 투표로 가장 많이 언급된 이름 선택
    final Map<String, double> nameScores = <String, double>{};
    
    for (final result in results) {
      final double weight = _getApiWeight(result.apiProvider) * result.confidence;
      nameScores[result.name] = (nameScores[result.name] ?? 0.0) + weight;
    }
    
    return nameScores.entries
        .reduce((final a, final b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// 최적의 학명 선택
  String _selectBestScientificName(final List<AnalysisResult> results) {
    // 비어있지 않은 학명 중 가장 신뢰도 높은 것 선택
    final validScientificNames = results
        .where((final r) => r.scientificName.isNotEmpty)
        .toList();
    
    if (validScientificNames.isEmpty) return '';
    
    validScientificNames.sort((final a, final b) => b.confidence.compareTo(a.confidence));
    return validScientificNames.first.scientificName;
  }
  
  /// 통합 설명 생성
  String _generateCombinedDescription(final List<AnalysisResult> results) {
    final descriptions = results
        .where((final r) => r.description.isNotEmpty)
        .map((final r) => r.description)
        .toSet()
        .toList();
    
    if (descriptions.isEmpty) return '여러 AI 모델을 통해 분석된 식물입니다.';
    if (descriptions.length == 1) return descriptions.first;
    
    return '${descriptions.first} (다중 AI 분석 결과 통합)';
  }
  
  /// 평균 희귀도 계산
  int _calculateAverageRarity(final List<AnalysisResult> results) {
    final double averageRarity = results.map((final r) => r.rarity).reduce((final a, final b) => a + b) / results.length;
    return averageRarity.round().clamp(1, 5);
  }
  
  // 향후 이미지 전처리 및 결과 후처리 메서드들을 여기에 추가할 예정
} 