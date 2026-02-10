import 'dart:math';

import '../constants.dart';

class RandomDataGenerator {
  RandomDataGenerator._private();

  static final RandomDataGenerator _instance = RandomDataGenerator._private();

  static RandomDataGenerator get i => _instance;

  final Random _random = Random();

  // Organization/Company names
  final List<String> _companyNames = [
    'Tech Solutions Inc',
    'Global Industries',
    'Digital Services Co',
    'Innovation Labs',
    'Enterprise Systems',
    'Smart Solutions',
    'Future Technologies',
    'Advanced Systems',
    'Cloud Services Ltd',
    'Data Analytics Corp',
    'Software Innovations',
    'Business Solutions Group',
    'Modern Enterprises',
    'Strategic Partners',
    'Creative Ventures',
  ];

  // Common cities
  final List<String> _cities = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
    'San Antonio',
    'San Diego',
    'Dallas',
    'San Jose',
    'Austin',
    'Jacksonville',
    'Fort Worth',
    'Columbus',
    'Charlotte',
  ];

  // Common domains for websites and emails
  final List<String> _domains = [
    'example.com',
    'test.com',
    'demo.org',
    'sample.net',
    'company.com',
    'business.org',
    'enterprise.net',
    'corp.com',
  ];

  // Street names/types
  final List<String> _streetTypes = [
    'Street',
    'Avenue',
    'Road',
    'Lane',
    'Drive',
    'Court',
    'Boulevard',
    'Place',
    'Circle',
    'Parkway',
  ];

  /// Generates a random organization/company name
  String randomOrganizationName({bool includeNumber = true}) {
    final name = _companyNames[_random.nextInt(_companyNames.length)];
    if (includeNumber) {
      return '$name ${_random.nextInt(999) + 1}';
    }
    return name;
  }

  /// Generates a random phone number (US format)
  String randomPhoneNumber({String? countryCode}) {
    final code = countryCode ?? '+1';
    return '$code${_random.nextInt(900) + 100}${_random.nextInt(900) + 100}${_random.nextInt(9000) + 1000}';
  }

  /// Generates a random email address
  String randomEmail({String? prefix}) {
    final emailPrefix = prefix ?? 'user${_random.nextInt(9999)}';
    final domain = _domains[_random.nextInt(_domains.length)];
    return '$emailPrefix@$domain';
  }

  /// Generates a random website URL
  String randomWebsite() {
    final domain = _domains[_random.nextInt(_domains.length)];
    final protocols = ['https://www.', 'http://www.', 'https://'];
    final protocol = protocols[_random.nextInt(protocols.length)];
    return '$protocol$domain';
  }

  /// Generates a random street address
  String randomAddressLine1() {
    final streetNumber = _random.nextInt(9999) + 1;
    final streetName = firstNames[_random.nextInt(firstNames.length)];
    final streetType = _streetTypes[_random.nextInt(_streetTypes.length)];
    return '$streetNumber $streetName $streetType';
  }

  /// Generates a random address line 2 (optional - can be empty)
  String randomAddressLine2({bool allowEmpty = true}) {
    if (allowEmpty && _random.nextBool()) {
      return '';
    }
    final addressTypes = ['Suite', 'Apt', 'Unit', 'Floor', 'Building'];
    final addressType = addressTypes[_random.nextInt(addressTypes.length)];
    return '$addressType ${_random.nextInt(999) + 100}';
  }

  /// Generates a random city name
  String randomCity() {
    return _cities[_random.nextInt(_cities.length)];
  }

  /// Generates a random postal/ZIP code
  String randomPostalCode({int length = 5}) {
    final min = pow(10, length - 1).toInt();
    final max = pow(10, length).toInt() - 1;
    return '${_random.nextInt(max - min + 1) + min}';
  }

  /// Generates a random name (first + last)
  String randomName() {
    return '${firstNames[_random.nextInt(firstNames.length)]} ${lastNames[_random.nextInt(lastNames.length)]}';
  }

  /// Generates a random first name
  String randomFirstName() {
    return firstNames[_random.nextInt(firstNames.length)];
  }

  /// Generates a random last name
  String randomLastName() {
    return lastNames[_random.nextInt(lastNames.length)];
  }

  /// Generates a random integer within a range
  int randomInt(int min, int max) {
    return _random.nextInt(max - min + 1) + min;
  }

  /// Generates a random boolean
  bool randomBool() {
    return _random.nextBool();
  }
}
