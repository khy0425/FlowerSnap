import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/api_token.dart';
import '../../data/services/plant_analysis_service.dart';

// 토큰 상태 Provider
final tokenStatusProvider = FutureProvider<Map<String, dynamic>>((
  final ref,
) async {
  final service = PlantAnalysisService();
  return await service.getTokenStatus();
});

// 토큰 목록 Provider
final tokenListProvider = FutureProvider<List<ApiToken>>((final ref) async {
  final service = PlantAnalysisService();
  return await service.getAllTokens();
});

class TokenManagementWidget extends ConsumerStatefulWidget {
  const TokenManagementWidget({super.key});

  @override
  ConsumerState<TokenManagementWidget> createState() =>
      _TokenManagementWidgetState();
}

class _TokenManagementWidgetState extends ConsumerState<TokenManagementWidget> {
  final _tokenController = TextEditingController();
  final _usageLimitController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final tokenStatus = ref.watch(tokenStatusProvider);
    final tokenList = ref.watch(tokenListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 현재 토큰 상태
        tokenStatus.when(
          data: (final status) => _buildTokenStatus(context, status),
          loading: () => const CircularProgressIndicator(),
          error: (final error, final stack) => Text('오류: $error'),
        ),

        const SizedBox(height: 16),

        // 토큰 추가 버튼
        if (!_isLoading) ...[
          ElevatedButton.icon(
            onPressed: () => _showAddTokenDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Plant.id 토큰 추가'),
          ),
        ] else ...[
          const CircularProgressIndicator(),
        ],

        const SizedBox(height: 16),

        // 토큰 목록
        tokenList.when(
          data: (final tokens) => _buildTokenList(context, tokens),
          loading: () => const CircularProgressIndicator(),
          error: (final error, final stack) => Text('토큰 목록 로드 오류: $error'),
        ),
      ],
    );
  }

  Widget _buildTokenStatus(
    final BuildContext context,
    final Map<String, dynamic> status,
  ) {
    final hasToken = (status['hasToken'] as bool?) ?? false;
    final canUse = (status['canUse'] as bool?) ?? false;
    final remainingUsage = status['remainingUsage'] as int?;
    final usageCount = (status['usageCount'] as int?) ?? 0;
    final provider = (status['provider'] as String?) ?? 'PlantNet (무료)';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: hasToken && canUse
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasToken && canUse ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasToken && canUse ? Icons.check_circle : Icons.warning,
            color: hasToken && canUse ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 사용 중: $provider',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (hasToken) ...[
                  Text(
                    '사용량: $usageCount회',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (remainingUsage != null)
                    Text(
                      '남은 사용량: $remainingUsage회',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenList(
    final BuildContext context,
    final List<ApiToken> tokens,
  ) {
    if (tokens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.vpn_key_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              '등록된 토큰이 없습니다',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Plant.id 토큰을 추가하여 프리미엄 기능을 사용해보세요',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('등록된 토큰', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...tokens.map((final token) => _buildTokenItem(context, token)),
      ],
    );
  }

  Widget _buildTokenItem(final BuildContext context, final ApiToken token) =>
      Card(
        child: ListTile(
          leading: Icon(
            token.canUse ? Icons.vpn_key : Icons.vpn_key_off,
            color: token.canUse ? Colors.green : Colors.grey,
          ),
          title: Text('${token.provider.toUpperCase()} 토큰'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('토큰: ${token.maskedToken}'),
              Text('사용량: ${token.usageCount}회'),
              if (token.remainingUsage != null)
                Text('남은 사용량: ${token.remainingUsage}회'),
              Text('상태: ${token.canUse ? "활성" : "비활성"}'),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (final value) => _handleTokenAction(value, token),
            itemBuilder: (final context) => [
              const PopupMenuItem(value: 'toggle', child: Text('활성/비활성 전환')),
              const PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ),
      );

  void _showAddTokenDialog(final BuildContext context) {
    _tokenController.clear();
    _usageLimitController.clear();

    showDialog<void>(
      context: context,
      builder: (final context) => AlertDialog(
        title: const Text('Plant.id 토큰 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(
                  labelText: 'API 토큰',
                  hintText: 'Plant.id API 키를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usageLimitController,
                decoration: const InputDecoration(
                  labelText: '사용 한도 (선택사항)',
                  hintText: '예: 1000 (비워두면 무제한)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              Text(
                'Plant.id 웹사이트에서 API 토큰을 구매하고 여기에 입력하세요.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => _addToken(context),
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _addToken(final BuildContext context) async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      _showErrorSnackBar('토큰을 입력해주세요');
      return;
    }

    // BuildContext를 미리 저장
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isLoading = true);

    try {
      final usageLimit = _usageLimitController.text.trim().isNotEmpty
          ? int.parse(_usageLimitController.text.trim())
          : null;

      final service = PlantAnalysisService();
      final success = await service.addApiToken(
        'plantid',
        token,
        usageLimit: usageLimit,
      );

      if (mounted) {
        if (success) {
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('토큰이 성공적으로 추가되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(tokenStatusProvider);
          ref.invalidate(tokenListProvider);
        } else {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('토큰 추가에 실패했습니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleTokenAction(
    final String action,
    final ApiToken token,
  ) async {
    final service = PlantAnalysisService();

    switch (action) {
      case 'toggle':
        // 토큰 활성/비활성 전환 기능
        break;
      case 'delete':
        final confirmed = await _showConfirmDialog('토큰 삭제', '이 토큰을 삭제하시겠습니까?');
        if (confirmed) {
          try {
            await service.removeToken(token.provider);
            _showSuccessSnackBar('토큰이 삭제되었습니다');
            ref.invalidate(tokenStatusProvider);
            ref.invalidate(tokenListProvider);
          } catch (e) {
            _showErrorSnackBar('토큰 삭제 실패: $e');
          }
        }
        break;
    }
  }

  Future<bool> _showConfirmDialog(
    final String title,
    final String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (final context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackBar(final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
