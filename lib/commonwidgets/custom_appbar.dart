import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onResetPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onBackPressed,
    required this.onResetPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: const TextStyle(
              color: Color(0xFF2C3E50), fontWeight: FontWeight.w300)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50)),
        onPressed: onBackPressed,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.refresh_outlined, color: Color(0xFF3498DB)),
              onPressed: onResetPressed,
              tooltip: 'Reset all fields',
              splashColor: const Color(0xFF3498DB).withOpacity(0.3),
              highlightColor: const Color(0xFF3498DB).withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
