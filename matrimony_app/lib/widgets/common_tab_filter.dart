import 'package:flutter/material.dart';

class FilterTabItem {
  final String label;
  final int count;
  final String id;

  const FilterTabItem({
    required this.label,
    required this.count,
    required this.id,
  });
}

/// A generic widget that displays filter tabs.
class CommonTabFilter extends StatelessWidget {
  final List<FilterTabItem> tabs;
  final String selectedTabId;
  final ValueChanged<String> onTabChanged;

  const CommonTabFilter({
    super.key,
    required this.tabs,
    required this.selectedTabId,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isSelected = tab.id == selectedTabId;

            return InkWell(
              onTap: () => onTabChanged(tab.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF0D9488)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : Colors.grey[600],
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "(${tab.count})",
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
