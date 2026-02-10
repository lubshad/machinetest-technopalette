// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:matrimony_app/features/chat/mixins/chat_mixin.dart';
import 'package:matrimony_app/features/profile_screen/common_controller.dart';
import 'package:matrimony_app/features/profile_screen/profile_details_model.dart';
import 'package:matrimony_app/widgets/custom_appbar.dart';
import 'package:matrimony_app/widgets/user_avatar.dart';
import 'package:matrimony_app/exporter.dart';

class ProfileDetailsScreen extends StatefulWidget {
  static const String path = "/profile-details";
  final ProfileDetailsModel profile;

  const ProfileDetailsScreen({super.key, required this.profile});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen>
    with ChatMixin {
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
                      color: const Color(0xffF5F5F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      padding: const EdgeInsets.all(4),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(21),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: primaryColor,
                      unselectedLabelColor: const Color(0xff666666),
                      labelStyle: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: "About"),
                        Tab(text: "Family"),
                        Tab(text: "Address"),
                      ],
                    ),
                  ),
                  Gap(16.h),
                  Expanded(
                    child: TabBarView(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget profileTopSection(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 430 / 271,
              child: Container(
                decoration: const BoxDecoration(
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(paddingSmall),
                  child: Hero(
                    tag: 'profile_${widget.profile.userId}',
                    child: UserAvatar(
                      size: 135.h,
                      imageUrl: widget.profile.photo,
                      username: widget.profile.fullName,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: CustomAppBar(
                title: widget.profile.firstName,
                borderColor: Colors.transparent,
                textStyle: context.kanit50023.copyWith(color: Colors.white),
                showBackButton: true,
              ),
            ),
          ],
        ),
        gap,
        Text(
          widget.profile.fullName,
          style: const TextStyle(
            color: Color(0xff3C3F4E),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const Gap(4),
        if (widget.profile.email.isNotEmpty)
          Text(
            widget.profile.email,
            style: const TextStyle(color: Color(0xff666666), fontSize: 16),
          ),
        gapLarge,
      ],
    );
  }

  Widget _buildAboutMeTab() {
    final profile = widget.profile;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            _buildSectionTitle(
              "Bio",
              Icons.description_outlined,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
            gapSmall,
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    profile.bio!,
                    style: const TextStyle(
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
          gapSmall,
          _buildInfoCard([
                _buildInfoRow(
                  "Gender",
                  profile.gender?.label ?? "Not specified",
                  Icons.wc,
                ),
                if (profile.phoneNumber != null)
                  _buildInfoRow(
                    "Phone",
                    profile.phoneNumber!,
                    Icons.phone_outlined,
                  ),
                if (profile.height != null)
                  _buildInfoRow("Height", "${profile.height} cm", Icons.height),
                if (profile.weight != null)
                  _buildInfoRow(
                    "Weight",
                    "${profile.weight} kg",
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
    final profile = widget.profile;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Family Details",
            Icons.family_restroom,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          gapSmall,
          if ((profile.fatherName == null || profile.fatherName!.isEmpty) &&
              (profile.motherName == null || profile.motherName!.isEmpty) &&
              (profile.siblings == null) &&
              (profile.familyType == null) &&
              (profile.familyStatus == null))
            _buildEmptyState("No family information available")
          else
            _buildInfoCard([
                  if (profile.fatherName != null &&
                      profile.fatherName!.isNotEmpty)
                    _buildInfoRow(
                      "Father's Name",
                      profile.fatherName!,
                      Icons.person,
                    ),
                  if (profile.motherName != null &&
                      profile.motherName!.isNotEmpty)
                    _buildInfoRow(
                      "Mother's Name",
                      profile.motherName!,
                      Icons.person_2,
                    ),
                  if (profile.siblings != null)
                    _buildInfoRow(
                      "Siblings",
                      profile.siblings.toString(),
                      Icons.people_outline,
                    ),
                  if (profile.familyType != null)
                    _buildInfoRow(
                      "Family Type",
                      profile.familyType!.label,
                      Icons.diversity_1,
                    ),
                  if (profile.familyStatus != null)
                    _buildInfoRow(
                      "Family Status",
                      profile.familyStatus!.label,
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
    final profile = widget.profile;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            "Address",
            Icons.location_on_outlined,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          gapSmall,
          if ((profile.addressLine1 == null || profile.addressLine1!.isEmpty) &&
              (profile.addressLine2 == null || profile.addressLine2!.isEmpty) &&
              (profile.city == null || profile.city!.isEmpty) &&
              (profile.state == null || profile.state!.isEmpty) &&
              (profile.country == null || profile.country!.isEmpty) &&
              (profile.postalCode == null || profile.postalCode!.isEmpty))
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
            color: const Color(0xff1C1F1D),
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
            offset: const Offset(0, 2),
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
            style: context.bodySmall.copyWith(color: const Color(0xff999999)),
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
            style: const TextStyle(
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
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xff3C3F4E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          ListenableBuilder(
            listenable: CommonController.i,
            builder: (context, _) {
              final isInterested =
                  CommonController.i.profileDetails?.interests?.contains(
                    widget.profile.userId,
                  ) ??
                  false;

              return Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInterested
                        ? Colors.grey[200]
                        : primaryColor,
                    foregroundColor: isInterested ? Colors.black : Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: () =>
                      CommonController.i.toggleInterest(widget.profile.userId),
                  child: Text(
                    isInterested ? "Interests Sent" : "Interested",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
          gapLarge,
          ValueListenableBuilder<bool>(
            valueListenable: buttonLoading,
            builder: (context, loading, child) {
              return Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: loading
                    ? SizedBox(
                        width: 56.h,
                        height: 56.h,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        ),
                      )
                    : IconButton(
                        iconSize: 28.sp,
                        padding: EdgeInsets.all(14.r),
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          messageUser(
                            widget.profile.userId.toString(),
                            widget.profile.fullName,
                            widget.profile.photo ?? dummyProfile,
                          );
                        },
                      ),
              );
            },
          ),
        ],
      ),
    ).animate().slideY(
      begin: 1,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOut,
    );
  }
}
