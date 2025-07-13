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
        
        final currentCount = await tokenService.getTokenCount();
        expect(currentCount, equals(initialCount));
        
        await tokenService.addToken();
        final newCount = await tokenService.getTokenCount();
        
        expect(newCount, equals(initialCount + 1));
      });

      test('should add multiple tokens correctly', () async {
        const initialCount = 0;
        const tokensToAdd = 5;
        
        final currentCount = await tokenService.getTokenCount();
        expect(currentCount, equals(initialCount));
        
        await tokenService.addTokens(tokensToAdd);
        final newCount = await tokenService.getTokenCount();
        
        expect(newCount, equals(initialCount + tokensToAdd));
      });

      test('should use tokens correctly when available', () async {
        const initialTokens = 10;
        
        await tokenService.addTokens(initialTokens);
        
        final canUse = await tokenService.useToken();
        expect(canUse, isTrue);
        
        final remainingCount = await tokenService.getTokenCount();
        expect(remainingCount, equals(initialTokens - 1));
      });

      test('should return false when trying to use with no tokens', () async {
        // 토큰이 0개인 상태에서 사용 시도
        final currentCount = await tokenService.getTokenCount();
        expect(currentCount, equals(0));
        
        final canUse = await tokenService.useToken();
        expect(canUse, isFalse);
        
        final afterCount = await tokenService.getTokenCount();
        expect(afterCount, equals(0)); // 토큰 수가 변하지 않아야 함
      });

      test('should handle multiple token additions', () async {
        await tokenService.addTokens(3);
        await tokenService.addTokens(2);
        await tokenService.addTokens(1);
        
        final totalCount = await tokenService.getTokenCount();
        expect(totalCount, equals(6));
      });

      test('should handle multiple token usages', () async {
        const initialTokens = 5;
        await tokenService.addTokens(initialTokens);
        
        // 3번 연속 사용
        for (int i = 0; i < 3; i++) {
          final canUse = await tokenService.useToken();
          expect(canUse, isTrue);
        }
        
        final remainingCount = await tokenService.getTokenCount();
        expect(remainingCount, equals(2));
      });

      test('should prevent using more tokens than available', () async {
        const initialTokens = 2;
        await tokenService.addTokens(initialTokens);
        
        // 2개 사용 (성공)
        expect(await tokenService.useToken(), isTrue);
        expect(await tokenService.useToken(), isTrue);
        
        // 3번째 사용 시도 (실패)
        expect(await tokenService.useToken(), isFalse);
        
        final finalCount = await tokenService.getTokenCount();
        expect(finalCount, equals(0));
      });

      test('should check token availability correctly', () async {
        // 토큰이 없을 때
        expect(await tokenService.hasToken(), isFalse);
        
        // 토큰 추가 후
        await tokenService.addToken();
        expect(await tokenService.hasToken(), isTrue);
        
        // 토큰 사용 후
        await tokenService.useToken();
        expect(await tokenService.hasToken(), isFalse);
      });
    });

    group('Token Reset and Management', () {
      test('should reset tokens to zero', () async {
        await tokenService.addTokens(10);
        expect(await tokenService.getTokenCount(), equals(10));
        
        await tokenService.resetTokens();
        expect(await tokenService.getTokenCount(), equals(0));
      });

      test('should persist token count across service instances', () async {
        const testTokens = 7;
        
        // 첫 번째 인스턴스에서 토큰 추가
        await tokenService.addTokens(testTokens);
        expect(await tokenService.getTokenCount(), equals(testTokens));
        
        // 새 인스턴스 생성
        final newTokenService = AnalysisTokenService();
        
        // 새 인스턴스에서도 같은 토큰 수가 확인되어야 함
        expect(await newTokenService.getTokenCount(), equals(testTokens));
      });

      test('should handle setting specific token count', () async {
        await tokenService.addTokens(5);
        expect(await tokenService.getTokenCount(), equals(5));
        
        await tokenService.setTokenCount(15);
        expect(await tokenService.getTokenCount(), equals(15));
        
        await tokenService.setTokenCount(0);
        expect(await tokenService.getTokenCount(), equals(0));
      });
    });

    group('Reward Ad Features', () {
      test('should start with zero reward ad count for today', () async {
        final count = await tokenService.getTodayRewardAdCount();
        expect(count, equals(0));
      });

      test('should increment reward ad count correctly', () async {
        expect(await tokenService.getTodayRewardAdCount(), equals(0));
        
        await tokenService.incrementTodayRewardAdCount();
        expect(await tokenService.getTodayRewardAdCount(), equals(1));
        
        await tokenService.incrementTodayRewardAdCount();
        expect(await tokenService.getTodayRewardAdCount(), equals(2));
      });

      test('should check if can watch more reward ads today', () async {
        // 처음에는 광고를 볼 수 있어야 함
        expect(await tokenService.canWatchRewardAdToday(), isTrue);
        
        // 최대 한도(5회)까지 시청
        for (int i = 0; i < 5; i++) {
          await tokenService.incrementTodayRewardAdCount();
        }
        
        // 한도에 도달하면 더 이상 볼 수 없어야 함
        expect(await tokenService.canWatchRewardAdToday(), isFalse);
      });

      test('should handle reward ad and token integration', () async {
        const initialTokens = 0;
        expect(await tokenService.getTokenCount(), equals(initialTokens));
        
        // 리워드 광고 시청 및 토큰 추가 시뮬레이션
        await tokenService.incrementTodayRewardAdCount();
        await tokenService.addToken();
        
        expect(await tokenService.getTokenCount(), equals(1));
        expect(await tokenService.getTodayRewardAdCount(), equals(1));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle zero token additions', () async {
        const initialTokens = 3;
        await tokenService.addTokens(initialTokens);
        
        await tokenService.addTokens(0);
        expect(await tokenService.getTokenCount(), equals(initialTokens));
      });

      test('should handle large token numbers', () async {
        const largeNumber = 999999;
        
        await tokenService.addTokens(largeNumber);
        expect(await tokenService.getTokenCount(), equals(largeNumber));
        
        // 큰 수에서도 사용이 정상 작동하는지 확인
        final canUse = await tokenService.useToken();
        expect(canUse, isTrue);
        expect(await tokenService.getTokenCount(), equals(largeNumber - 1));
      });

      test('should maintain token count consistency', () async {
        const operations = 100;
        
        // 복잡한 토큰 조작 시나리오
        for (int i = 0; i < operations; i++) {
          await tokenService.addToken();
        }
        
        expect(await tokenService.getTokenCount(), equals(operations));
        
        // 절반 사용
        for (int i = 0; i < operations ~/ 2; i++) {
          final used = await tokenService.useToken();
          expect(used, isTrue);
        }
        
        expect(await tokenService.getTokenCount(), equals(operations ~/ 2));
      });

      test('should validate token count is never negative', () async {
        await tokenService.resetTokens();
        
        // 음수가 될 수 있는 상황에서도 0 이상 유지
        final canUse = await tokenService.useToken();
        expect(canUse, isFalse);
        
        final count = await tokenService.getTokenCount();
        expect(count, greaterThanOrEqualTo(0));
      });
    });

    group('Real-world Scenarios', () {
      test('should handle typical user workflow', () async {
        // 1. 새 사용자는 토큰이 없음
        expect(await tokenService.getTokenCount(), equals(0));
        expect(await tokenService.hasToken(), isFalse);
        
        // 2. 리워드 광고를 보고 토큰 획득
        await tokenService.incrementTodayRewardAdCount();
        await tokenService.addToken();
        
        expect(await tokenService.getTokenCount(), equals(1));
        expect(await tokenService.hasToken(), isTrue);
        
        // 3. 정밀 분석 사용
        final canUse = await tokenService.useToken();
        expect(canUse, isTrue);
        expect(await tokenService.getTokenCount(), equals(0));
        
        // 4. 다시 토큰이 없음
        expect(await tokenService.hasToken(), isFalse);
      });

      test('should handle premium user workflow', () async {
        // 프리미엄 사용자는 한 번에 많은 토큰 구매
        const purchasedTokens = 50;
        await tokenService.addTokens(purchasedTokens);
        
        expect(await tokenService.getTokenCount(), equals(purchasedTokens));
        
        // 여러 번 사용해도 충분함
        for (int i = 0; i < 10; i++) {
          expect(await tokenService.useToken(), isTrue);
        }
        
        expect(await tokenService.getTokenCount(), equals(purchasedTokens - 10));
      });

      test('should handle mixed token acquisition', () async {
        // 리워드 광고로 몇 개 획득
        await tokenService.addToken();
        await tokenService.addToken();
        expect(await tokenService.getTokenCount(), equals(2));
        
        // 추가로 구매
        await tokenService.addTokens(8);
        expect(await tokenService.getTokenCount(), equals(10));
        
        // 몇 개 사용
        await tokenService.useToken();
        await tokenService.useToken();
        expect(await tokenService.getTokenCount(), equals(8));
      });
    });
  });
} 