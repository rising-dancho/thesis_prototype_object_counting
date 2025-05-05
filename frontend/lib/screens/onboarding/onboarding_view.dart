import 'package:flutter/material.dart';
import 'package:tectags/screens/onboarding/onboarding_items.dart';
import 'package:tectags/screens/navigation/navigation_menu.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tectags/services/shared_prefs_service.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboardingItems();
  final pageController = PageController();

  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: isLastPage
          ? null // No bottomSheet on the last page
          : Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  TextButton(
                    onPressed: () =>
                        pageController.jumpToPage(controller.items.length - 1),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 22, 165, 221),
                      textStyle: const TextStyle(fontSize: 17),
                    ),
                    child: const Text("Skip"),
                  ),

                  // Indicator
                  SmoothPageIndicator(
                    controller: pageController,
                    count: controller.items.length,
                    onDotClicked: (index) => pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                    ),
                    effect: const WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      activeDotColor: Color.fromARGB(255, 33, 51, 155),
                    ),
                  ),
                  // Next Button
                  TextButton(
                    onPressed: () => pageController.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 22, 165, 221),
                      textStyle: const TextStyle(fontSize: 17),
                    ),
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
      body: PageView.builder(
        onPageChanged: (index) =>
            setState(() => isLastPage = controller.items.length - 1 == index),
        itemCount: controller.items.length,
        controller: pageController,
        itemBuilder: (context, index) {
          final onboardingItem = controller.items[index];
          return Container(
            decoration: BoxDecoration(
              color: onboardingItem.backgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Image.asset(onboardingItem.image),
                const SizedBox(height: 50),
                Text(
                  onboardingItem.title,
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  onboardingItem.descriptions,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 238, 238, 238),
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isLastPage) ...[
                  const Spacer(),
                  getStarted(),
                  const SizedBox(height: 20), // Space below the button
                ],
              ],
            ),
          );
        },
      ),
    );
  }

// Get Started Button
  Widget getStarted() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 55,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 22, 165, 221),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            // final prefs = await SharedPreferences.getInstance();
            // prefs.setBool("onboarding", true);
            await SharedPrefsService.setHasSeenOnboarding(true);

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const NavigationMenu()),
            );
          },
          child: const Text(
            "Get started",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
