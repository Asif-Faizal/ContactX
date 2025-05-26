import 'package:flutter_test/flutter_test.dart';
import 'package:contactx/contactx.dart';
import 'package:contactx/contactx_platform_interface.dart';
import 'package:contactx/contactx_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockContactxPlatform
    with MockPlatformInterfaceMixin
    implements ContactxPlatform {
  @override
  Future<List<Map<String, String>>> getContacts() async {
    return [
      {'name': 'Mock Contact', 'number': '9876543210'},
    ];
  }

  @override
  Future<String> checkContactPermission() async {
    return 'authorized';
  }
}

void main() {
  final ContactxPlatform initialPlatform = ContactxPlatform.instance;

  test('$MethodChannelContactx is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelContactx>());
  });

  test('getContacts returns a list of contacts', () async {
    final mockPlatform = MockContactxPlatform();
    ContactxPlatform.instance = mockPlatform;
    final contacts = await Contactx().getContacts();
    expect(contacts, isA<List<Map<String, String>>>());
    expect(contacts.length, 1);
    expect(contacts[0]['name'], 'Mock Contact');
    expect(contacts[0]['number'], '9876543210');
  });

  test('checkContactPermission returns permission status', () async {
    final mockPlatform = MockContactxPlatform();
    ContactxPlatform.instance = mockPlatform;
    final status = await Contactx().checkContactPermission();
    expect(status, 'authorized');
  });
}
