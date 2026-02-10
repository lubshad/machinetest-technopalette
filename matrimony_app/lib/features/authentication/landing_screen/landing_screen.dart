import 'package:flutter/material.dart';
import 'package:matrimony_app/features/authentication/social_authentication/social_authentication_screen.dart';
import '../../../core/app_route.dart';
import '../../../exporter.dart';
import 'widgets/landing_screen_item.dart';

class LandingPage extends StatefulWidget {
  static const String path = "/landing-page";

  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  void _goToNextPage() {
    if (_currentPage < children.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Color> get colors => [
    Color(0xFFF9F9F9),
    Color(0xFFF9F9F9),
    Color(0xFFF9F9F9),
  ];

  List<Widget> children = <Widget>[
    LandingScreenItem(
      description:
          "We want our members to find meaningful and authentic relationships that ignite confidence and joy.",
      title: "We exist to bring people closer to love.",
      image: Assets.pngs.landing1.keyName,
    ),
    LandingScreenItem(
      description:
          "Connect mean you can stop typing and start talking. Come solo or bring a friend—and leave with a new connection.",
      title: "Start the chat in person",
      image: Assets.pngs.landing2.keyName,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: animationDuration,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: children,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingXL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(children.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(
                        horizontal: paddingSmall,
                      ),
                      height: 3.h,
                      width: _currentPage == index ? 28.h : 16.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.black
                            : Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    );
                  }),
                ),
              ),
              Container(
                height: 170.h,
                width: ScreenUtil().screenWidth,
                padding: EdgeInsets.symmetric(horizontal: paddingXL),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 57.h,
                    width: 57.h,
                    child: IconButton.filled(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(primaryColor),
                      ),
                      onPressed: () {
                        if (_currentPage == children.length - 1) {
                          navigate(context, SocialAuthenticationScreen.path);
                        } else {
                          _goToNextPage();
                        }
                      },
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
