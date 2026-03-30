import 'package:flutter/material.dart';

import 'package:get/get.dart'
    hide GetNumUtils, ContextExtensionsNum, NumDurationExtensions;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import 'main_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 3500), () {
      Get.off(() => const MainWrapper(), transition: Transition.fadeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF020024),
              Color(0xFF090979),
              Color(0xFF003545),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.05),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.swap_horizontal_circle,
                        size: 100,
                        color: Colors.green,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.08, 1.08),
                      duration: 1.seconds,
                    )
                    .shimmer(
                      delay: 1.seconds,
                      duration: 2.seconds,
                      color: Colors.white24,
                    ),

                const SizedBox(height: 30),

                const Text(
                      "HandExchange",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0)
                    .then()
                    .shimmer(duration: 2.seconds, color: Colors.greenAccent),

                const SizedBox(height: 8),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMottoText("Buy • "),
                    _buildMottoText("Sell • "),
                    _buildMottoText("Save"),
                  ],
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),

            Positioned(
              bottom: 50,
              child: Column(
                children: [
                  Lottie.network(
                    'https://raw.githubusercontent.com/NotCapable1o/lottie/main/HomeScreen/sliderImageLoader.json',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "VERSION 1.0.0",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ).animate().fadeIn(delay: 1500.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMottoText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w500,
        letterSpacing: 1.1,
      ),
    );
  }
}
