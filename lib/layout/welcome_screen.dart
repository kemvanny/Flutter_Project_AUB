import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project_aub/constants/app_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int sliderIndex = 0;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB7B2E8),
              Color(0xFFE8E7F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// Illustration
              // SizedBox(
              //   height: size.height * 0.45,
              //   child: Image.asset(
              //     "assets/images/img_logo.png",
              //     fit: BoxFit.contain,
              //   ),
              // ),
              _buildSlider(context),
              const SizedBox(height: 20),

              /// Page Indicator
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     _dot(false),
              //     _dot(false),
              //     _dot(true),
              //   ],
              // ),
              const SizedBox(height: 30),

              /// App Name
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 14),

              /// Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "PlanMe helps you create smart to-do lists, set reminders, and track your daily progress — all in one beautifully designed app.\n\nPlan smarter. Do better. Live balanced.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff393844),
                    height: 1.6,
                  ),
                ),
              ),
              const Spacer(),

              /// Get Start Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to next screen
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB9B5F0),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Get start",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Indicator Dot
  // Widget _dot(bool isActive) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     margin: const EdgeInsets.symmetric(horizontal: 6),
  //     width: isActive ? 10 : 8,
  //     height: isActive ? 10 : 8,
  //     decoration: BoxDecoration(
  //       color: isActive ? Colors.indigo : Colors.grey.shade400,
  //       shape: BoxShape.circle,
  //     ),
  //   );
  // }

  //Slider show
  Widget _buildSlider(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: height * 0.40, // 🔥 FULL HEIGHT CONTROL
            viewportFraction: 0.99,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() {
                sliderIndex = index;
              });
            },
          ),
          items: [
            AppImage.slider1,
            AppImage.slider2,
            AppImage.slider3,
          ].map((img) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
        AnimatedSmoothIndicator(
          activeIndex: sliderIndex,
          count: 3,
          effect: const JumpingDotEffect(
            dotWidth: 10,
            dotHeight: 10,
            activeDotColor: Color(0xFF7C7AED),
            dotColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}
