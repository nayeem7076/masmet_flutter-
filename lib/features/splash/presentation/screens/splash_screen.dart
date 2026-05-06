import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:messmate_app_full/core/constants/app_constants.dart';
import 'package:messmate_app_full/core/localization/app_text.dart';
import 'package:messmate_app_full/features/auth/presentation/screens/login_screen.dart';
import 'package:messmate_app_full/features/auth/presentation/viewmodels/app_provider.dart';
import 'package:messmate_app_full/features/home/presentation/screens/home_screen.dart';
import 'package:messmate_app_full/features/onboarding/presentation/screens/onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late final AnimationController _textIntroController;
  bool _showGif = true;
  bool _showVideo = false;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    _textIntroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _setupSplashMedia();
    Future.microtask(() {
      if (!mounted) return;
      setState(() {
        _animateIn = true;
      });
    });
    Future.delayed(const Duration(milliseconds: 3300), () {
      if (!mounted) return;
      final provider = ref.read(appProviderProvider);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) {
            if (AppConstants.skipLoginForTesting) {
              return const HomeScreen();
            }
            return !provider.onboarded
                ? const OnboardingScreen()
                : provider.isLoggedIn
                    ? const HomeScreen()
                    : const LoginScreen();
          },
        ),
      );
    });
  }

  Future<void> _setupSplashMedia() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/videos/splash.mp4',
      );
      await controller.initialize();
      controller.setLooping(true);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _videoController = controller;
        _showVideo = true;
      });
    } catch (_) {
      // Keep GIF fallback when video is missing/invalid.
      if (!mounted) return;
      setState(() {
        _showVideo = false;
      });
    }
  }

  @override
  void dispose() {
    _textIntroController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                opacity: _animateIn ? 1 : 0,
                child: _showGif
                    ? Container(
                        width: 270,
                        height: 270,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFDFF0FF), Color(0xFFEDF5FF)],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x332A6DDE),
                              blurRadius: 24,
                              offset: Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/splash_loader.gif',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) {
                              return Image.asset(
                                'assets/images/logo.png',
                                width: 180,
                                height: 180,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                      )
                    : _showVideo && _videoController != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: SizedBox(
                              width: 260,
                              height: 260,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _videoController!.value.size.width,
                                  height: _videoController!.value.size.height,
                                  child: VideoPlayer(_videoController!),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                width: 180,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'MessMate',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppText.t(
                                  context,
                                  bn: 'স্মার্ট মেস ম্যানেজমেন্ট',
                                  en: 'Smart Mess Management',
                                ),
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _textIntroController,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.35),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _textIntroController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Power By Razin Soft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                        shadows: [
                          Shadow(
                            color: Color(0xAA79B8FF),
                            blurRadius: 10,
                          ),
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
    );
  }
}
