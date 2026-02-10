// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../../core/app_route.dart';
import '../../chat/chats.dart';
import '../../home_screen/home_screen.dart';
import '../../interests/interests_screen.dart';
import '../../profile_screen/profile_screen.dart';

final feedNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "feed");
final interestsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: "interests",
);
final chatNavigationKey = GlobalKey<NavigatorState>(debugLabel: "chat");
final profileNavigationKey = GlobalKey<NavigatorState>(debugLabel: "profile");

enum Screens {
  feed,
  interests,
  chat,
  profile;

  BuildContext get context {
    switch (this) {
      case Screens.feed:
        return feedNavigatorKey.currentContext!;
      case Screens.interests:
        return interestsNavigatorKey.currentContext!;
      case Screens.chat:
        return chatNavigationKey.currentContext!;
      case Screens.profile:
        return profileNavigationKey.currentContext!;
    }
  }

  Widget get bottomIcon {
    switch (this) {
      case Screens.feed:
        return const Icon(Icons.home_outlined);
      case Screens.interests:
        return const Icon(Icons.favorite_border);
      case Screens.chat:
        return const Icon(Icons.chat_bubble_outline);
      case Screens.profile:
        return const Icon(Icons.person_outline);
    }
  }

  GlobalKey get navigatorKey {
    switch (this) {
      case Screens.feed:
        return feedNavigatorKey;
      case Screens.interests:
        return interestsNavigatorKey;
      case Screens.chat:
        return chatNavigationKey;
      case Screens.profile:
        return profileNavigationKey;
    }
  }

  String get initialRoute {
    switch (this) {
      case Screens.feed:
        return HomeScreen.path;
      case Screens.interests:
        return InterestsScreen.path;
      case Screens.chat:
        return ChatPage.path;
      case Screens.profile:
        return ProfileScreen.path;
    }
  }

  Widget get activeIcon {
    switch (this) {
      case Screens.feed:
        return const Icon(Icons.home, color: Colors.white);
      case Screens.interests:
        return const Icon(Icons.favorite, color: Colors.white);
      case Screens.chat:
        return const Icon(Icons.chat_bubble, color: Colors.white);
      case Screens.profile:
        return const Icon(Icons.person, color: Colors.white);
    }
  }

  Widget get body {
    switch (this) {
      case Screens.feed:
        return Navigator(
          key: feedNavigatorKey,
          onGenerateRoute: AppRoute.onGenerateRoute,
          initialRoute: initialRoute,
        );
      case Screens.interests:
        return Navigator(
          key: interestsNavigatorKey,
          onGenerateRoute: AppRoute.onGenerateRoute,
          initialRoute: initialRoute,
        );
      case Screens.chat:
        return Navigator(
          key: chatNavigationKey,
          onGenerateRoute: AppRoute.onGenerateRoute,
          initialRoute: initialRoute,
        );

      case Screens.profile:
        return Navigator(
          key: profileNavigationKey,
          onGenerateRoute: AppRoute.onGenerateRoute,
          initialRoute: initialRoute,
        );
    }
  }

  String get label {
    switch (this) {
      case Screens.feed:
        return "Feed";
      case Screens.interests:
        return "Interests";
      case Screens.chat:
        return "Chat";
      case Screens.profile:
        return "Profile";
    }
  }

  void popAll() {
    Navigator.popUntil(context, (route) => route.settings.name == initialRoute);
  }
}
