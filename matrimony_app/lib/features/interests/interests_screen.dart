import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../mixins/event_listener.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/no_item_found.dart';
import '../home_screen/widgets/user_card.dart';
import '../profile_screen/profile_details_model.dart';

class InterestsScreen extends StatefulWidget {
  static const String path = "/interests";

  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen>
    with EventListenerMixin {
  late final PagingController<int, ProfileDetailsModel> pagingController;

  @override
  void initState() {
    super.initState();
    allowedEvents = [EventType.interestToggel];
    listenForEvents((event) {
      pagingController.refresh();
    });

    pagingController = PagingController(
      getNextPageKey: (state) => state.nextIntPageKey,
      fetchPage: (pageKey) => _fetchInterests(pageKey),
    );
  }

  Future<List<ProfileDetailsModel>> _fetchInterests(int pageKey) async {
    final value = await DataRepository.i.fetchMyInterests(page: pageKey);
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
      backgroundColor: const Color(0xffF8F9FA),
      appBar: CustomAppBar(
        title: "My Interests",
        showBackButton: false,
        actions: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0XffF5F5F5),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => pagingController.refresh(),
        color: primaryColor,
        child: PagingListener(
          controller: pagingController,
          builder: (context, state, fetchNextPage) =>
              PagedListView<int, ProfileDetailsModel>.separated(
                fetchNextPage: fetchNextPage,
                state: state,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                  firstPageProgressIndicatorBuilder: (context) => const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  itemBuilder: (context, item, index) => UserCard(profile: item)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (index % 5 * 100).ms)
                      .slideY(begin: 0.1, end: 0),
                ),
                separatorBuilder: (context, index) => gapLarge,
              ),
        ),
      ),
    );
  }
}
