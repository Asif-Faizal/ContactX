import 'package:flutter/material.dart';
import 'package:contactx/contactx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Contactx Example', home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Contactx _contactx = Contactx();
  List<Map<String, String>> _contacts = [];
  bool _isLoading = false;
  String _permissionStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  /// Checks the current contact permission status using the plugin
  Future<void> _checkPermissionStatus() async {
    final status = await _contactx.checkContactPermission();
    if (mounted) {
      setState(() {
        _permissionStatus = status;
      });
    }
  }

  /// Loads contacts after checking/requesting permission
  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _contactx.checkContactPermission();
      setState(() {
        _permissionStatus = status;
      });

      if (status == 'authorized') {
        final contacts = await _contactx.getContacts();
        setState(() {
          _contacts = contacts;
        });
      } else {
        // Request permission by calling getContacts
        try {
          final contacts = await _contactx.getContacts();
          final newStatus = await _contactx.checkContactPermission();
          setState(() {
            _permissionStatus = newStatus;
          });

          if (newStatus == 'authorized') {
            setState(() {
              _contacts = contacts;
            });
          } else {
            _showSettingsAlert();
          }
        } catch (e) {
          debugPrint('Failed to load contacts: $e');
          _showSettingsAlert();
        }
      }
    } catch (e) {
      debugPrint('Failed to load contacts: $e');
      _showSnackBar('Failed to load contacts: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Shows a snackbar with a message
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// Shows a dialog directing the user to app settings
  void _showSettingsAlert() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Contacts Permission Required'),
            content: const Text(
              'This app needs access to your contacts. Please grant permission in Settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts Example')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Permission status: $_permissionStatus'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loadContacts,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Load Contacts'),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child:
                _contacts.isEmpty
                    ? const Center(child: Text('No contacts to display'))
                    : ListView.separated(
                      itemCount: _contacts.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(contact['name'] ?? ''),
                          subtitle: Text(contact['number'] ?? ''),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
