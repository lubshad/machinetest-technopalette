import 'dart:math'; // Added import

import 'package:flutter/material.dart';
import 'package:matrimony_app/mixins/event_listener.dart';

import '../../core/repository.dart';
import '../../services/snackbar_utils.dart';
import 'profile_details_model.dart';

class CommonController extends ChangeNotifier {
  static CommonController get i => _instance;
  static final CommonController _instance = CommonController._private();

  CommonController._private();

  bool initialized = false;

  Future<void> init() async {
    if (initialized) return;
    await fetchProfileDetails();
    initialized = true;
  }

  ProfileDetailsModel? profileDetails;

  Future<void> fetchProfileDetails() async {
    await DataRepository.i
        .fetchProfileDetails()
        .then((value) {
          profileDetails = value;
          notifyListeners();
        })
        .onError((error, stackTrace) {
          showErrorMessage(error);
        });
  }

  Future<bool> toggleInterest(int profileId) async {
    try {
      final result = await DataRepository.i.toggleInterest(profileId);
      final bool isInterested = result['is_interested'] ?? false;

      if (profileDetails != null) {
        final List<int> currentInterests = List.from(
          profileDetails!.interests ?? [],
        );
        if (isInterested) {
          if (!currentInterests.contains(profileId)) {
            currentInterests.add(profileId);
          }
        } else {
          currentInterests.remove(profileId);
        }
        profileDetails = profileDetails!.copyWith(interests: currentInterests);
        notifyListeners();
      }
      EventListener.i.sendEvent(Event(eventType: EventType.interestToggel));

      showSuccessMessage(result['message'] ?? "Status updated");
      return isInterested;
    } catch (e) {
      showErrorMessage(e);
      return false;
    }
  }

  void clear() {
    initialized = false;
  }
}
