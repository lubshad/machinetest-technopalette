// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:matrimony_app/mixins/event_listener.dart';

import '../../core/app_route.dart';
import '../../core/repository.dart';
import '../../exporter.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/error_widget_with_retry.dart';
import '../../widgets/no_item_found.dart';
import '../profile_screen/common_controller.dart';
import '../profile_screen/profile_details_model.dart';
import '../profile_screen/profile_drawer.dart';
import '../filter_screen/filter_controller.dart';
import '../filter_screen/filter_screen.dart';
import 'widgets/user_card.dart';
import 'widgets/user_card_shimmer.dart';

class HomeScreen extends StatefulWidget {
  static const String path = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with EventListenerMixin {
  late final PagingController<int, ProfileDetailsModel> pagingController;

  @override
  void initState() {
    super.initState();
    allowedEvents = [EventType.refresh];
    listenForEvents((event) {
      pagingController.refresh();
    });
    CommonController.i.init();
    pagingController = PagingController(
      getNextPageKey: (state) => state.nextIntPageKey,
      fetchPage: (pageKey) => _fetchProfiles(pageKey),
    );
  }

  Future<List<ProfileDetailsModel>> _fetchProfiles(int pageKey) async {
    final value = await DataRepository.i.fetchUserProfiles(
      page: pageKey,
      filters: FilterController.i.getFilters(),
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
      backgroundColor: const Color(0xffF8F9FA),
      drawer: const ProfileDrawer(),
      appBar: CustomAppBar(
        showBackButton: false,
        title: "Feed",
        showBorder: false,
        borderColor: Colors.transparent,
        actions: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListenableBuilder(
              listenable: FilterController.i,
              builder: (context, _) {
                final hasFilters = FilterController.i.hasFilters;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () async {
                        final result = await navigate(
                          context,
                          FilterScreen.path,
                        );
                        if (result == true) {
                          pagingController.refresh();
                        }
                      },
                      icon: const Icon(Icons.filter_list),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0XffF5F5F5),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    if (hasFilters)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            gap,
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0XffF5F5F5),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
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
                  firstPageProgressIndicatorBuilder: (context) => Column(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: EdgeInsets.only(bottom: paddingLarge),
                        child: const UserCardShimmer(),
                      ),
                    ),
                  ),
                  newPageProgressIndicatorBuilder: (context) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: UserCardShimmer(),
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
