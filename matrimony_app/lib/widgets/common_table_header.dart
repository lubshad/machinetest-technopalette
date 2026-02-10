import 'package:flutter/material.dart';

class TableColumnHeader {
  final String label;
  final int flex;
  final double? width;
  final Alignment alignment;

  const TableColumnHeader({
    required this.label,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

/// A generic responsive table header widget.
class CommonTableHeader extends StatelessWidget {
  final List<TableColumnHeader> columns;
  final bool? allSelected;
  final ValueChanged<bool?>? onSelectAll;
  final bool showCheckbox;

  const CommonTableHeader({
    super.key,
    required this.columns,
    this.allSelected,
    this.onSelectAll,
    this.showCheckbox = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showCheckbox)
            SizedBox(
              width: 40,
              child: Checkbox(
                value: allSelected ?? false,
                onChanged: onSelectAll,
                activeColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ...columns.map((col) {
            Widget child = Container(
              alignment: col.alignment,
              child: Text(
                col.label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );

            if (col.width != null) {
              return SizedBox(width: col.width, child: child);
            }
            return Expanded(flex: col.flex, child: child);
          }),
        ],
      ),
    );
  }
}
