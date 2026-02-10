

import 'package:flutter/material.dart';

import 'core/app_config.dart';
import 'main.dart';

class AppConfigDev extends AppConfig {
  @override
  String get domain => "matrimony.coreaxissolutions.in";

  @override
  String get slugUrl => "/api/";

  @override
  String get port => "443";

  @override
  String get scheme => "https";

  @override
  ENV get env => ENV.local;

  @override
  String get password => "password123";

  @override
  String get username => "william_10";

  @override
  String get googleMapsApiKey => "'sdfsdfsdfsdf'";

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
