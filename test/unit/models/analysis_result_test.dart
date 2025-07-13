import 'package:flutter_test/flutter_test.dart';

import 'package:flora_snap/data/models/analysis_result.dart';
import 'package:flora_snap/data/models/bounding_box.dart';

void main() {
  group('AnalysisResult Model Tests', () {
    late AnalysisResult testResult;
    
    setUp(() {
      testResult = AnalysisResult(
        id: 'test-id-123',
        name: '장미',
        scientificName: 'Rosa rubiginosa',
        confidence: 0.95,
        description: '아름다운 빨간 장미입니다.',
        alternativeNames: const ['Red Rose', 'Garden Rose'],
        imageUrl: 'https://example.com/rose.jpg',
        analyzedAt: DateTime(2024, 1, 15, 10, 30),
        apiProvider: 'plantnet',
        isPremiumResult: false,
        category: 'flower',
        rarity: 3,
        additionalInfo: const {
          'color': 'red',
          'season': 'spring',
        },
        boundingBoxes: const <BoundingBox>[
          BoundingBox(left: 0.1, top: 0.1, width: 0.8, height: 0.8),
        ],
      );
    });

    group('Constructor and Basic Properties', () {
      test('should create AnalysisResult with all required fields', () {
        expect(testResult.id, equals('test-id-123'));
        expect(testResult.name, equals('장미'));
        expect(testResult.scientificName, equals('Rosa rubiginosa'));
        expect(testResult.confidence, equals(0.95));
        expect(testResult.description, equals('아름다운 빨간 장미입니다.'));
        expect(testResult.alternativeNames, equals(['Red Rose', 'Garden Rose']));
        expect(testResult.imageUrl, equals('https://example.com/rose.jpg'));
        expect(testResult.analyzedAt, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(testResult.apiProvider, equals('plantnet'));
        expect(testResult.isPremiumResult, isFalse);
        expect(testResult.category, equals('flower'));
        expect(testResult.rarity, equals(3));
      });

      test('should handle empty alternative names', () {
        final result = AnalysisResult(
          id: 'test-2',
          name: '테스트 꽃',
          scientificName: 'Test flower',
          confidence: 0.8,
          description: '테스트용 꽃입니다.',
          alternativeNames: const <String>[],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'test',
          rarity: 1,
          additionalInfo: const <String, dynamic>{},
          boundingBoxes: const <BoundingBox>[],
        );
        
        expect(result.alternativeNames, isEmpty);
        expect(result.additionalInfo, isEmpty);
        expect(result.boundingBoxes, isEmpty);
      });
    });

    group('JSON Serialization', () {
      test('should convert to JSON correctly', () {
        final json = testResult.toJson();
        
        expect(json['id'], equals('test-id-123'));
        expect(json['name'], equals('장미'));
        expect(json['scientificName'], equals('Rosa rubiginosa'));
        expect(json['confidence'], equals(0.95));
        expect(json['description'], equals('아름다운 빨간 장미입니다.'));
        expect(json['alternativeNames'], equals(['Red Rose', 'Garden Rose']));
        expect(json['imageUrl'], equals('https://example.com/rose.jpg'));
        expect(json['apiProvider'], equals('plantnet'));
        expect(json['isPremiumResult'], isFalse);
        expect(json['category'], equals('flower'));
        expect(json['rarity'], equals(3));
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': 'json-test-id',
          'name': 'JSON 장미',
          'scientificName': 'Rosa JSON',
          'confidence': 0.87,
          'description': 'JSON에서 생성된 장미',
          'alternativeNames': <String>['JSON Rose'],
          'imageUrl': 'https://json.example.com/rose.jpg',
          'analyzedAt': '2024-01-15T10:30:00.000',
          'apiProvider': 'json-api',
          'isPremiumResult': true,
          'category': 'json-flower',
          'rarity': 2,
          'additionalInfo': <String, dynamic>{'source': 'json'},
          'boundingBoxes': <Map<String, dynamic>>[
            {'left': 0.2, 'top': 0.2, 'width': 0.6, 'height': 0.6}
          ],
        };
        
        final result = AnalysisResult.fromJson(json);
        
        expect(result.id, equals('json-test-id'));
        expect(result.name, equals('JSON 장미'));
        expect(result.scientificName, equals('Rosa JSON'));
        expect(result.confidence, equals(0.87));
        expect(result.description, equals('JSON에서 생성된 장미'));
        expect(result.alternativeNames, equals(['JSON Rose']));
        expect(result.imageUrl, equals('https://json.example.com/rose.jpg'));
        expect(result.apiProvider, equals('json-api'));
        expect(result.isPremiumResult, isTrue);
        expect(result.category, equals('json-flower'));
        expect(result.rarity, equals(2));
      });
    });

    group('Validation', () {
      test('should validate confidence range', () {
        expect(testResult.confidence, inInclusiveRange(0.0, 1.0));
      });

      test('should validate rarity range', () {
        expect(testResult.rarity, inInclusiveRange(1, 5));
      });

      test('should handle edge case confidence values', () {
        final minConfidenceResult = AnalysisResult(
          id: 'min-conf',
          name: '최소 신뢰도',
          scientificName: 'Min confidence',
          confidence: 0.0,
          description: '최소 신뢰도 테스트',
          alternativeNames: const <String>[],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'test',
          rarity: 1,
          additionalInfo: const <String, dynamic>{},
          boundingBoxes: const <BoundingBox>[],
        );

        final maxConfidenceResult = AnalysisResult(
          id: 'max-conf',
          name: '최대 신뢰도',
          scientificName: 'Max confidence',
          confidence: 1.0,
          description: '최대 신뢰도 테스트',
          alternativeNames: const <String>[],
          imageUrl: '',
          analyzedAt: DateTime.now(),
          apiProvider: 'test',
          isPremiumResult: false,
          category: 'test',
          rarity: 5,
          additionalInfo: const <String, dynamic>{},
          boundingBoxes: const <BoundingBox>[],
        );

        expect(minConfidenceResult.confidence, equals(0.0));
        expect(maxConfidenceResult.confidence, equals(1.0));
        expect(minConfidenceResult.rarity, equals(1));
        expect(maxConfidenceResult.rarity, equals(5));
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all properties match', () {
        final anotherResult = AnalysisResult(
          id: 'test-id-123',
          name: '장미',
          scientificName: 'Rosa rubiginosa',
          confidence: 0.95,
          description: '아름다운 빨간 장미입니다.',
          alternativeNames: const ['Red Rose', 'Garden Rose'],
          imageUrl: 'https://example.com/rose.jpg',
          analyzedAt: DateTime(2024, 1, 15, 10, 30),
          apiProvider: 'plantnet',
          isPremiumResult: false,
          category: 'flower',
          rarity: 3,
          additionalInfo: const {
            'color': 'red',
            'season': 'spring',
          },
          boundingBoxes: const <BoundingBox>[
            BoundingBox(left: 0.1, top: 0.1, width: 0.8, height: 0.8),
          ],
        );

        expect(testResult, equals(anotherResult));
        expect(testResult.hashCode, equals(anotherResult.hashCode));
      });

      test('should not be equal when properties differ', () {
        final differentResult = AnalysisResult(
          id: 'different-id',
          name: '다른 꽃',
          scientificName: 'Different flower',
          confidence: 0.8,
          description: '다른 꽃입니다.',
          alternativeNames: const <String>['Different'],
          imageUrl: 'https://different.com/flower.jpg',
          analyzedAt: DateTime(2024, 1, 16),
          apiProvider: 'different',
          isPremiumResult: true,
          category: 'different',
          rarity: 2,
          additionalInfo: const <String, dynamic>{'type': 'different'},
          boundingBoxes: const <BoundingBox>[],
        );

        expect(testResult, isNot(equals(differentResult)));
        expect(testResult.hashCode, isNot(equals(differentResult.hashCode)));
      });
    });

    group('String Representation', () {
      test('should provide meaningful toString output', () {
        final string = testResult.toString();
        
        expect(string, contains('AnalysisResult'));
        expect(string, contains('test-id-123'));
        expect(string, contains('장미'));
        expect(string, contains('0.95'));
      });
    });
  });
} 