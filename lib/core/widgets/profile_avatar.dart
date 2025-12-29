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
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    // If no profile picture, show initial
    if (profilePicture == null || profilePicture!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.teal,
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: radius * 0.8,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Check if it's a base64 data URI
    if (profilePicture!.startsWith('data:image')) {
      try {
        // Extract base64 data after the comma
        final base64Data = profilePicture!.split(',').last;
        final bytes = base64Decode(base64Data);

        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(bytes),
          backgroundColor: Colors.teal,
        );
      } catch (e) {
        print('Error decoding base64 profile picture: $e');
        // Fallback to initial
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.teal,
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: radius * 0.8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }

    // It's a regular URL
    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(profilePicture!),
      backgroundColor: Colors.teal,
      onBackgroundImageError: (_, __) {
        print('Error loading profile picture from URL: $profilePicture');
      },
    );
  }
}
