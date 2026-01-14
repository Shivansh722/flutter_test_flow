import 'package:flutter/material.dart';

class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final bool enableOCR;
  final VoidCallback? onOCRTap;
  final FocusNode? focusNode;
  final bool requestFocus;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.enableOCR = false,
    this.onOCRTap,
    this.focusNode,
    this.requestFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    if (requestFocus && focusNode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final fn = focusNode;
          if (fn != null) {
            fn.requestFocus();
          }
        } catch (e, st) {
          debugPrint('ModernTextField focus request failed: $e\n$st');
        }
      });
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[700]),
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color.fromARGB(255, 164, 164, 219))
              : null,
          suffixIcon: enableOCR
              ? IconButton(
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color.fromARGB(255, 164, 164, 219),
                  ),
                  onPressed: onOCRTap,
                  tooltip: 'Scan text with OCR',
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
