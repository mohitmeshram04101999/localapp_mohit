import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardAndPointerListener extends StatefulWidget {
  final Widget child;
  final Function(bool) onCtrlPress;
  final Function(double) onZoom;
  final Function(bool) onScrollEvent;

  const KeyboardAndPointerListener({
    Key? key,
    required this.child,
    required this.onCtrlPress,
    required this.onZoom,
    required this.onScrollEvent,
  }) : super(key: key);

  @override
  _KeyboardAndPointerListenerState createState() =>
      _KeyboardAndPointerListenerState();
}

class _KeyboardAndPointerListenerState
    extends State<KeyboardAndPointerListener> {
  bool _isCtrlPressed = false;
  bool _isScrollEvent = false;
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent e) {
        if (e.logicalKey == LogicalKeyboardKey.controlLeft ||
            e.logicalKey == LogicalKeyboardKey.controlRight) {
          setState(() {
            _isCtrlPressed = e is KeyDownEvent;
            _isScrollEvent = e is KeyUpEvent;
          });
          widget.onCtrlPress(_isCtrlPressed);
          widget.onScrollEvent(_isScrollEvent);
        }
      },
      child: Listener(
        onPointerSignal: (PointerSignalEvent pointerSignal) {
          if (pointerSignal is PointerScrollEvent && _isCtrlPressed) {
            setState(() {
              _isScrollEvent = true;
              _scale += pointerSignal.scrollDelta.dy > 0 ? -0.1 : 0.1;
              _scale = _scale.clamp(0.5, 1000.0); // Limit zoom range
            });
            widget.onZoom(_scale);
            // widget.onScrollEvent(_isScrollEvent);
          }
        },
        child: widget.child,
      ),
    );
  }
}
