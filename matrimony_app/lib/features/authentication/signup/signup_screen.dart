// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:matrimony_app/core/error_exception_handler.dart';

import '../../../exporter.dart';
import '../../../widgets/loading_button.dart';
import '../../../services/localization_service.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../core/repository.dart';
import '../../../services/shared_preferences_services.dart';
import '../../../services/snackbar_utils.dart';
import '../../navigation/navigation_screen.dart';
import '../../profile_screen/profile_details_model.dart';

class SignUpScreen extends StatefulWidget {
  static const String path = "/signup";

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>(debugLabel: 'signup_form_key');
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisible = false;
  bool signupButtonLoading = false;
  String? selectedGender;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  String? validateFirstName(String? value) {
    return value == null || value.isEmpty ? "First name is required" : null;
  }

  String? validateLastName(String? value) {
    return value == null || value.isEmpty ? "Last name is required" : null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone number is required";
    }
    if (value.length < 10) {
      return "Please enter a valid phone number";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  String? validateGender(String? value) {
    return value == null || value.isEmpty ? "Please select gender" : null;
  }

  bool validate() {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    if (selectedGender == null) {
      showErrorMessage("Please select gender");
      return false;
    }
    return true;
  }

  Future<void> signUp() async {
    if (!validate()) return;

    setState(() {
      signupButtonLoading = true;
    });

    try {
      // Call register API
      final result = await DataRepository.i.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        gender: selectedGender!,
      );

      // Store token
      final token = result['token'] as String;
      await SharedPreferencesService.i.setValue(value: token);

      // Store profile details
      final profile = result['user'] as ProfileDetailsModel;
      await SharedPreferencesService.i.setValue(
        key: 'profile',
        value: profile.toJson(),
      );

      if (!mounted) return;

      // Navigate to home screen
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(NavigationScreen.path, (route) => false);

      // Show success message
      showSuccessMessage("Registration successful!");
    } catch (e) {
      if (!mounted) return;

      // Show error message
      showErrorMessage(handleError(e));
    } finally {
      if (mounted) {
        setState(() {
          signupButtonLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Sign Up", showBorder: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: paddingXL),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapLarge,
              // First Name
              _buildTextField(
                controller: firstNameController,
                hintText: "First Name",
                validator: validateFirstName,
                textInputAction: TextInputAction.next,
                icon: Icons.person_outline,
              ),
              Gap(16.h),

              // Last Name
              _buildTextField(
                controller: lastNameController,
                hintText: "Last Name",
                validator: validateLastName,
                textInputAction: TextInputAction.next,
                icon: Icons.person_outline,
              ),
              Gap(16.h),

              // Email
              _buildTextField(
                controller: emailController,
                hintText: "Email",
                validator: validateEmail,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),
              Gap(16.h),

              // Phone Number
              _buildTextField(
                controller: phoneController,
                hintText: "Phone Number",
                validator: validatePhone,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
              ),
              Gap(16.h),

              // Password
              _buildTextField(
                controller: passwordController,
                hintText: "Password",
                validator: validatePassword,
                textInputAction: TextInputAction.done,
                obscureText: !passwordVisible,
                icon: Icons.lock_outline,
                suffixIcon: IconButton(
                  onPressed: togglePasswordVisibility,
                  icon: Icon(
                    passwordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black.withOpacity(0.5),
                    size: 20.sp,
                  ),
                ),
              ),
              Gap(16.h),

              // Gender Selection
              Row(
                children: [
                  TranslatedText(
                    "Gender",
                    style: context.kanit40014.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    " *",
                    style: context.kanit40014.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Gap(12.h),
              Row(
                children: [
                  Expanded(child: _buildGenderOption("Male")),
                  Gap(16.w),
                  Expanded(child: _buildGenderOption("Female")),
                ],
              ),
              Gap(32.h),

              // Sign Up Button
              LoadingButton(
                buttonLoading: signupButtonLoading,
                text: "Sign Up",
                onPressed: signUp,
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              Gap(24.h),

              // Already have account
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
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
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: "Sign In",
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
              Gap(24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    required TextInputAction textInputAction,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? icon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: context.kanit40015,
      decoration: InputDecoration(
        hintText: hintText.translated,
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.black.withOpacity(0.5), size: 20.sp)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = selectedGender == gender;
    return InkWell(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.1)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: TranslatedText(
            gender,
            style: context.kanit40014.copyWith(
              color: isSelected ? primaryColor : Colors.black.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
