import 'package:flutter_test/flutter_test.dart';

import 'package:flora_snap/data/models/analysis_result.dart';
import 'package:flora_snap/data/models/detection_result.dart';
import 'package:flora_snap/data/models/bounding_box.dart';

void main() {
  group('AnalysisResult Model Tests', () {
    late AnalysisResult testResult;
    late DetectionResult testDetection;
    late BoundingBox testBoundingBox;
    
    setUp(() {
      testBoundingBox = const BoundingBox(
        left: 0.1,
        top: 0.2,
        width: 0.3,
        height: 0.4,
      );
      
      testDetection = DetectionResult(
        boundingBox: testBoundingBox,
        confidence: 0.85,
        label: 'Rose',
      );
      
      testResult = AnalysisResult(
        id: 'test_001',
        name: '장미',
        scientificName: 'Rosa rubiginosa',
        confidence: 0.95,
        description: '아름다운 빨간 장미입니다.',
        alternativeNames: const ['Red Rose', '빨간장미'],
        imageUrl: '/path/to/image.jpg',
        analyzedAt: DateTime.now(),
        apiProvider: 'plantid',
        isPremiumResult: true,
        category: 'flower',
        rarity: 3,
        additionalInfo: const {'color': 'red', 'season': 'spring'},
        detectionResults: [testDetection],
      );
    });

    group('Constructor Tests', () {
      test('should create AnalysisResult with all fields', () {
        expect(testResult.id, equals('test_001'));
        expect(testResult.name, equals('장미'));
        expect(testResult.scientificName, equals('Rosa rubiginosa'));
        expect(testResult.confidence, equals(0.95));
        expect(testResult.description, equals('아름다운 빨간 장미입니다.'));
        expect(testResult.alternativeNames, equals(['Red Rose', '빨간장미']));
        expect(testResult.imageUrl, equals('/path/to/image.jpg'));
        expect(testResult.apiProvider, equals('plantid'));
        expect(testResult.isPremiumResult, isTrue);
        expect(testResult.category, equals('flower'));
        expect(testResult.rarity, equals(3));
        expect(testResult.additionalInfo, equals({'color': 'red', 'season': 'spring'}));
        expect(testResult.detectionResults.length, equals(1));
        expect(testResult.detectionResults.first.label, equals('Rose'));
      });

      test('should create AnalysisResult with required fields only', () {
        final result = AnalysisResult(
          id: 'test_002',
          name: '해바라기',
          scientificName: 'Helianthus annuus',
          confidence: 0.92,
          description: '노란색 꽃잎을 가진 해바라기입니다.',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'plantid',
          isPremiumResult: false,
          category: 'flower',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        );

        expect(result.id, equals('test_002'));
        expect(result.name, equals('해바라기'));
        expect(result.alternativeNames, isEmpty);
        expect(result.detectionResults, isEmpty);
      });

      test('should create AnalysisResult with empty detection results', () {
        final result = AnalysisResult(
          id: 'test_003',
          name: '튤립',
          scientificName: 'Tulipa gesneriana',
          confidence: 0.78,
          description: '봄에 피는 아름다운 튤립입니다.',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'google_vision',
          isPremiumResult: false,
          category: 'flower',
          rarity: 2,
          additionalInfo: const {},
          detectionResults: const [],
        );

        expect(result.detectionResults, isEmpty);
        expect(result.boundingBoxes, isEmpty); // deprecated getter should work
      });
    });

    group('JSON Serialization Tests', () {
      test('should convert to JSON correctly', () {
        final json = testResult.toJson();

        expect(json['id'], equals('test_001'));
        expect(json['name'], equals('장미'));
        expect(json['scientific_name'], equals('Rosa rubiginosa'));
        expect(json['confidence'], equals(0.95));
        expect(json['description'], equals('아름다운 빨간 장미입니다.'));
        expect(json['alternative_names'], equals(['Red Rose', '빨간장미']));
        expect(json['image_url'], equals('/path/to/image.jpg'));
        expect(json['api_provider'], equals('plantid'));
        expect(json['is_premium_result'], isTrue);
        expect(json['category'], equals('flower'));
        expect(json['rarity'], equals(3));
        expect(json['additional_info'], equals({'color': 'red', 'season': 'spring'}));
        expect(json['detection_results'], isA<List>());
        expect(json['detection_results'].length, equals(1));
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'test_json',
          'name': '개나리',
          'scientific_name': 'Forsythia koreana',
          'confidence': 0.88,
          'description': '노란색 봄꽃 개나리입니다.',
          'alternative_names': const <String>[],
          'image_url': '/test/image.jpg',
          'analyzed_at': DateTime.now().toIso8601String(),
          'api_provider': 'test',
          'is_premium_result': false,
          'category': 'flower',
          'rarity': 2,
          'additional_info': const <String, dynamic>{},
          'detection_results': const <Map<String, dynamic>>[],
        };

        final result = AnalysisResult.fromJson(json);
        expect(result.id, equals('test_json'));
        expect(result.name, equals('개나리'));
        expect(result.scientificName, equals('Forsythia koreana'));
        expect(result.confidence, equals(0.88));
        expect(result.isPremiumResult, isFalse);
        expect(result.category, equals('flower'));
        expect(result.rarity, equals(2));
      });
    });

    group('Validation Tests', () {
      test('should validate positive confidence', () {
        expect(() => AnalysisResult(
          id: 'test_invalid',
          name: 'Invalid',
          scientificName: 'Invalid',
          confidence: -0.1,
          description: 'Invalid confidence',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'unknown',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        ), throwsA(isA<AssertionError>()));
      });

      test('should validate confidence not exceeding 1.0', () {
        expect(() => AnalysisResult(
          id: 'test_invalid',
          name: 'Invalid',
          scientificName: 'Invalid',
          confidence: 1.5,
          description: 'Invalid confidence',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'unknown',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        ), throwsA(isA<AssertionError>()));
      });

      test('should validate empty ID', () {
        expect(() => AnalysisResult(
          id: '',
          name: 'Valid',
          scientificName: 'Valid',
          confidence: 0.5,
          description: 'Valid description',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'unknown',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        ), throwsA(isA<AssertionError>()));
      });

      test('should validate empty name', () {
        expect(() => AnalysisResult(
          id: 'test_valid',
          name: '',
          scientificName: 'Valid',
          confidence: 0.5,
          description: 'Valid description',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'unknown',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        ), throwsA(isA<AssertionError>()));
      });
    });

    group('Helper Methods Tests', () {
      test('should check if result is recent', () {
        final recentResult = AnalysisResult(
          id: 'recent',
          name: 'Recent Flower',
          scientificName: 'Recent species',
          confidence: 0.8,
          description: 'Recently analyzed',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'flower',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        );

        // Check if analyzed within last hour (manually)
        final hourAgo = DateTime.now().subtract(const Duration(hours: 1));
        expect(recentResult.analyzedAt.isAfter(hourAgo), isTrue);
      });

      test('should check detection results', () {
        expect(testResult.detectionResults.isNotEmpty, isTrue);
        expect(testResult.boundingBoxes.isNotEmpty, isTrue); // deprecated getter
      });

      test('should have correct basic properties', () {
        expect(testResult.name, contains('장미'));
        expect(testResult.scientificName, contains('Rosa rubiginosa'));
        expect(testResult.confidence, equals(0.95));
      });

      test('should create copy with changes', () {
        final copy = testResult.copyWith(
          confidence: 0.99,
          name: '새로운 이름',
        );

        expect(copy.confidence, equals(0.99));
        expect(copy.name, equals('새로운 이름'));
        expect(copy.id, equals(testResult.id)); // unchanged
        expect(copy.scientificName, equals(testResult.scientificName)); // unchanged
      });
    });

    group('Edge Cases', () {
      test('should handle minimum confidence', () {
        final result = AnalysisResult(
          id: 'min_confidence',
          name: 'Uncertain',
          scientificName: 'Uncertain species',
          confidence: 0.0,
          description: 'Minimum confidence',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'unknown',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        );

        expect(result.confidence, equals(0.0));
        expect(result.confidence >= 0.8, isFalse);
      });

      test('should handle maximum confidence', () {
        final result = AnalysisResult(
          id: 'max_confidence',
          name: 'Certain',
          scientificName: 'Certain species',
          confidence: 1.0,
          description: 'Maximum confidence',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'flower',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        );

        expect(result.confidence, equals(1.0));
        expect(result.confidence >= 0.8, isTrue);
      });

      test('should handle empty lists and maps', () {
        final result = AnalysisResult(
          id: 'empty_test',
          name: 'Empty Test',
          scientificName: 'Empty',
          confidence: 0.5,
          description: 'Empty collections test',
          alternativeNames: const [],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'unknown',
          rarity: 1,
          additionalInfo: const {},
          detectionResults: const [],
        );

        expect(result.alternativeNames, isEmpty);
        expect(result.additionalInfo, isEmpty);
        expect(result.detectionResults, isEmpty);
        expect(result.boundingBoxes, isEmpty);
      });
    });
  });
} 