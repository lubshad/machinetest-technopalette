import 'package:flutter/material.dart';
import '../profile_screen/profile_details_model.dart';

class FilterController extends ChangeNotifier {
  static FilterController get i => _instance;
  static final FilterController _instance = FilterController._private();

  FilterController._private();

  String? city;
  String? state;
  String? country;
  FamilyType? familyType;
  FamilyStatus? familyStatus;
  RangeValues? heightRange;
  RangeValues? weightRange;
  int? siblings;
  String? search;

  bool get hasFilters => getFilters().isNotEmpty;

  void setCity(String? value) {
    city = value;
    notifyListeners();
  }

  void setStateStr(String? value) {
    state = value;
    notifyListeners();
  }

  void setCountry(String? value) {
    country = value;
    notifyListeners();
  }

  void setFamilyType(FamilyType? value) {
    familyType = value;
    notifyListeners();
  }

  void setFamilyStatus(FamilyStatus? value) {
    familyStatus = value;
    notifyListeners();
  }

  void setHeightRange(RangeValues? value) {
    heightRange = value;
    notifyListeners();
  }

  void setWeightRange(RangeValues? value) {
    weightRange = value;
    notifyListeners();
  }

  void setSiblings(int? value) {
    siblings = value;
    notifyListeners();
  }

  void setSearch(String? value) {
    search = value;
    notifyListeners();
  }

  Map<String, dynamic> getFilters() {
    return {
      if (city != null && city!.isNotEmpty) 'city__icontains': city,
      if (state != null && state!.isNotEmpty) 'state__icontains': state,
      if (country != null && country!.isNotEmpty) 'country__icontains': country,
      if (familyType != null) 'family_type': familyType!.value,
      if (familyStatus != null) 'family_status': familyStatus!.value,
      if (heightRange != null) ...{
        'height__gte': heightRange!.start,
        'height__lte': heightRange!.end,
      },
      if (weightRange != null) ...{
        'weight__gte': weightRange!.start,
        'weight__lte': weightRange!.end,
      },
      if (siblings != null) 'siblings': siblings,
      if (search != null && search!.isNotEmpty) 'search': search,
    };
  }

  void clearFilters() {
    city = null;
    state = null;
    country = null;
    familyType = null;
    familyStatus = null;
    heightRange = null;
    weightRange = null;
    siblings = null;
    search = null;
    notifyListeners();
  }
}
