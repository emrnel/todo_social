import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? profilePicture;
  final String username;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.profilePicture,
    required this.username,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (profilePicture == null || profilePicture!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.teal,
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Check for base64 data URI
    if (profilePicture!.startsWith('data:image')) {
      try {
        final base64Data = profilePicture!.split(',').last;
        final bytes = base64Decode(base64Data);
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (e) {
        return _buildFallback();
      }
    }

    // Regular URL
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(profilePicture!),
      onBackgroundImageError: (_, __) {},
    );
  }

  Widget _buildFallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.teal,
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
