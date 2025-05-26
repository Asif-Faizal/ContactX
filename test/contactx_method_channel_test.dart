import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:contactx/contactx_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelContactx platform = MethodChannelContactx();
  const MethodChannel channel = MethodChannel('contactx');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getContacts':
              return [
                {'name': 'Test Contact', 'number': '1234567890'},
              ];
            case 'checkPermission':
              return 'authorized';
            default:
              return '';
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getContacts returns a list of contacts', () async {
    final contacts = await platform.getContacts();
    expect(contacts, isA<List<Map<String, String>>>());
    expect(contacts.length, 1);
    expect(contacts[0]['name'], 'Test Contact');
    expect(contacts[0]['number'], '1234567890');
  });

  test('checkContactPermission returns permission status', () async {
    final status = await platform.checkContactPermission();
    expect(status, 'authorized');
  });
}
