import 'package:flutter/material.dart';

/// A generic app bar widget for management screens (Vehicles, Users, etc.).
/// Displays a title, subtitle (e.g., count), search field, and refresh button.
class ManagementAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextEditingController? searchController;
  final VoidCallback? onSearch;
  final VoidCallback onRefresh;
  final VoidCallback? onAdd;
  final String addLabel;
  final String searchHint;
  final VoidCallback? onBack;
  final bool showSearch;

  const ManagementAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.searchController,
    this.onSearch,
    required this.onRefresh,
    this.searchHint = "Search...",
    this.onAdd,
    this.addLabel = "Create",
    this.onBack,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (onBack != null) ...[
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back, color: Colors.grey[700], size: 20),
              tooltip: "Back",
            ),
          ),
        ],
        // Left side - Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1D1F),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        // Right side - Search field and refresh button
        Row(
          children: [
            // Search Field
            if (showSearch) ...[
              Container(
                width: 280,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: searchController,
                  onSubmitted: (_) => onSearch?.call(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1D1F),
                  ),
                  decoration: InputDecoration(
                    hintText: searchHint,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            // Refresh Button
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh, color: Colors.grey[700], size: 20),
                tooltip: "Refresh",
              ),
            ),
            if (onAdd != null) ...[
              const SizedBox(width: 12),
              // Add Button
              InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 20),
                      if (addLabel.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          addLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
