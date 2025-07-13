import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../models/analysis_result.dart';

class PlantIdService {
  final Dio _dio = Dio();

  // Plant.id API 설정
  static const String _baseUrl = 'https://api.plant.id/v3/identification';

  /// Plant.id API로 식물 식별
  Future<AnalysisResult> identifyPlant(
    final File imageFile,
    final String apiKey,
  ) async {
    try {
      // 이미지를 base64로 인코딩
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 요청 데이터 준비
      final requestData = {
        'images': [base64Image],
        'similar_images': true,
        'plant_details': [
          'common_names',
          'url',
          'name_authority',
          'wiki_description',
          'taxonomy',
          'synonyms',
        ],
      };

      // API 호출
      final response = await _dio.post<Map<String, dynamic>>(
        _baseUrl,
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null) {
          return AnalysisResult.fromPlantId(data);
        } else {
          throw Exception('API 응답 데이터가 없습니다');
        }
      } else {
        throw Exception('API 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('잘못된 요청입니다');
      } else if (e.response?.statusCode == 401) {
        throw Exception('유효하지 않은 API 키입니다');
      } else if (e.response?.statusCode == 402) {
        throw Exception('결제가 필요합니다');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API 호출 한도를 초과했습니다');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('연결 시간 초과');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('응답 시간 초과');
      } else {
        throw Exception('네트워크 오류: ${e.message}');
      }
    } catch (e) {
      throw Exception('Plant.id API 오류: $e');
    }
  }

  /// API 키 유효성 검증
  Future<bool> validateToken(final String apiKey) async {
    try {
      // 테스트용 작은 이미지 생성 (1x1 픽셀)
      const testImageBase64 =
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';

      final response = await _dio.post<Map<String, dynamic>>(
        _baseUrl,
        data: {
          'images': [testImageBase64],
          'plant_details': ['common_names'],
        },
        options: Options(
          headers: {'Content-Type': 'application/json', 'Api-Key': apiKey},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // 200, 201은 성공, 400은 이미지 문제지만 키는 유효함
      return [200, 201, 400].contains(response.statusCode);
    } on DioException catch (e) {
      // 401은 키가 유효하지 않음
      if (e.response?.statusCode == 401) {
        return false;
      }
      // 400은 이미지 문제지만 키는 유효함
      if (e.response?.statusCode == 400) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Plant.id API 사용량 정보 조회
  Future<Map<String, dynamic>> getUsageInfo(final String apiKey) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.plant.id/v3/usage',
        options: Options(headers: {'Api-Key': apiKey}),
      );

      if (response.statusCode == 200) {
        return response.data ?? <String, dynamic>{};
      }

      return <String, dynamic>{};
    } catch (e) {
      return <String, dynamic>{};
    }
  }

  /// Plant.id API 기능 정보
  Map<String, dynamic> getServiceInfo() => {
    'provider': 'Plant.id',
    'type': '프리미엄',
    'monthlyFree': 100, // 월 100회 무료
    'pricePerRequest': 0.10, // $0.10 per request
    'features': [
      '고정밀 식물 식별',
      '상세한 식물 정보',
      '위키피디아 설명',
      '학명 및 분류체계',
      '유사 이미지',
      '동의어 정보',
      '질병 진단 (추가 기능)',
    ],
    'accuracy': '매우 높음 (90%+)',
    'responseTime': '1-3초',
    'imageRequirements': {
      'maxSize': '10MB',
      'formats': ['jpg', 'jpeg', 'png'],
      'minResolution': '100x100',
      'maxResolution': '4096x4096',
    },
  };

  /// 이미지 사전 검증
  Future<bool> validateImage(final File imageFile) async {
    try {
      final stat = await imageFile.stat();
      final size = stat.size;

      // 파일 크기 체크 (10MB 제한)
      if (size > 10 * 1024 * 1024) {
        throw Exception('이미지 크기가 10MB를 초과합니다');
      }

      // 파일 확장자 체크
      final extension = imageFile.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        throw Exception('지원하지 않는 이미지 형식입니다 (jpg, jpeg, png만 지원)');
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Plant.id API 상태 확인
  Future<bool> isServiceAvailable() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.plant.id/v3/kb/plants',
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
}
