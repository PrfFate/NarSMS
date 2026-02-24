import 'package:flutter/material.dart';

class DeviceAddPage extends StatefulWidget {
  const DeviceAddPage({super.key});

  @override
  State<DeviceAddPage> createState() => _DeviceAddPageState();
}

class _DeviceAddPageState extends State<DeviceAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Ekle'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Cihaz Ekle',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cihaz ekleme formu buraya gelecek',
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
