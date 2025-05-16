import 'contactx_platform_interface.dart';

class Contactx {

  /// Returns a list of contacts containing only name and phone number
  Future<List<Map<String, String>>> getContacts() {
    return ContactxPlatform.instance.getContacts();
  }
  
  /// Check contact permission status.
  /// Returns for iOS: "authorized", "denied", "restricted", "notDetermined", "unknown"
  /// Returns for Android: "authorized", "denied"
  Future<String> checkContactPermission() {
    return ContactxPlatform.instance.checkContactPermission();
  }
}
