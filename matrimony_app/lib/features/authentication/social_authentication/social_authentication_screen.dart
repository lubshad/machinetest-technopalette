// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/app_route.dart';
import '../../../exporter.dart';
import '../../../widgets/loading_button.dart';
import 'email_and_password_mixin.dart';

import '../../../services/localization_service.dart';
import 'package:gap/gap.dart';
import '../signup/signup_screen.dart';

class SocialAuthenticationScreen extends StatefulWidget {
  static const String path = "/social-authentication";

  const SocialAuthenticationScreen({super.key});

  @override
  State<SocialAuthenticationScreen> createState() =>
      _SocialAuthenticationScreenState();
}

class _SocialAuthenticationScreenState extends State<SocialAuthenticationScreen>
    with EmailPasswordMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: primaryColor),
          Align(
            alignment: Alignment.topCenter,
            child: Assets.pngs.socialAuth.image(fit: BoxFit.cover),
          ),
          // LoginBackground(assetImage: Assets.pngs.socialAuth.path),
          LoginBottomSheet(
            child: Form(
              key: formKey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: Theme.of(context).inputDecorationTheme
                      .copyWith(hintStyle: hintStyle.copyWith(fontSize: 15.sp)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      "Hello\nAgain!",
                      style: context.kanit40036.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    Gap(8.h),
                    TranslatedText(
                      "Welcome back, you've been missed!",
                      style: context.kanit30016.copyWith(
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    Gap(32.h),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: usernameController,
                      validator: validateUsername,
                      style: context.kanit40015,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 12.w),
                          child: SvgPicture.asset(
                            Assets.svgs.personOutline,
                            width: 20.w,
                            height: 20.h,
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 40.w,
                          minHeight: 40.h,
                        ),
                        hintText: "Enter username".translated,
                      ),
                    ),
                    Gap(20.h),
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (value) => signInWithEmailAndPassword(),
                      obscureText: !passwordVisible,
                      validator: passwordValidator,
                      controller: passwordController,
                      style: context.kanit40015,
                      decoration: InputDecoration(
                        errorText: passwordError,
                        hintText: "Password".translated,
                        suffixIcon: IconButton(
                          onPressed: touglePasswordVisibility,
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.black.withOpacity(0.5),
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    Gap(32.h),
                    LoadingButton(
                      buttonLoading: loginButtonLoading,
                      text: "Sign In",
                      onPressed: signInWithEmailAndPassword,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    Gap(24.h),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          navigate(context, SignUpScreen.path);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: context.kanit40014.copyWith(
                              color: Colors.black.withOpacity(0.6),
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: "Sign Up",
                                style: context.kanit40014.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void navigateForgotPassword() {}

  // void signupAction() {}
}

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingXL,
          vertical: paddingXL * 1.5,
        ),
        child: child,
      ),
    );
  }
}

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key, this.assetImage});

  final String? assetImage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.h,
      right: 40.h,
      left: 40.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            "Your app description here.",
            style: context.labelLarge.copyWith(color: Colors.white),
          ),
          gapXL,
          Row(
            children: [
              Expanded(
                child:
                    (assetImage ?? Assets.svgs.loginGraphics).endsWith('.svg')
                    ? SvgPicture.asset(assetImage ?? Assets.svgs.loginGraphics)
                    : Image.asset(assetImage ?? Assets.svgs.loginGraphics),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? domainValidator(
  TextEditingController controller, {
  bool required = false,
}) {
  if (required && controller.text.isEmpty) {
    return "Domain is required".translated;
  } else if (controller.text.isNotEmpty) {
    var uri = Uri.tryParse(controller.text);
    if (uri?.hasScheme == false) {
      controller.text = "https://${controller.text}";
      uri = Uri.tryParse(controller.text);
      controller.text = controller.text;
    }

    if (uri == null ||
        !uri.hasScheme ||
        !["https", "http"].contains(uri.scheme) ||
        uri.authority == "" ||
        !uri.authority.contains(".") ||
        uri.authority.split(".").last.length < 2) {
      return "Enter a valid url eg:(www.touch2scan.com)".translated;
    }
    return null;
  }
  return null;
}
