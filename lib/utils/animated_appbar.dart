import 'package:flutter/material.dart';

class AnimatedAppBarTitle extends StatefulWidget {
  final String text;
  const AnimatedAppBarTitle({super.key, required this.text});

  @override
  State<AnimatedAppBarTitle> createState() => _AnimatedAppBarTitleState();
}

class _AnimatedAppBarTitleState extends State<AnimatedAppBarTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.blueAccent,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) {
        return Text(
          widget.text,
          style: TextStyle(
            color: _colorAnimation.value,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        );
      },
    );
  }
}
