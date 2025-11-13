import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/injection/injection.dart';
import '../../../data/datasources/local/local_storage.dart';
import '../../widgets/onboarding/onboarding_page_widget.dart';
import '../../widgets/onboarding/onboarding_indicator.dart';
import '../../widgets/onboarding/onboarding_buttons.dart';
import 'onboarding_data.dart';

/// Pantalla de onboarding/wizard para nuevos usuarios
class OnboardingScreen extends StatefulWidget {
  final String? returnRoute;
  
  const OnboardingScreen({
    super.key,
    this.returnRoute,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < OnboardingData.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() async {
    await _markOnboardingAsCompleted();
    if (mounted) {
      final route = widget.returnRoute ?? '/login';
      context.go(route);
    }
  }

  void _getStarted() async {
    await _markOnboardingAsCompleted();
    if (mounted) {
      final route = widget.returnRoute ?? '/login';
      context.go(route);
    }
  }

  Future<void> _markOnboardingAsCompleted() async {
    final localStorage = sl<LocalStorage>();
    await localStorage.setOnboardingCompleted(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button (solo en las primeras páginas)
              if (_currentPage < OnboardingData.pages.length - 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        'Saltar',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

              // PageView con las páginas
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: OnboardingData.pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      pageData: OnboardingData.pages[index],
                      pageIndex: index,
                      currentIndex: _currentPage,
                    );
                  },
                ),
              ),

              // Indicadores
              OnboardingIndicator(
                currentIndex: _currentPage,
                totalPages: OnboardingData.pages.length,
              ),

              const SizedBox(height: 24),

              // Botones de navegación
              OnboardingButtons(
                currentPage: _currentPage,
                totalPages: OnboardingData.pages.length,
                onNext: _nextPage,
                onSkip: _skipOnboarding,
                onGetStarted: _getStarted,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

