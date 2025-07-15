import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/senior_theme.dart';
import '../../data/services/analysis_token_service.dart';
import '../../generated/l10n/app_localizations.dart';
import '../services/image_analysis_helper.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/developer_menu.dart';
import '../widgets/home_screen_widgets.dart';
import '../widgets/premium_widgets.dart';
import 'settings_screen.dart';

// 개발 모드 플래그 (릴리즈 시 false로 변경)
const bool kDebugMode = true;

class FloraSnapHomeScreen extends ConsumerStatefulWidget {
  const FloraSnapHomeScreen({super.key});

  @override
  ConsumerState<FloraSnapHomeScreen> createState() => _FloraSnapHomeScreenState();
}

class _FloraSnapHomeScreenState extends ConsumerState<FloraSnapHomeScreen>
    with TickerProviderStateMixin {
  final AnalysisTokenService _tokenService = AnalysisTokenService();
  int _tokenCount = 0;
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadTokenCount();
    _initializeAnimations();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: SeniorConstants.animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideController = AnimationController(
      duration: SeniorConstants.animationDurationSlow,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  /// 분석 토큰 개수 로드
  Future<void> _loadTokenCount() async {
    final count = await _tokenService.getTokenCount();
    if (mounted) {
      setState(() {
        _tokenCount = count;
      });
    }
  }

  /// 로딩 상태 설정
  void _setLoading(final bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }
  
  @override
  // ignore: prefer_expression_function_bodies
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: SeniorTheme.backgroundColor,
      body: Container(
        decoration: SeniorTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // 앱바
              HomeScreenWidgets.buildAppBar(
                context,
                tokenCount: _tokenCount,
                onDeveloperMenu: () => DeveloperMenu.showDeveloperMenu(
                  context,
                  tokenService: _tokenService,
                  onTokenCountUpdate: _loadTokenCount,
                ),
                                  onSettings: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (final context) => const SettingsScreen(),
                  ),
                ),
                showDeveloperMenu: kDebugMode,
              ),
              
              // 메인 콘텐츠
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 메인 카메라 섹션
                            HomeScreenWidgets.buildMainCameraSection(
                              context,
                              isLoading: _isLoading,
                              onTakePhoto: () => ImageAnalysisHelper.instance.takePictureAndAnalyze(
                                context,
                                setLoading: _setLoading,
                              ),
                              onSelectFromGallery: () => ImageAnalysisHelper.instance.pickFromGalleryAndAnalyze(
                                context,
                                setLoading: _setLoading,
                              ),
                            ),
                            
                            const SizedBox(height: SeniorConstants.spacingXLarge),
                            
                            // 오늘 배운 꽃 섹션
                            HomeScreenWidgets.buildTodayFlowerSection(
                              context,
                              ref.watch(analysisHistoryProvider),
                            ),
                            
                            const SizedBox(height: SeniorConstants.spacingLarge),
                            
                            // 꽃 노트 섹션
                            _buildFlowerNoteSection(context),
                            
                            const SizedBox(height: SeniorConstants.spacingXLarge),
                            
                            // 하단 환영 메시지
                            HomeScreenWidgets.buildWelcomeMessage(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // 하단 배너 광고
      bottomNavigationBar: _buildBottomSection(context),
    );
  }

  /// 꽃 노트 섹션
  Widget _buildFlowerNoteSection(final BuildContext context) {
    final analysisHistory = ref.watch(analysisHistoryProvider);
    
    return Container(
      decoration: SeniorTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(SeniorConstants.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSectionHeader(
                    context,
                    icon: Icons.menu_book,
                    title: AppLocalizations.of(context).myFlowerNote,
                    color: SeniorTheme.primaryColor,
                  ),
                ),
                if (analysisHistory.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _showFlowerNoteScreen(context),
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    label: Text(AppLocalizations.of(context).seeMore),
                    style: TextButton.styleFrom(
                      foregroundColor: SeniorTheme.primaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SeniorConstants.spacing),
            
            analysisHistory.isEmpty
                ? Text(
                    AppLocalizations.of(context).noFlowerSaved,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SeniorTheme.textSecondaryColor,
                    ),
                  )
                : _buildFlowerNotePreview(context, analysisHistory),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 위젯
  // ignore: prefer_expression_function_bodies
  Widget _buildSectionHeader(
    final BuildContext context, {
    required final IconData icon,
    required final String title,
    required final Color color,
  // ignore: prefer_expression_function_bodies
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(SeniorConstants.spacingSmall),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusSmall),
          ),
          child: Icon(
            icon,
            color: color,
            size: SeniorConstants.iconSizeLarge,
          ),
        ),
        const SizedBox(width: SeniorConstants.spacing),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// 꽃 노트 미리보기
  // ignore: prefer_expression_function_bodies
  Widget _buildFlowerNotePreview(final BuildContext context, final List<dynamic> history) {
    return Container(
      padding: const EdgeInsets.all(SeniorConstants.spacing),
      decoration: BoxDecoration(
        color: SeniorTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SeniorConstants.borderRadiusLarge),
        border: Border.all(
          color: SeniorTheme.accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).totalFlowerCount(history.length),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SeniorConstants.spacingSmall),
          Text(
            "최근 분석한 꽃들을 확인해보세요",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SeniorTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 섹션 (프리미엄 안내 + 광고)
  // ignore: prefer_expression_function_bodies
  Widget _buildBottomSection(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 프리미엄 기능 안내 섹션
        PremiumWidgets.buildPremiumPromoSection(
          context,
          onRewardAd: () => _showRewardAdForToken(context),
          onPurchase: () => PremiumWidgets.showSimplePurchaseDialog(context),
        ),
        
        // 개발 모드에서만 테스트 배너 표시
        if (kDebugMode)
          Container(
            margin: const EdgeInsets.all(8),
            child: const Card(
              color: Colors.lightBlue,
              child: SizedBox(
                width: 320,
                height: 50,
                child: Center(
                  child: Text(
                    '테스트 광고 배너 (실제 앱에서는 Google AdMob)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  /// 꽃 노트 전체 화면으로 이동
  void _showFlowerNoteScreen(final BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).flowerNoteComingSoon),
        backgroundColor: SeniorTheme.primaryColor,
      ),
    );
  }

  /// 리워드 광고로 토큰 획득 (테스트 모드)
  Future<void> _showRewardAdForToken(final BuildContext context) async {
    if (kDebugMode) {
      PremiumWidgets.showTestTokenDialog(
        context,
        tokenService: _tokenService,
        onTokenCountUpdate: _loadTokenCount,
      );
    } else {
      // 실제 광고 로직 구현
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('광고 기능 준비 중입니다')),
      );
    }
  }
} 
