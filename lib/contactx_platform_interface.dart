import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'contactx_method_channel.dart';

abstract class ContactxPlatform extends PlatformInterface {
  /// Constructs a ContactxPlatform.
  ContactxPlatform() : super(token: _token);

  static final Object _token = Object();

  static ContactxPlatform _instance = MethodChannelContactx();

  /// The default instance of [ContactxPlatform] to use.
  ///
  /// Defaults to [MethodChannelContactx].
  static ContactxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ContactxPlatform] when
  /// they register themselves.
  static set instance(ContactxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get a list of contacts with only name and phone number
  Future<List<Map<String, String>>> getContacts() {
    throw UnimplementedError('getContacts() has not been implemented.');
  }
  
  /// Check contact permission status (particularly useful for iOS)
  Future<String> checkContactPermission() {
    throw UnimplementedError('checkContactPermission() has not been implemented.');
  }
}
