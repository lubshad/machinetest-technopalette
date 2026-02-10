// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/app_route.dart';
import '../../../exporter.dart';
import '../../profile_screen/common_controller.dart';
import '../../profile_screen/profile_details_model.dart';

import '../../chat/mixins/chat_mixin.dart';
import '../../profile_screen/profile_details_screen.dart';

class UserCard extends StatefulWidget {
  final ProfileDetailsModel profile;

  const UserCard({super.key, required this.profile});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> with ChatMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navigate(
        context,
        ProfileDetailsScreen.path,
        arguments: widget.profile,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Hero(
                    tag: 'profile_${widget.profile.userId}',
                    child: CachedNetworkImage(
                      imageUrl: widget.profile.photo ?? dummyProfile,
                      fit: BoxFit.cover,
                      errorWidget: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.h,
                  left: 20.w,
                  right: 20.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.profile.fullName,
                        style: context.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                            size: 14.sp,
                          ),
                          gapTiny,
                          Text(
                            widget.profile.city ?? "Not specified",
                            style: context.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          gapLarge,
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          ),
                          gapLarge,
                          Text(
                            widget.profile.gender?.label ?? "",
                            style: context.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Info Section
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.profile.bio != null &&
                      widget.profile.bio!.isNotEmpty) ...[
                    Text(
                      widget.profile.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMedium.copyWith(
                        color: const Color(0xff666666),
                        height: 1.4,
                      ),
                    ),
                    gap,
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListenableBuilder(
                        listenable: CommonController.i,
                        builder: (context, _) {
                          final isInterested =
                              CommonController.i.profileDetails?.interests
                                  ?.contains(widget.profile.userId) ??
                              false;

                          return Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInterested
                                    ? Colors.grey[200]
                                    : primaryColor,
                                foregroundColor: isInterested
                                    ? Colors.black
                                    : Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              onPressed: () => CommonController.i
                                  .toggleInterest(widget.profile.userId),
                              child: Text(
                                isInterested ? "Interests Sent" : "Interested",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
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
                                ? const SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: primaryColor,
                                      ),
                                    ),
                                  )
                                : IconButton(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
