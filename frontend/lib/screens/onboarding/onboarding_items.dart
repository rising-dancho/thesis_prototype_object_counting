import 'package:flutter/material.dart';
import 'onboarding_info.dart';

class OnboardingItems {
  List<OnboardingInfo> items = [
    OnboardingInfo(
      title: "Welcome to TecTags",
      descriptions: "Experience cutting-edge real-time object detection at your fingertips.",
      // image: "assets/onboarding1.gif",
      backgroundColor: const Color.fromARGB(255, 11, 3, 121), // Set the desired background color
    ),
    OnboardingInfo(
      title: "Real-Time Detection",
      descriptions: "Point your camera at any object to receive instant identification and details.",
      // image: "assets/onboarding2.gif",
      backgroundColor: Colors.blueAccent, // Set the desired background color
    ),
    OnboardingInfo(
      title: "Seamless Integration",
      descriptions: "Effortlessly integrate TecTags with your existing workflows and applications.",
      // image: "assets/onboarding3.gif",
      backgroundColor: const Color.fromARGB(255, 17, 180, 102), // Set the desired background color
    ),
    OnboardingInfo(
      title: "Get Started",
      descriptions: "Grant camera access to begin your object detection journey with TecTags.",
      // image: "assets/onboarding4.gif",
      backgroundColor: const Color.fromARGB(255, 212, 128, 18), // Set the desired background color
    ),
  ];
}
