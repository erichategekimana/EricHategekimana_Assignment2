import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'In Progress':
        bgColor = const Color(0xFFE8EAFD);
        textColor = const Color(0xFF4A55D2);
        break;
      case 'Resolved':
        bgColor = const Color(0xFFE4F7ED);
        textColor = const Color(0xFF1F8B58);
        break;
      case 'Submitted':
      default:
        bgColor = const Color(0xFFFFF4DC);
        textColor = const Color(0xFFC57B14);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}