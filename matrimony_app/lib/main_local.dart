import 'dart:io';

import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';
import 'main_dev.dart';

class AppConfigLocal extends AppConfig {
  @override
  String get domain => Platform.isAndroid ? "10.0.2.2" : "0.0.0.0";

  @override
  String get slugUrl => "/api/";

  @override
  String get port => "8000";

  @override
  String get scheme => "http";

  @override
  ENV get env => ENV.local;

  @override
  String get password => "password";

  @override
  String get username => "username";

  @override
  String get googleMapsApiKey => "AIzaSyBwAIsJa57pOEsDY9fBrtSODwaxuTksaDQ";

  @override
  String get privacyPolicyUrl => "privacy-policy";

  @override
  String get termsAndConditionsUrl => "terms-and-conditions";
}

void main() async {
  appConfig = AppConfigDev();
  await mainCommon();
  runApp(const MyApp());
}
