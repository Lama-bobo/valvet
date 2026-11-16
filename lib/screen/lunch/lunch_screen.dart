import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:souqna_anaqa/getx_controller/app_getx_controller.dart';
import 'package:souqna_anaqa/getx_controller/user_profile_getx_controller.dart';
import 'package:souqna_anaqa/screen/bottom_nav_bar/main_screen.dart';
import 'package:souqna_anaqa/utils/app_colors.dart';

/// شاشة البداية: تحمّل هوية المتجر (الاسم، الشعار، اللون) ثم تنتقل للرئيسية.
class LunchScreen extends StatefulWidget {
  const LunchScreen({super.key});

  @override
  State<LunchScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<LunchScreen> {
  /// أقل مدة حتى لا يومض الشعار، وأقصى مدة قبل فتح الرئيسية مهما تأخر الخادم.
  static const _minDuration = Duration(milliseconds: 1400);
  static const _maxDuration = Duration(seconds: 3);

  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _error = null);
    final app = Get.find<AppGetxController>();
    // الحساب محفوظ على الجهاز؛ تحديثه من الخادم يكمل بالخلفية بدون انتظار.
    Get.find<UserProfileGetxController>().fetchUserProfile();
    final results = await Future.wait([
      // إذا تأخر الخادم نفتح الرئيسية والطلب يكمل بالخلفية:
      // اسم المتجر وشعاره ولونه تتحدّث تلقائيًا (Obx) عند وصولها.
      app.fetchStore().timeout(_maxDuration, onTimeout: () => true),
      Future.delayed(_minDuration),
    ]);
    if (!mounted) return;
    if (results.first == true) {
      Get.offAll(() => const MainScreen(), transition: Transition.fadeIn);
    } else {
      setState(() => _error = app.errorMessage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = Get.find<AppGetxController>();
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Obx(() => _Glow(color: app.primary.value, size: 340)),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: Obx(
              () => _Glow(
                color: app.primary.value.withValues(alpha: 0.6),
                size: 300,
              ),
            ),
          ),
          // عمود بدل Positioned: في الوضع الأفقي لا يتداخل المؤشر السفلي مع الشعار.
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutBack,
                        builder: (_, v, child) => Opacity(
                          opacity: v.clamp(0, 1),
                          child: Transform.scale(
                            scale: 0.85 + 0.15 * v,
                            child: child,
                          ),
                        ),
                        child: Obx(() {
                          final store = app.store.value;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // نفس لوجو أيقونة التطبيق وشاشة الإقلاع الأصلية.
                              Image.asset(
                                'assets/splash/splash_logo.png',
                                height: 120.r,
                              ),
                              const SizedBox(height: 22),
                              Text(
                                store?.name ?? 'Velvet',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                store?.tagline ?? 'أناقتك تبدأ من هنا',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: _error == null
                      ? SizedBox(
                          width: 26,
                          height: 26,
                          child: Obx(
                            () => CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: app.primary.value,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _start,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'إعادة المحاولة',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
      ),
    ),
  );
}
