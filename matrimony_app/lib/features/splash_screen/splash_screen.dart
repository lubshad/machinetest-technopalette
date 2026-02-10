// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_route.dart';
import '../../exporter.dart';
import '../../services/shared_preferences_services.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/network_resource.dart';
import '../authentication/landing_screen/landing_screen.dart';
import '../navigation/navigation_screen.dart';
import '../profile_screen/common_controller.dart';
import 'models/registration_state.dart';

class SplashScreen extends StatefulWidget {
  static const String path = "/splash-screen";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void>? future;

  @override
  void initState() {
    super.initState();
    fetchRegistrationState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NetworkResource(
        future,
        error: (error) => ErrorWidgetWithRetry(
          exception: error,
          retry: fetchRegistrationState,
        ),
        success: (data) => const SizedBox(),
        loading: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                    "assets/pngs/app_icon.png",
                    width: 250.w,
                    height: 250.w,
                  )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 1000.ms,
                    curve: Curves.elasticOut,
                  )
                  .shimmer(
                    delay: 1000.ms,
                    duration: 1500.ms,
                    color: Colors.white.withOpacity(0.6),
                    size: 2,
                  ) // Shimmer effect
                  .animate(
                    delay: 2500.ms, // Wait for intro to complete
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scaleXY(
                    begin: 1,
                    end: 1.05,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  )
                  .moveY(
                    begin: 0,
                    end: -10,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  ),
              gapLarge,
              Text(
                    "CONNECT",
                    style: context.kanit50027.copyWith(
                      letterSpacing: 4,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),
              gapSmall,
              Text(
                    "Find your perfect match",
                    style: context.kanit30016.copyWith(
                      color: Colors.black54,
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),
            ],
          ),
        ),
      ),
    );
  }

  void fetchRegistrationState() async {
    final isLoggedIn = (await SharedPreferencesService.i.token) != "";
    if (isLoggedIn) {
      CommonController.i.init();
    }
    setState(() {
      future =
          Future.wait([
            // DataRepository.i.fetchRegistrationState(),
            Future.delayed(const Duration(seconds: 3)),
          ]).then((value) async {
            // throw DioException(requestOptions: RequestOptions());
            RegistrationState state = RegistrationState.completed;
            // RegistrationState.fromString(value.first.data["state"]);
            switch (state) {
              case RegistrationState.basicDetails:
              // Navigator.pushNamedAndRemoveUntil(
              //     context, BasicDetailsForm.path, (route) => false);
              // break;
              case RegistrationState.programSelection:
              // Navigator.pushNamedAndRemoveUntil(
              //     context, ProgramSelectionForm.path, (route) => false);
              // break;
              case RegistrationState.completed:
                if (isLoggedIn) {
                  navigate(context, NavigationScreen.path, replace: true);
                } else {
                  navigate(context, LandingPage.path, replace: true);
                }
                break;
            }
          });
    });
  }
}
