import 'package:flutter/material.dart';
import 'onboarding_info.dart';

class OnboardingItems {
  List<OnboardingInfo> items = [
    OnboardingInfo(
      title: "Welcome to TecTags",
      descriptions: "Experience real-time object detection at your fingertips.",
      image: "assets/images/tectags_logo_nobg.png",
      backgroundColor: Colors.blueAccent.shade400,
    ),
    OnboardingInfo(
      title: "Real-Time Detection",
      descriptions: "Point your camera at any object to receive instant identification and details.",
      image: "assets/images/tectags_logo_nobg.png",
      backgroundColor: Colors.blueAccent.shade400,
    ),
    OnboardingInfo(
      title: "Seamless Integration",
      descriptions: "Effortlessly integrate TecTags with your existing workflows and applications.",
      image: "assets/images/tectags_logo_nobg.png",
      backgroundColor: Colors.blueAccent.shade400,
    ),
    OnboardingInfo(
      title: "Unlock the Experience",
      descriptions: "Grant camera access to begin your object detection journey with TecTags.",
      image: "assets/images/tectags_logo_nobg.png",
      backgroundColor: Colors.blueAccent.shade400,
    ),
  ];
}
