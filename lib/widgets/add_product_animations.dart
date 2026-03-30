import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AddProductAnimations {
  static const String uploadUrl =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/IMAGE.json.json";
  static const String cancel =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Cancel.json";
  static const String deleteBin =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Delete%20Bin.json";
  static const String loadingBarProgress =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Loading%20Bar%20%20Progress%20Bar.json";
  static const String tickMarket =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Tick%20Market.json";
  static const String empty =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/empty.json";
  static const String loading =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/loading.json";
  static const String mapPinUrl =
      "https://lottie.host/9360565b-8086-444e-8686-e260905e323b/7l0QW0Y8Wk.json";
  static const String donationUrl =
      "https://lottie.host/8708527a-5264-4689-b883-9b87207c4852/4F9WzY0z9W.json";
  static const String formHeaderUrl =
      "https://lottie.host/f886367c-674e-4f2a-9f5b-9b77207c4852/5G0XzY0z0X.json";

  static Widget uploadPlaceholder() => Lottie.network(
    uploadUrl,
    repeat: true,
    fit: BoxFit.fill,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
  );

  static Widget mapPin({double size = 35}) => Lottie.network(
    mapPinUrl,
    width: size,
    height: size,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.location_on, size: 24, color: Colors.red),
  );

  static Widget donationAnim({double size = 40}) => Lottie.network(
    donationUrl,
    width: size,
    height: size,
    errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.card_giftcard, size: 24, color: Colors.green),
  );

  static Widget headerAnim({double height = 100}) => Center(
    child: Lottie.network(
      formHeaderUrl,
      height: height,
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    ),
  );
}
