import 'package:flutter/material.dart';

class ServicePreRegistrationsPage extends StatefulWidget {
  const ServicePreRegistrationsPage({super.key});

  @override
  State<ServicePreRegistrationsPage> createState() =>
      _ServicePreRegistrationsPageState();
}

class _ServicePreRegistrationsPageState
    extends State<ServicePreRegistrationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis Ön Kayıtları'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.app_registration,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Servis Ön Kayıtları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Servis ön kayıtları listesi buraya gelecek',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
