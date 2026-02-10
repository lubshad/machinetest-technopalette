import 'package:flutter/material.dart';

import '../../exporter.dart';
import '../../services/fcm_service.dart';
import '../../services/localization_service.dart';
import 'models/notification_history_model.dart';

class NotificationListingItem extends StatelessWidget {
  const NotificationListingItem({super.key, required this.item});

  final NotificationHistoryModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(paddingLarge),
        // boxShadow: defaultShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final url = item.actionUrl;
            if (url != null && url.isNotEmpty) {
              FCMService.handleData(url);
              return;
            }
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    paddingLarge,
                    paddingLarge,
                    paddingLarge,
                    paddingLarge + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(item.title, style: context.kanit50018),
                      gapSmall,
                      TranslatedText(
                        item.createdAt.dateTimeFormat ?? "N/A",
                        style: context.bodySmall.copyWith(
                          color: const Color(0xff3C3F4E),
                        ),
                      ),
                      gapLarge,
                      TranslatedText(item.body, style: context.kanit30014),
                    ],
                  ),
                );
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: paddingLarge,
              vertical: paddingSmall,
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 14.w,
                  ),
                ),
                gapLarge,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        item.createdAt.dateTimeFormat ?? "N/A",
                        style: context.bodySmall.copyWith(
                          color: Color(0xff3C3F4E),
                        ),
                      ),
                      gapSmall,
                      TranslatedText(
                        item.title,
                        maxLines: 1,
                        style: context.kanit40015,
                      ),
                      gapSmall,

                      TranslatedText(
                        item.body,
                        maxLines: 2,
                        style: context.kanit30010.copyWith(
                          color: Color(0xff666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
