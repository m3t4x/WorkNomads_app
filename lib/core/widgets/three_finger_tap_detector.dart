import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ThreeFingerTapDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onTripleTap;
  final Duration window;

  const ThreeFingerTapDetector({
    super.key,
    required this.child,
    required this.onTripleTap,
    this.window = const Duration(milliseconds: 250),
  });

  @override
  State<ThreeFingerTapDetector> createState() => _ThreeFingerTapDetectorState();
}

class _ThreeFingerTapDetectorState extends State<ThreeFingerTapDetector> {
  final Set<int> _activePointers = <int>{};
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.window, _reset);
  }

  void _reset() {
    _activePointers.clear();
  }

  void _maybeTrigger() {
    if (_activePointers.length >= 3) {
      _timer?.cancel();
      _reset();
      widget.onTripleTap();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (PointerDownEvent event) {
        // Track unique pointers
        _activePointers.add(event.pointer);
        if (_activePointers.length == 1) {
          _startTimer();
        }
        _maybeTrigger();
      },
      onPointerUp: (PointerUpEvent event) {
        _activePointers.remove(event.pointer);
      },
      onPointerCancel: (PointerCancelEvent event) {
        _activePointers.remove(event.pointer);
      },
      child: widget.child,
    );
  }
}
