import 'package:flutter/material.dart';

/// A generic responsive list row widget.
class CommonListRow extends StatelessWidget {
  final List<Widget> children;

  final bool? isSelected;
  final ValueChanged<bool?>? onSelected;
  final bool showCheckbox;

  final VoidCallback? onTap;

  const CommonListRow({
    super.key,
    required this.children,
    this.isSelected,
    this.onSelected,
    this.showCheckbox = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        child: Row(
          children: [
            if (showCheckbox)
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected ?? false,
                  onChanged: onSelected,
                  activeColor: const Color(0xFF0D9488),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}
