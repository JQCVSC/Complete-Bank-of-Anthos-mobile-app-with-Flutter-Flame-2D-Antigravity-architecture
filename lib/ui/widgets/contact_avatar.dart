import 'package:flutter/material.dart';
import '../../data/models/contact.dart';

class ContactAvatar extends StatelessWidget {
  final Contact contact;
  final double size;
  final VoidCallback? onTap;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.size = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Generate deterministic pleasing gradient based on contact label hash
    final hash = contact.label.hashCode.abs();
    final colorsList = [
      [const Color(0xFF1A73E8), const Color(0xFF00C49F)],
      [const Color(0xFF673AB7), const Color(0xFF512DA8)],
      [const Color(0xFF00897B), const Color(0xFF004D40)],
      [const Color(0xFFE65100), const Color(0xFFF57C00)],
      [const Color(0xFF0F2027), const Color(0xFF2C5364)],
    ];
    final selectedColors = colorsList[hash % colorsList.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: selectedColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: selectedColors[0].withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          contact.initials,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
