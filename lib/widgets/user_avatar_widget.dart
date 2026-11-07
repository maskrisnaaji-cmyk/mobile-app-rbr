import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_session.dart';
import '../theme/colors.dart';
import '../views/profil_view.dart';

/// Reusable dynamic user avatar widget synced with UserSession state management
class UserAvatarWidget extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;
  final double? fontSize;
  final String? tooltip;

  const UserAvatarWidget({
    super.key,
    this.radius = 14,
    this.onTap,
    this.showBorder = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.fontSize,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserSession.instance,
      builder: (context, _) {
        final initials = UserSession.instance.initials;
        final name = UserSession.instance.name;

        Widget avatar = Container(
          padding: showBorder ? const EdgeInsets.all(2) : EdgeInsets.zero,
          decoration: showBorder
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor ?? AppColors.maroon,
                    width: borderWidth,
                  ),
                )
              : null,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor ?? AppColors.maroon.withValues(alpha: 0.12),
            child: Text(
              initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: fontSize ?? (radius * 0.72).clamp(8.0, 18.0),
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.maroon,
              ),
            ),
          ),
        );

        return Tooltip(
          message: tooltip ?? name,
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap!();
              } else {
                // Navigate to ProfilView with bottom navigation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilView(showBottomNav: true),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(radius + 4),
            child: avatar,
          ),
        );
      },
    );
  }
}

