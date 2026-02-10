import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/localization_service.dart';

class DioExceptionWidget extends StatelessWidget {
  const DioExceptionWidget({super.key, required this.exception});

  final DioException exception;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const TranslatedText(
            'Oops! An error occurred.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const TranslatedText(
            'Please check your network connection and try again.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (kDebugMode)
            Column(
              children: [
                TranslatedText((exception).message.toString()),
                TranslatedText((exception).requestOptions.uri.toString()),
                TranslatedText((exception).requestOptions.data.toString()),
                TranslatedText(((exception).response?.data).toString()),
              ],
            ),
        ],
      ),
    );
  }
}
