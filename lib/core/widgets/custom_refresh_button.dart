import 'package:flutter/material.dart';

class CustomRefreshButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  final Color? iconColor;

  const CustomRefreshButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Sayfayı Yenile',
    this.size = 48.0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Primary orange color
    final Color actualIconColor = iconColor ?? const Color(0xFFF57C00);
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: onPressed,
          hoverColor: actualIconColor.withAlpha(20),
          highlightColor: actualIconColor.withAlpha(40),
          splashColor: actualIconColor.withAlpha(40),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Icon(
                Icons.refresh_rounded, // Görseldeki gibi oval ve şık yenileme ikonu
                color: actualIconColor,
                size: size * 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
