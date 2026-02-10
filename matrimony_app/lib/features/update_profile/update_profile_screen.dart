// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:matrimony_app/mixins/event_listener.dart';

import '../../core/repository.dart';
import '../../exporter.dart';
import '../../services/snackbar_utils.dart';
import '../../widgets/bottom_button_padding.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loading_button.dart';
import '../profile_screen/common_controller.dart';
import '../profile_screen/profile_details_model.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const String path = "/update-profile";
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController siblingsController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  Gender? selectedGender;
  FamilyType? selectedFamilyType;
  FamilyStatus? selectedFamilyStatus;
  bool buttonLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final profile = CommonController.i.profileDetails;
    if (profile != null) {
      firstNameController.text = profile.firstName;
      lastNameController.text = profile.lastName;
      emailController.text = profile.email;
      phoneController.text = profile.phoneNumber ?? '';
      heightController.text = profile.height?.toString() ?? '';
      weightController.text = profile.weight?.toString() ?? '';
      addressLine1Controller.text = profile.addressLine1 ?? '';
      addressLine2Controller.text = profile.addressLine2 ?? '';
      cityController.text = profile.city ?? '';
      stateController.text = profile.state ?? '';
      countryController.text = profile.country ?? '';
      postalCodeController.text = profile.postalCode ?? '';
      fatherNameController.text = profile.fatherName ?? '';
      motherNameController.text = profile.motherName ?? '';
      siblingsController.text = profile.siblings?.toString() ?? '';
      bioController.text = profile.bio ?? '';
      selectedGender = profile.gender;
      selectedFamilyType = profile.familyType;
      selectedFamilyStatus = profile.familyStatus;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    siblingsController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Update Profile"),
      bottomNavigationBar: BottomButtonPadding(
        child: LoadingButton(
          buttonLoading: buttonLoading,
          text: "Update",
          onPressed: submit,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: middlePadding,
          vertical: paddingLarge,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionTitle("Personal Information"),
              gapLarge,

              _buildTextField(
                controller: firstNameController,
                label: "First Name",
                icon: Icons.person_outline,
                validator: (value) =>
                    value?.isEmpty ?? true ? "First name is required" : null,
              ),
              gap,

              _buildTextField(
                controller: lastNameController,
                label: "Last Name",
                icon: Icons.person_outline,
                validator: (value) =>
                    value?.isEmpty ?? true ? "Last name is required" : null,
              ),
              gap,

              _buildTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return "Email is required";
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value!)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              gap,

              _buildTextField(
                controller: phoneController,
                label: "Phone Number",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value?.isEmpty ?? true) return "Phone number is required";
                  if (value!.length < 10) {
                    return "Please enter a valid phone number";
                  }
                  return null;
                },
              ),
              gap,

              // Gender Selection
              _buildLabel("Gender"),
              gapSmall,
              Row(
                children: [
                  Expanded(child: _buildGenderOption(Gender.male)),
                  gapSmall,
                  Expanded(child: _buildGenderOption(Gender.female)),
                ],
              ),
              gapLarge,

              // Physical Attributes Section
              _buildSectionTitle("Physical Attributes"),
              gapLarge,

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: heightController,
                      label: "Height (cm)",
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  gapSmall,
                  Expanded(
                    child: _buildTextField(
                      controller: weightController,
                      label: "Weight (kg)",
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              gapLarge,

              // Address Section
              _buildSectionTitle("Address"),
              gapLarge,

              _buildTextField(
                controller: addressLine1Controller,
                label: "Address Line 1",
                icon: Icons.home_outlined,
              ),
              gap,

              _buildTextField(
                controller: addressLine2Controller,
                label: "Address Line 2",
                icon: Icons.home_outlined,
              ),
              gap,

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: cityController,
                      label: "City",
                      icon: Icons.location_city,
                    ),
                  ),
                  gapSmall,
                  Expanded(
                    child: _buildTextField(
                      controller: stateController,
                      label: "State",
                      icon: Icons.map_outlined,
                    ),
                  ),
                ],
              ),
              gap,

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: countryController,
                      label: "Country",
                      icon: Icons.flag_outlined,
                    ),
                  ),
                  gapSmall,
                  Expanded(
                    child: _buildTextField(
                      controller: postalCodeController,
                      label: "Postal Code",
                      icon: Icons.markunread_mailbox_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              gapLarge,

              // Family Information Section
              _buildSectionTitle("Family Information"),
              gapLarge,

              _buildTextField(
                controller: fatherNameController,
                label: "Father's Name",
                icon: Icons.person_outline,
              ),
              gap,

              _buildTextField(
                controller: motherNameController,
                label: "Mother's Name",
                icon: Icons.person_outline,
              ),
              gap,

              _buildTextField(
                controller: siblingsController,
                label: "Number of Siblings",
                icon: Icons.people_outline,
                keyboardType: TextInputType.number,
              ),
              gap,

              // Family Type
              _buildLabel("Family Type"),
              gapSmall,
              Row(
                children: [
                  Expanded(child: _buildFamilyTypeOption(FamilyType.nuclear)),
                  gapSmall,
                  Expanded(child: _buildFamilyTypeOption(FamilyType.joint)),
                ],
              ),
              gapLarge,

              // Family Status
              _buildLabel("Family Status"),
              gapSmall,
              _buildFamilyStatusOption(FamilyStatus.middleClass),
              gapSmall,
              _buildFamilyStatusOption(FamilyStatus.upperMiddleClass),
              gapSmall,
              _buildFamilyStatusOption(FamilyStatus.rich),
              gapLarge,

              // Bio Section
              _buildSectionTitle("About Me"),
              gapLarge,

              _buildTextField(
                controller: bioController,
                label: "Bio",
                icon: Icons.description_outlined,
                maxLines: 5,
              ),
              gapXL,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: context.kanit50020.copyWith(
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: context.kanit40014.copyWith(
        fontWeight: FontWeight.w500,
        color: Colors.black.withOpacity(0.7),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: context.kanit40015,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Colors.black.withOpacity(0.5),
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildGenderOption(Gender gender) {
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
          child: Text(
            gender.label,
            style: context.kanit40014.copyWith(
              color: isSelected ? primaryColor : Colors.black.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyTypeOption(FamilyType type) {
    final isSelected = selectedFamilyType == type;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFamilyType = type;
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
          child: Text(
            type.label,
            style: context.kanit40014.copyWith(
              color: isSelected ? primaryColor : Colors.black.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyStatusOption(FamilyStatus status) {
    final isSelected = selectedFamilyStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFamilyStatus = status;
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
          child: Text(
            status.label,
            style: context.kanit40014.copyWith(
              color: isSelected ? primaryColor : Colors.black.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      buttonLoading = true;
    });

    final updatedProfile = CommonController.i.profileDetails!.copyWith(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      gender: selectedGender,
      height: double.tryParse(heightController.text),
      weight: double.tryParse(weightController.text),
      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: countryController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      fatherName: fatherNameController.text.trim(),
      motherName: motherNameController.text.trim(),
      siblings: int.tryParse(siblingsController.text),
      familyType: selectedFamilyType,
      familyStatus: selectedFamilyStatus,
      bio: bioController.text.trim(),
    );

    DataRepository.i
        .updateProfileDetails(updatedProfile)
        .then((value) async {
          setState(() {
            buttonLoading = false;
          });
          showSuccessMessage("Profile updated successfully");
          await CommonController.i.fetchProfileDetails();
          EventListener.i.sendEvent(Event(eventType: EventType.refresh));
          Navigator.pop(context);
        })
        .catchError((error) {
          setState(() {
            buttonLoading = false;
          });
          showErrorMessage(error.toString());
        });
  }
}
