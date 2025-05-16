import 'package:flutter_test/flutter_test.dart';
import 'package:contactx/contactx.dart';
import 'package:contactx/contactx_platform_interface.dart';
import 'package:contactx/contactx_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockContactxPlatform
    with MockPlatformInterfaceMixin
    implements ContactxPlatform {

  @override
  Future<List<Map<String, String>>> getContacts() {
    // TODO: implement getContacts
    throw UnimplementedError();
  }
  
  @override
  Future<String> checkContactPermission() {
    // TODO: implement checkContactPermission
    throw UnimplementedError();
  }
}

void main() {
  final ContactxPlatform initialPlatform = ContactxPlatform.instance;

  test('$MethodChannelContactx is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelContactx>());
  });

}
