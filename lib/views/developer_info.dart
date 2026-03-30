import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeveloperInfo extends StatelessWidget {
  const DeveloperInfo({super.key});

  static const String loaderUrl =
      'https://raw.githubusercontent.com/NotCapable1o/lottie/refs/heads/Developer/Developer/flutterDeveloper.json';
  static const String educationLogo =
      'https://raw.githubusercontent.com/NotCapable1o/lottie/refs/heads/Developer/Developer/Educatin.json';
  static const String imgLoader =
      'https://raw.githubusercontent.com/NotCapable1o/lottie/main/HomeScreen/sliderImageLoader.json';
  static const String successTick =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Tick%20Market.json";

  static const String princeImg =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/refs/heads/Assets/Project%20Assets/12105007.jpg";
  static const String shithiImg =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/refs/heads/Assets/Project%20Assets/12105009.jpg";
  static const String ramjanImg =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/refs/heads/Assets/Project%20Assets/12005034.jpg";

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F2027), const Color(0xFF2C5364)]
                : [const Color(0xFFFDFCFB), const Color(0xFFE2D1C3)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 60),

              _buildHeader(isDark),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildAnimatedGradientSectionTitle("Project Lead", isDark),
                    _buildLeadCard(context, isDark),

                    const SizedBox(height: 25),
                    _buildAnimatedGradientSectionTitle(
                      "Development Team",
                      isDark,
                    ),
                    _buildTeamGrid(context, isDark),

                    const SizedBox(height: 25),
                    _buildAnimatedGradientSectionTitle(
                      "Technology Stack",
                      isDark,
                    ),
                    _buildTechStack(isDark),

                    const SizedBox(height: 30),
                    Lottie.network(educationLogo, height: 100, repeat: true),
                    Text(
                      "Computer Science and Engineering",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                      ),
                    ).animate().fadeIn(delay: const Duration(seconds: 1)),

                    Text(
                      "Begum Rokeya University, Rangpur",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.blueGrey,
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    const String devLoaderUrl =
        "https://raw.githubusercontent.com/NotCapable1o/lottie/main/DeveloperInfo/developerInfoFlutterLoader.json";

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 600,
              child: Lottie.network(devLoaderUrl, fit: BoxFit.contain),
            ),

            Lottie.network(
              loaderUrl,
              height: 300,
              width: 600,
              fit: BoxFit.contain,

              frameRate: FrameRate.max,
            ),
          ],
        ),

        Text(
          "HandExchange",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.blueAccent.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ).animate().shimmer(duration: const Duration(seconds: 2)),

        Text(
              "buy • sell • save",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.orangeAccent : Colors.deepOrange,
                letterSpacing: 1.2,
              ),
            )
            .animate()
            .fadeIn(delay: const Duration(milliseconds: 500))
            .slideY(begin: 0.5),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAnimatedGradientSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child:
            ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? [
                            Colors.blueAccent,
                            Colors.cyanAccent,
                            Colors.purpleAccent,
                          ]
                        : [
                            Colors.blue.shade800,
                            Colors.purple.shade700,
                            Colors.red.shade400,
                          ],
                  ).createShader(bounds),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .shimmer(
                  duration: const Duration(seconds: 3),
                  color: Colors.white24,
                ),
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, bool isDark) {
    return _imageInteractionWrapper(
      url: princeImg,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.indigo.shade700],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _circularAvatar(princeImg, 40),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Md. An Nahian Prince",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "ID: 12105007",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 30),
            _actionTile(
              Icons.email,
              "prince.12105007@student.brur.ac.bd",
              "Email",
            ),
            const SizedBox(height: 10),
            _actionTile(Icons.phone, "01601942144", "Call"),
          ],
        ),
      ),
    ).animate().slideX(begin: -0.2).fadeIn();
  }

  Widget _buildTeamGrid(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _teamMemberSmall(
            context,
            "Shithi Rani Roy",
            "12105009",
            shithiImg,
            isDark,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _teamMemberSmall(
            context,
            "Ramjan Hossain",
            "12005034",
            ramjanImg,
            isDark,
          ),
        ),
      ],
    ).animate().slideY(begin: 0.2).fadeIn();
  }

  Widget _teamMemberSmall(
    BuildContext context,
    String name,
    String id,
    String url,
    bool isDark,
  ) {
    return _imageInteractionWrapper(
      url: url,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
          boxShadow: [
            if (!isDark)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            _circularAvatar(url, 35),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              "ID: $id",
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularAvatar(String url, double radius) {
    return CircleAvatar(
      radius: radius + 2,
      backgroundColor: Colors.blueAccent,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Lottie.network(imgLoader, width: 40);
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.person),
          ),
        ),
      ),
    );
  }

  Widget _actionTile(IconData icon, String value, String type) {
    return InkWell(
      onTap: () {
        if (type == "Call") {
          _makeCall(value);
        } else {
          _sendEmail(value);
        }
      },
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        Fluttertoast.showToast(msg: "$type Copied!");
        HapticFeedback.lightImpact();
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStack(bool isDark) {
    final techs = [
      {"name": "Dart", "color": Colors.blue},
      {"name": "Flutter", "color": Colors.cyan},
      {"name": "GetX", "color": Colors.purple},
      {"name": "Supabase", "color": Colors.yellow},
      {"name": "Firebase", "color": Colors.orange},
      {"name": "Lottie", "color": Colors.greenAccent},
      {"name": "Dio", "color": Colors.redAccent},
      {"name": "Gal", "color": Colors.blueGrey},
      {"name": "HTTP", "color": Colors.pinkAccent},
      {"name": "Flutter Map", "color": Colors.cyanAccent},
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: techs
          .map(
            (t) =>
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (t['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: (t['color'] as Color).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        t['name'] as String,
                        style: TextStyle(
                          color: isDark
                              ? (t['color'] as Color).withOpacity(0.9)
                              : (t['color'] as Color).withOpacity(1.0),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      delay: const Duration(seconds: 2),
                      duration: const Duration(seconds: 2),
                    ),
          )
          .toList(),
    );
  }

  Widget _imageInteractionWrapper({
    required String url,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => _FullScreenImage(url: url)),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showSaveDialog(url);
      },
      child: child,
    );
  }

  void _showSaveDialog(String url) {
    Get.defaultDialog(
      title: "Save Photo",
      middleText: "Save this developer's photo to your gallery?",
      textCancel: "Cancel",
      textConfirm: "Save",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blueAccent,
      onConfirm: () {
        Get.back();
        _saveImage(url);
      },
    );
  }

  Future<void> _saveImage(String url) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final access = await Gal.requestAccess();
        if (!access) {
          Fluttertoast.showToast(msg: "Permission denied");
          return;
        }
      }
      Fluttertoast.showToast(msg: "Downloading...");
      var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      await Gal.putImageBytes(
        Uint8List.fromList(response.data),
        name: "dev_${DateTime.now().millisecondsSinceEpoch}",
      );
      Fluttertoast.showToast(msg: "Saved to Gallery!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving image");
    }
  }

  void _makeCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(msg: "Could not launch dialer");
    }
  }

  void _sendEmail(String email) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(msg: "Could not launch email app");
    }
  }
}

class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: GestureDetector(
          onLongPress: () => _handleLongPressSave(context, url),
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleLongPressSave(BuildContext context, String url) {
    HapticFeedback.mediumImpact();
    Get.defaultDialog(
      title: "Save Image",
      middleText: "Would you like to save this image to your gallery?",
      textCancel: "Cancel",
      textConfirm: "Save",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        _saveImageDirectly(url);
      },
    );
  }

  Future<void> _saveImageDirectly(String url) async {
    try {
      var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      await Gal.putImageBytes(Uint8List.fromList(response.data));
      Fluttertoast.showToast(msg: "Saved Successfully!");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to save image");
    }
  }
}
