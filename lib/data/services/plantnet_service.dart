import 'dart:io';
import 'package:dio/dio.dart';
import '../models/analysis_result.dart';

class PlantNetService {
  final Dio _dio = Dio();

  // PlantNet API 설정
  static const String _baseUrl = 'https://my-api.plantnet.org/v1/identify';
  static const String _project = 'all'; // 'all', 'weurope', 'the-plant-list' 등

  /// PlantNet API로 식물 식별
  Future<AnalysisResult> identifyPlant(final File imageFile) async {
    try {
      // 이미지 파일을 multipart로 준비
      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'plant_image.jpg',
        ),
        'modifiers': ['crops', 'common_names'],
        'plant-details': ['common_names'],
      });

      // API 호출
      final response = await _dio.post<Map<String, dynamic>>(
        '$_baseUrl/$_project',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            // PlantNet은 실제로는 API 키 없이도 사용 가능
            // 'Api-Key': '', 
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data ?? <String, dynamic>{};
        final results = data['results'] as List? ?? <dynamic>[];

        if (results.isEmpty) {
          throw Exception('식물이 아닙니다');
        }

        // 가장 높은 신뢰도의 결과 반환
        final bestResult = results.first as Map<String, dynamic>;
        return AnalysisResult.fromPlantNet(bestResult);
      } else {
        throw Exception('API 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('연결 시간 초과');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('응답 시간 초과');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API 호출 한도 초과');
      } else {
        throw Exception('네트워크 오류: ${e.message}');
      }
    } catch (e) {
      throw Exception('PlantNet API 오류: $e');
    }
  }

  /// PlantNet API 상태 확인
  Future<bool> isServiceAvailable() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/$_project',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 지원되는 식물 프로젝트 목록 가져오기
  Future<List<String>> getSupportedProjects() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://my-api.plantnet.org/v1/projects',
      );

      if (response.statusCode == 200) {
        final projects = response.data as List;
        return projects.map((final project) => project.toString()).toList();
      }

      return ['all']; // 기본값
    } catch (e) {
      return ['all']; // 기본값
    }
  }

  /// PlantNet API 무료 사용량 확인 (추정)
  Map<String, dynamic> getUsageInfo() => {
    'provider': 'PlantNet',
    'type': '무료',
    'dailyLimit': '무제한', // 실제로는 제한이 있을 수 있음
    'features': ['식물 식별', '학명 제공', '일반명 제공', '신뢰도 점수'],
    'accuracy': '중간-높음',
    'responseTime': '2-5초',
  };
}
