import 'package:flutter/material.dart';

class AppColors {
  // static const Color primary = Color((0xFF7265E3));
  static const Color primary = Color((0xFFC8344A));
  static const Color secondary = Colors.white70;
}

class AppButtonStyles {
static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

class AppTextStyles {
  static const TextStyle primaryButton = TextStyle(
    fontSize: 16,
    color: Colors.white,
    fontWeight: FontWeight.w600, // optional
  );
  static const TextStyle secondryButton = TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w600, // optional
  );
}
//Media Solutions