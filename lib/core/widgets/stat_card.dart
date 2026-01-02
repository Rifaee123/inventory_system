import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? percentageChange;
  final bool isPositive;
  final IconData icon;
  final Color
  iconColor; // Usually just for the icon tint if needed, but we follow specific design
  final String? badgeText; // "Needs Attention", etc.
  final Color? badgeColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.percentageChange,
    this.isPositive = true,
    required this.icon,
    this.iconColor = const Color(0xFF4C4C9A),
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E7F3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1313EC).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4C4C9A),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 8),

          // Value and Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0D0D1B),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              if (percentageChange != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isPositive
                                ? const Color(0xFF078841)
                                : const Color(0xFFD32F2F))
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: isPositive
                            ? const Color(0xFF078841)
                            : const Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        percentageChange!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPositive
                              ? const Color(0xFF078841)
                              : const Color(0xFFD32F2F),
                        ),
                      ),
                    ],
                  ),
                ),
              if (badgeText != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? const Color(0xFFEAB308)).withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeColor ?? const Color(0xFFEAB308),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
