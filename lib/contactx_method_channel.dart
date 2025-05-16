import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'contactx_platform_interface.dart';

/// An implementation of [ContactxPlatform] that uses method channels.
class MethodChannelContactx extends ContactxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('contactx');
  
  @override
  Future<List<Map<String, String>>> getContacts() async {
    final List<dynamic>? contacts = await methodChannel.invokeMethod<List<dynamic>>('getContacts');
    if (contacts == null) return [];
    
    return contacts.map((contact) {
      final Map<dynamic, dynamic> contactMap = contact as Map<dynamic, dynamic>;
      return {
        'name': contactMap['name'] as String? ?? '',
        'number': contactMap['number'] as String? ?? '',
      };
    }).toList();
  }
  
  /// Check contact permission status.
  /// Returns for iOS: "authorized", "denied", "restricted", "notDetermined", "unknown"
  /// Returns for Android: "authorized", "denied"
  @override
  Future<String> checkContactPermission() async {
    final String status = await methodChannel.invokeMethod<String>('checkPermission') ?? "unknown";
    return status;
  }
}