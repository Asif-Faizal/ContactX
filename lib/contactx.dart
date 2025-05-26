import 'contactx_platform_interface.dart';

/// A Flutter plugin for accessing device contacts.
///
/// This plugin provides functionality to request contact permissions
/// and fetch contacts from the device's address book.
///
/// The main class for the Contactx plugin.
///
/// Use this class to interact with device contacts and manage permissions.
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
