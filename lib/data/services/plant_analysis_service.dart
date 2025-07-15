import 'dart:io';

import 'package:logger/logger.dart';

import '../models/analysis_result.dart';
import '../models/api_token.dart';
import 'plantid_service.dart';
import 'plantnet_service.dart';
import 'token_manager_service.dart';

class PlantAnalysisService {
  final Logger _logger;
  final TokenManagerService _tokenManager;
  final PlantNetService _plantNetService;
  final PlantIdService _plantIdService;

  /// 생성자 (의존성 주입)
  PlantAnalysisService({
    final Logger? logger,
    final TokenManagerService? tokenManager,
    final PlantNetService? plantNetService,
    final PlantIdService? plantIdService,
  }) : _logger = logger ?? Logger(),
       _tokenManager = tokenManager ?? TokenManagerService(),
       _plantNetService = plantNetService ?? PlantNetService(),
       _plantIdService = plantIdService ?? PlantIdService();

  /// 메인 분석 함수 - 토큰 유무에 따라 무료/유료 API 선택
  Future<AnalysisResult> analyzeImage(final File imageFile) async {
    try {
      // 1. 먼저 Plant.id 토큰이 있는지 확인
      final plantIdToken = await _tokenManager.getActiveToken('plantid');

      if (plantIdToken != null && plantIdToken.canUse) {
        try {
          // 유료 API 사용
          final result = await _plantIdService.identifyPlant(
            imageFile,
            plantIdToken.token,
          );

          // 토큰 사용량 증가
          await _tokenManager.incrementTokenUsage(plantIdToken);

          return result;
        } catch (e) {
          _logger.w('Plant.id API 오류, 무료 API로 전환: $e');
          // 유료 API 실패시 무료 API로 폴백
        }
      }

      // 2. 무료 API 사용 (PlantNet)
      return await _plantNetService.identifyPlant(imageFile);
    } catch (e) {
      // API 에러 메시지에 '식물이 아닙니다'가 포함되어 있으면 그대로 전달
      if (e.toString().contains('식물이 아닙니다')) {
        throw Exception('식물이 아닙니다');
      }
      throw Exception('이미지 분석 실패: $e');
    }
  }

  /// 결과 비교 - 무료 vs 유료 API 차이점 보여주기
  Future<Map<String, AnalysisResult?>> compareResults(
    final File imageFile,
  ) async {
    final results = <String, AnalysisResult?>{};

    // 무료 API 결과
    try {
      results['free'] = await _plantNetService.identifyPlant(imageFile);
    } catch (e) {
      _logger.w('무료 API 오류: $e');
      results['free'] = null;
    }

    // 유료 API 결과
    try {
      final plantIdToken = await _tokenManager.getActiveToken('plantid');
      if (plantIdToken != null && plantIdToken.canUse) {
        results['premium'] = await _plantIdService.identifyPlant(
          imageFile,
          plantIdToken.token,
        );
        await _tokenManager.incrementTokenUsage(plantIdToken);
      } else {
        results['premium'] = null;
      }
    } catch (e) {
      _logger.w('유료 API 오류: $e');
      results['premium'] = null;
    }

    return results;
  }

  /// 사용자의 토큰 상태 확인
  Future<Map<String, dynamic>> getTokenStatus() async {
    final plantIdToken = await _tokenManager.getActiveToken('plantid');

    return {
      'hasToken': plantIdToken != null,
      'canUse': plantIdToken?.canUse ?? false,
      'remainingUsage': plantIdToken?.remainingUsage,
      'usageCount': plantIdToken?.usageCount ?? 0,
      'provider': plantIdToken?.providerDisplayName ?? 'PlantNet (무료)',
    };
  }

  /// 토큰 추가
  Future<bool> addApiToken(
    final String provider,
    final String token, {
    final int? usageLimit,
  }) async {
    try {
      // 토큰 유효성 검증
      final isValid = await _validateToken(provider, token);
      if (!isValid) {
        throw Exception('유효하지 않은 토큰입니다');
      }

      // 토큰 저장
      final apiToken = ApiToken(
        provider: provider,
        token: token,
        addedAt: DateTime.now(),
        usageLimit: usageLimit,
      );

      await _tokenManager.saveToken(apiToken);
      return true;
    } catch (e) {
      _logger.e('토큰 추가 실패: $e');
      return false;
    }
  }

  /// 토큰 유효성 검증
  Future<bool> _validateToken(final String provider, final String token) async {
    try {
      switch (provider) {
        case 'plantid':
          return await _plantIdService.validateToken(token);
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// 토큰 제거
  Future<void> removeToken(final String provider) async {
    await _tokenManager.removeToken(provider);
  }

  /// 모든 토큰 목록
  Future<List<ApiToken>> getAllTokens() async =>
      await _tokenManager.getAllTokens();
}
