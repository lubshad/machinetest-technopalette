
// ignore_for_file: deprecated_member_use

import 'package:agora_chat_uikit/chat_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:matrimony_app/main.dart';

import '../../core/app_route.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../mixins/user_image_mixin.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/user_avatar.dart';
import '../update_profile/update_profile_screen.dart';
import 'common_controller.dart';

class ProfileScreen extends StatefulWidget {
  static const String path = "/profile-screen";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with UserImageMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          profileTopSection(context),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: padding),
                    decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      padding: EdgeInsets.all(4),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: primaryColor,
                      unselectedLabelColor: Color(0xff666666),
                      labelStyle: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: "About Me"),
                        Tab(text: "Family"),
                        Tab(text: "Address"),
                      ],
                    ),
                  ),
                  Gap(16.h),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: CommonController.i,
                      builder: (context, child) {
                        return TabBarView(
                          children: [
                            _buildAboutMeTab()
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.1, end: 0),
                            _buildFamilyInfoTab()
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.1, end: 0),
                            _buildResidentialInfoTab()
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .slideX(begin: 0.1, end: 0),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileTopSection(BuildContext context) {
    return AnimatedBuilder(
      animation: CommonController.i,
      builder: (context, child) {
        return Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 430 / 271,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff012036),
                          Color(0xff001734),
                          Color(0xff0A353F),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  height: 70.h,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(paddingXL),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  height: 140.h,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 140.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(paddingSmall),
                      child: Stack(
                        children: [
                          UserAvatar(
                            size: 135.h,
                            imageUrl: CommonController.i.profileDetails?.photo,
                            username:
                                CommonController.i.profileDetails?.fullName ??
                                "",
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton.filled(
                              style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(
                                  Colors.black.withAlpha(.5.alpha),
                                ),
                              ),
                              onPressed: () => showImagePicker(
                                image: "profile",
                                onChanged: () {
                                  DataRepository.i
                                      .updateProfileDetails(
                                        CommonController.i.profileDetails!
                                            .copyWith(
                                              photoFile: selectedProfileImage,
                                            ),
                                      )
                                      .then((_) async {
                                        await CommonController.i
                                            .fetchProfileDetails();

                                        await ChatUIKit.instance.updateUserInfo(
                                          avatarUrl:
                                              CommonController
                                                  .i
                                                  .profileDetails!
                                                  .photo ??
                                              "",
                                        );
                                      });
                                },
                              ),
                              icon: Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  // child: AppBar(),
                  child: CustomAppBar(
                    title: "Profile",
                    borderColor: Colors.transparent,
                    textStyle: context.kanit50023.copyWith(color: Colors.white),
                    actions: SizedBox(
                      width: 104.h,
                      child: LoadingButton(
                        textColor: Colors.white,
                        buttonType: ButtonType.outlined,
                        aspectRatio: 104 / 31,
                        buttonLoading: false,
                        text: "Edit Profile",
                        onPressed: () => navigate(
                          navigatorKey.currentContext!,
                          UpdateProfileScreen.path,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            gap,
            Text(
              CommonController.i.profileDetails?.fullName ?? "",
              style: TextStyle(
                color: Color(0xff3C3F4E),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Gap(4),
            Text(
              CommonController.i.profileDetails?.email ?? "",
              style: TextStyle(color: Color(0xff666666), fontSize: 16),
            ),
            gapLarge,
          ],
        );
      },
    );
  }

  Widget _buildAboutMeTab() {
    final profile = CommonController.i.profileDetails;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
            _buildSectionTitle(
              "Bio",
              Icons.description_outlined,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
            gapLarge,
            Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    profile.bio!,
                    style: TextStyle(
                      color: Color(0xff666666),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
            gapLarge,
          ],
          _buildSectionTitle(
            "Personal Information",
            Icons.person_outline,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          gapLarge,
          _buildInfoCard([
                _buildInfoRow(
                  "Gender",
                  profile?.gender?.label ?? "Not specified",
                  Icons.wc,
                ),
                _buildInfoRow(
                  "Phone",
                  profile?.phoneNumber ?? "Not specified",
                  Icons.phone_outlined,
                ),
                if (profile?.height != null)
                  _buildInfoRow(
                    "Height",
                    "${profile!.height} cm",
                    Icons.height,
                  ),
                if (profile?.weight != null)
                  _buildInfoRow(
                    "Weight",
                    "${profile!.weight} kg",
                    Icons.monitor_weight_outlined,
                  ),
              ])
              .animate()
              .fadeIn(duration: 400.ms, delay: 150.ms)
              .slideY(begin: 0.1, end: 0),
          gapLarge,
        ],
      ),
    );
  }

  Widget _buildFamilyInfoTab() {
    final profile = CommonController.i.profileDetails;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Family Details",
            Icons.family_restroom,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          gapLarge,
          if ((profile?.fatherName == null || profile!.fatherName!.isEmpty) &&
              (profile?.motherName == null || profile!.motherName!.isEmpty) &&
              profile?.siblings == null &&
              profile?.familyType == null &&
              profile?.familyStatus == null)
            _buildEmptyState("No family information available")
          else
            _buildInfoCard([
                  if (profile?.fatherName != null &&
                      profile!.fatherName!.isNotEmpty)
                    _buildInfoRow(
                      "Father's Name",
                      profile.fatherName!,
                      Icons.person,
                    ),
                  if (profile?.motherName != null &&
                      profile!.motherName!.isNotEmpty)
                    _buildInfoRow(
                      "Mother's Name",
                      profile.motherName!,
                      Icons.person_2,
                    ),
                  if (profile?.siblings != null)
                    _buildInfoRow(
                      "Siblings",
                      profile!.siblings.toString(),
                      Icons.people_outline,
                    ),
                  if (profile?.familyType != null)
                    _buildInfoRow(
                      "Family Type",
                      profile!.familyType!.label,
                      Icons.diversity_1,
                    ),
                  if (profile?.familyStatus != null)
                    _buildInfoRow(
                      "Family Status",
                      profile!.familyStatus!.label,
                      Icons.currency_rupee,
                    ),
                ])
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildResidentialInfoTab() {
    final profile = CommonController.i.profileDetails;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Address",
            Icons.location_on_outlined,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          gapLarge,
          if ((profile?.addressLine1 == null ||
                  profile!.addressLine1!.isEmpty) &&
              (profile?.addressLine2 == null ||
                  profile!.addressLine2!.isEmpty) &&
              (profile?.city == null || profile!.city!.isEmpty) &&
              (profile?.state == null || profile!.state!.isEmpty) &&
              (profile?.country == null || profile!.country!.isEmpty) &&
              (profile?.postalCode == null || profile!.postalCode!.isEmpty))
            _buildEmptyState("No residential information available")
          else
            _buildInfoCard([
                  if (profile.addressLine1 != null &&
                      profile.addressLine1!.isNotEmpty)
                    _buildInfoRow(
                      "Address Line 1",
                      profile.addressLine1!,
                      Icons.home_outlined,
                    ),
                  if (profile.addressLine2 != null &&
                      profile.addressLine2!.isNotEmpty)
                    _buildInfoRow(
                      "Address Line 2",
                      profile.addressLine2!,
                      Icons.home_outlined,
                    ),
                  if (profile.city != null && profile.city!.isNotEmpty)
                    _buildInfoRow("City", profile.city!, Icons.location_city),
                  if (profile.state != null && profile.state!.isNotEmpty)
                    _buildInfoRow("State", profile.state!, Icons.map_outlined),
                  if (profile.country != null && profile.country!.isNotEmpty)
                    _buildInfoRow(
                      "Country",
                      profile.country!,
                      Icons.flag_outlined,
                    ),
                  if (profile.postalCode != null &&
                      profile.postalCode!.isNotEmpty)
                    _buildInfoRow(
                      "Postal Code",
                      profile.postalCode!,
                      Icons.markunread_mailbox_outlined,
                    ),
                ])
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: primaryColor),
        Gap(8.w),
        Text(
          title,
          style: context.kanit50018.copyWith(
            fontWeight: FontWeight.w600,
            color: Color(0xff1C1F1D),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children.expand((element) => [element, gap]).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: paddingXL * 2),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 40.sp,
            color: Colors.black.withOpacity(0.1),
          ),
          gap,
          Text(
            message,
            style: context.bodySmall.copyWith(color: Color(0xff999999)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale();
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Colors.black.withOpacity(0.5)),
        Gap(12.w),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xff3C3F4E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
