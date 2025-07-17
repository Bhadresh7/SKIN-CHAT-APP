import 'package:flutter/material.dart';

class ToastHelper {
  static OverlayEntry? _currentOverlay;

  static void showSuccessToast({
    required BuildContext context,
    required String message,
  }) {
    _showOverlayToast(
      context: context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  static void showErrorToast({
    required BuildContext context,
    required String message,
  }) {
    _showOverlayToast(
      context: context,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  static void _showOverlayToast({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
  }) {
    // Remove existing overlay if visible
    _currentOverlay?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedTopToast(
        message: message,
        backgroundColor: backgroundColor,
        onClose: () {
          overlayEntry.remove();
          _currentOverlay = null;
        },
      ),
    );

    overlay.insert(overlayEntry);
    _currentOverlay = overlayEntry;
  }
}

class _AnimatedTopToast extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onClose;

  const _AnimatedTopToast({
    required this.message,
    required this.backgroundColor,
    required this.onClose,
  });

  @override
  State<_AnimatedTopToast> createState() => _AnimatedTopToastState();
}

class _AnimatedTopToastState extends State<_AnimatedTopToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _controller.reverse().then((_) => widget.onClose());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _controller.reverse().then((_) => widget.onClose());
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
