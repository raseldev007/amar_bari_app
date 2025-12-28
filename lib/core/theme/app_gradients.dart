import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBg = LinearGradient(
    colors: [Color(0xFFffffff), Color(0xFFf8f9fa)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient paid = LinearGradient(
    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient due = LinearGradient(
    colors: [Color(0xFFEB3349), Color(0xFFF45C43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
