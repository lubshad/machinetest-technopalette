import 'package:flutter/material.dart';
import '../../exporter.dart';
import '../profile_screen/profile_details_model.dart';
import 'filter_controller.dart';

class FilterScreen extends StatefulWidget {
  static const String path = "/filter";

  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = FilterController.i;
    _cityController.text = controller.city ?? '';
    _stateController.text = controller.state ?? '';
    _countryController.text = controller.country ?? '';
    _searchController.text = controller.search ?? '';
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FilterController.i,
      builder: (context, _) {
        final controller = FilterController.i;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Filters"),
            actions: [
              TextButton(
                onPressed: () {
                  controller.clearFilters();
                  _cityController.clear();
                  _stateController.clear();
                  _countryController.clear();
                  _searchController.clear();
                },
                child: const Text("Reset"),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Search"),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search by name, email, or bio...",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: controller.setSearch,
                ),
                _buildSectionTitle("Family Type"),
                Row(
                  children: FamilyType.values.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(right: padding),
                      child: ChoiceChip(
                        label: Text(f.label),
                        selected: controller.familyType == f,
                        onSelected: (selected) {
                          controller.setFamilyType(selected ? f : null);
                        },
                      ),
                    );
                  }).toList(),
                ),
                gapLarge,
                _buildSectionTitle("Family Status"),
                Wrap(
                  spacing: padding,
                  children: FamilyStatus.values.map((f) {
                    return ChoiceChip(
                      label: Text(f.label),
                      selected: controller.familyStatus == f,
                      onSelected: (selected) {
                        controller.setFamilyStatus(selected ? f : null);
                      },
                    );
                  }).toList(),
                ),
                gapLarge,
                _buildSectionTitle("Height (cm)"),
                RangeSlider(
                  values: controller.heightRange ?? const RangeValues(140, 200),
                  min: 100,
                  max: 250,
                  divisions: 150,
                  labels: RangeLabels(
                    "${(controller.heightRange?.start ?? 140).round()} cm",
                    "${(controller.heightRange?.end ?? 200).round()} cm",
                  ),
                  onChanged: controller.setHeightRange,
                ),
                gapLarge,
                _buildSectionTitle("Weight (kg)"),
                RangeSlider(
                  values: controller.weightRange ?? const RangeValues(40, 100),
                  min: 30,
                  max: 150,
                  divisions: 120,
                  labels: RangeLabels(
                    "${(controller.weightRange?.start ?? 40).round()} kg",
                    "${(controller.weightRange?.end ?? 100).round()} kg",
                  ),
                  onChanged: controller.setWeightRange,
                ),
                gapLarge,
                _buildSectionTitle("Siblings"),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if ((controller.siblings ?? 0) > 0) {
                          controller.setSiblings(
                            (controller.siblings ?? 0) - 1,
                          );
                        }
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      "${controller.siblings ?? 0}",
                      style: context.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        controller.setSiblings((controller.siblings ?? 0) + 1);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    if (controller.siblings != null)
                      TextButton(
                        onPressed: () => controller.setSiblings(null),
                        child: const Text("Clear"),
                      ),
                  ],
                ),
                gapLarge,
                _buildSectionTitle("Location"),
                TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(hintText: "City"),
                  onChanged: controller.setCity,
                ),
                gap,
                TextField(
                  controller: _stateController,
                  decoration: const InputDecoration(hintText: "State"),
                  onChanged: controller.setStateStr,
                ),
                gap,
                TextField(
                  controller: _countryController,
                  decoration: const InputDecoration(hintText: "Country"),
                  onChanged: controller.setCountry,
                ),
                gapXXL,
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(paddingLarge),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Apply Filters"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: padding),
      child: Text(
        title,
        style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
