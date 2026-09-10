import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum ButtonVariant { primary, outline, ghost, destructive }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case ButtonVariant.primary:
        return ShadButton(
          onPressed: onPressed,
          leading: icon != null ? Icon(icon, size: 18) : null,
          child: Text(label),
        );
      case ButtonVariant.outline:
        return ShadButton.outline(
          onPressed: onPressed,
          leading: icon != null ? Icon(icon, size: 18) : null,
          child: Text(label),
        );
      case ButtonVariant.ghost:
        return ShadButton.ghost(
          onPressed: onPressed,
          leading: icon != null ? Icon(icon, size: 18) : null,
          child: Text(label),
        );
      case ButtonVariant.destructive:
        return ShadButton.destructive(
          onPressed: onPressed,
          leading: icon != null ? Icon(icon, size: 18) : null,
          child: Text(label),
        );
    }
  }
}
