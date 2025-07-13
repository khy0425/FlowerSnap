import 'package:flutter_test/flutter_test.dart';
import 'package:flora_snap/data/services/analysis_token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AnalysisTokenService Tests', () {
    late AnalysisTokenService tokenService;

    setUp(() async {
      // SharedPreferences Mock 설정
      SharedPreferences.setMockInitialValues({});
      tokenService = AnalysisTokenService();
    });

    group('Token Count Management', () {
      test('should start with default token count', () async {
        final count = await tokenService.getTokenCount();
        expect(count, equals(0)); // 기본값 확인
      });

      test('should add single token correctly', () async {
        const initialCount = 0;
        
        final countBefore = await tokenService.getTokenCount();
        expect(countBefore, equals(initialCount));
        
        await tokenService.addToken();
        
        final countAfter = await tokenService.getTokenCount();
        expect(countAfter, equals(initialCount + 1));
      });

      test('should add multiple tokens correctly', () async {
        const tokensToAdd = 5;
        
        await tokenService.addTokens(tokensToAdd);
        
        final finalCount = await tokenService.getTokenCount();
        expect(finalCount, equals(tokensToAdd));
      });

      test('should use token when available', () async {
        // 먼저 토큰 추가
        await tokenService.addToken();
        
        final canUse = await tokenService.useToken();
        expect(canUse, isTrue);
        
        final finalCount = await tokenService.getTokenCount();
        expect(finalCount, equals(0));
      });

      test('should not use token when none available', () async {
        final canUse = await tokenService.useToken();
        expect(canUse, isFalse);
        
        final count = await tokenService.getTokenCount();
        expect(count, equals(0));
      });
    });

    group('Multiple Operations', () {
      test('should handle multiple add and use operations', () async {
        // 3개 토큰 추가
        await tokenService.addTokens(3);
        expect(await tokenService.getTokenCount(), equals(3));
        
        // 1개 사용
        final used1 = await tokenService.useToken();
        expect(used1, isTrue);
        expect(await tokenService.getTokenCount(), equals(2));
        
        // 2개 더 추가
        await tokenService.addTokens(2);
        expect(await tokenService.getTokenCount(), equals(4));
        
        // 2개 사용
        await tokenService.useToken();
        await tokenService.useToken();
        expect(await tokenService.getTokenCount(), equals(2));
      });

      test('should maintain consistency across operations', () async {
        const iterations = 10;
        
        for (int i = 0; i < iterations; i++) {
          await tokenService.addToken();
          final count = await tokenService.getTokenCount();
          expect(count, equals(i + 1));
        }
        
        for (int i = iterations; i > 0; i--) {
          final canUse = await tokenService.useToken();
          expect(canUse, isTrue);
          
          final count = await tokenService.getTokenCount();
          expect(count, equals(i - 1));
        }
        
        // 마지막에는 0이어야 함
        final finalCount = await tokenService.getTokenCount();
        expect(finalCount, equals(0));
      });
    });
  });
} 