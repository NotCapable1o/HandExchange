import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedAssets {
  static const String refreshUrl =
      "https://assets10.lottiefiles.com/packages/lf20_usmfx6bp.json";

  static const String emptyUrl =
      "https://assets2.lottiefiles.com/packages/lf20_jtbfg2nb.json";

  static const String emptyListing =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/Profile/emptyListing.json";

  static const String logoutUrl =
      "https://raw.githubusercontent.com/NotCapable1o/lottie/main/logout.json";

  static const String guestUrl =
      "https://assets3.lottiefiles.com/packages/lf20_ktwnwv5m.json";

  static Widget refreshAnimation({double height = 110}) {
    return SizedBox(
      height: height,
      child: Lottie.network(refreshUrl, repeat: true, fit: BoxFit.contain),
    );
  }

  static Widget logoutIcon({double size = 32}) {
    return SizedBox(
      height: size,
      width: size,
      child: Lottie.network(logoutUrl, repeat: true),
    );
  }

  static Widget emptyListings() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          child: Lottie.network(emptyListing, repeat: true),
        ),
        const SizedBox(height: 16),
        const Text(
          "You haven't posted anything yet.",
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  static Widget guestAnimation({double height = 180}) {
    return SizedBox(
      height: height,
      child: Lottie.network(guestUrl, repeat: true),
    );
  }

  static Widget glowingAvatar({required Widget child}) {
    return _AnimatedGlow(child: child);
  }

  static Widget pageEntrance({required Widget child}) {
    return _PageEntrance(child: child);
  }

  static Widget animatedCounter({
    required int value,
    TextStyle? style,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, val, _) {
        return Text(
          val.toString(),
          style:
              style ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  static Widget animatedListItem({required Widget child, int delay = 0}) {
    return _AnimatedListItem(delay: delay, child: child);
  }

  static Widget tapEffect({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return _TapEffect(onTap: onTap, child: child);
  }
}

class _AnimatedGlow extends StatefulWidget {
  final Widget child;

  const _AnimatedGlow({required this.child});

  @override
  State<_AnimatedGlow> createState() => _AnimatedGlowState();
}

class _AnimatedGlowState extends State<_AnimatedGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.6),
                blurRadius: 20 + (_controller.value * 25),
                spreadRadius: 2,
              ),
            ],
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent, Colors.cyan],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _PageEntrance extends StatefulWidget {
  final Widget child;

  const _PageEntrance({required this.child});

  @override
  State<_PageEntrance> createState() => _PageEntranceState();
}

class _PageEntranceState extends State<_PageEntrance> {
  double opacity = 0;
  double offset = 40;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        opacity = 1;
        offset = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        transform: Matrix4.translationValues(0, offset, 0),
        child: widget.child,
      ),
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int delay;

  const _AnimatedListItem({required this.child, required this.delay});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem> {
  double opacity = 0;
  double offset = 30;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100 + widget.delay), () {
      setState(() {
        opacity = 1;
        offset = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        transform: Matrix4.translationValues(0, offset, 0),
        child: widget.child,
      ),
    );
  }
}

class _TapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapEffect({required this.child, required this.onTap});

  @override
  State<_TapEffect> createState() => _TapEffectState();
}

class _TapEffectState extends State<_TapEffect> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.96),
      onTapUp: (_) {
        setState(() => scale = 1);
        widget.onTap();
      },
      onTapCancel: () => setState(() => scale = 1),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
