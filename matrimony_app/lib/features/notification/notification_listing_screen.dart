import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/list_tile_shimmer.dart';
import '../../widgets/no_item_found.dart';
import 'models/notification_history_model.dart';
import 'notification_listing_item.dart';

class NotificationListingScreen extends StatefulWidget {
  static const String path = "/notification-listing";

  const NotificationListingScreen({super.key});

  @override
  State<NotificationListingScreen> createState() =>
      _NotificationListingScreenState();
}

class _NotificationListingScreenState extends State<NotificationListingScreen>
    with EventListenerMixin {
  late final PagingController<int, NotificationHistoryModel> pagingController;

  @override
  void initState() {
    super.initState();
    pagingController = PagingController(
      getNextPageKey: (state) => state.nextIntPageKey,
      fetchPage: (pageKey) => _fetchNotifications(pageKey),
    );
    allowedEvents = [EventType.notification, EventType.resumed];
    listenForEvents((event) {
      pagingController.refresh();
    });
  }

  Future<List<NotificationHistoryModel>> _fetchNotifications(
    int pageKey,
  ) async {
    final value = await DataRepository.i.fetchNotificationHistory(
      page: pageKey,
    );
    if (!value.hasNext) {
      pagingController.value = pagingController.value.copyWith(
        hasNextPage: false,
      );
    }
    return value.results;
  }

  @override
  void dispose() {
    pagingController.dispose();
    disposeEventListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: ("Notifications")),
      body: RefreshIndicator(
        onRefresh: () async => pagingController.refresh(),
        child: PagingListener(
          controller: pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, NotificationHistoryModel>.separated(
                fetchNextPage: fetchNextPage,
                state: state,
                padding: const EdgeInsets.all(middlePadding),
                builderDelegate: PagedChildBuilderDelegate(
                  firstPageErrorIndicatorBuilder: (context) => SizedBox(
                    height: 400,
                    child: ErrorWidgetWithRetry(
                      exception: state.error,
                      retry: pagingController.refresh,
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (context) =>
                      const NoItemsFound(),
                  firstPageProgressIndicatorBuilder: (context) => Column(
                    children: List.generate(4, (index) => ListTileShimmer()),
                  ),
                  itemBuilder: (context, item, index) =>
                      NotificationListingItem(item: item),
                ),
                separatorBuilder: (context, index) =>
                    Divider(color: dividerColor),
              ),
        ),
      ),
    );
  }
}
