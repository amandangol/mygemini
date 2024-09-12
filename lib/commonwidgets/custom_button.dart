import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Widget? child;
  final VoidCallback? onPressed;
  final IconData? iconData;
  final double? iconSize;
  final Color? iconColor;

  CustomButton({
    super.key,
    this.child,
    this.onPressed,
    this.iconData,
    this.iconSize = 24.0,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3498DB).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child ?? const SizedBox.shrink(),
              if (iconData != null) ...[
                const SizedBox(
                  width: 8,
                ),
                Icon(
                  iconData,
                  size: iconSize,
                  color: iconColor,
                )
              ]
            ],
          )),
    );
  }
}
