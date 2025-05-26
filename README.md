# ContactX

A Flutter plugin for retrieving contacts from the device with proper permission handling.

## Features

- Retrieve device contacts with name and phone number
- Automatic permission handling for both Android and iOS
- Clean phone number formatting (removes special characters)
- Permission status checking

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  contactx: ^0.0.8
```

## Usage

### Import the package

```dart
import 'package:contactx/contactx.dart';
```

### Initialize the plugin

```dart
final Contactx _contactx = Contactx();
```

### Get Contacts

The `getContacts()` method retrieves all contacts from the device with their names and phone numbers. It handles permission requests automatically.

```dart
try {
  final contacts = await _contactx.getContacts();
  // contacts is a List<Map<String, String>>
  // Each contact has 'name' and 'number' keys
  // Example: [{'name': 'John Doe', 'number': '1234567890'}]
} catch (e) {
  // Handle error
}
```

### Check Permission Status

The `checkContactPermission()` method checks the current permission status for contacts access.

```dart
final status = await _contactx.checkContactPermission();
// Returns:
// - For iOS: "authorized", "denied", "restricted", "notDetermined", "unknown"
// - For Android: "authorized", "denied"
```

## Example

Here's a complete example of how to use the plugin:

```dart
import 'package:flutter/material.dart';
import 'package:contactx/contactx.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Contactx _contactx = Contactx();
  List<Map<String, String>> _contacts = [];

  Future<void> _loadContacts() async {
    try {
      final status = await _contactx.checkContactPermission();
      if (status == 'authorized') {
        final contacts = await _contactx.getContacts();
        setState(() {
          _contacts = contacts;
        });
      } else {
        // Handle permission not granted
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Contacts Example')),
        body: ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            return ListTile(
              title: Text(contact['name'] ?? ''),
              subtitle: Text(contact['number'] ?? ''),
            );
          },
        ),
      ),
    );
  }
}
```

## Platform Setup

### Android

Add the following permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

### iOS

Add the following keys to your `Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to contacts to show them in the app.</string>
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
