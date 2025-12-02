import 'package:flutter/material.dart';

class DeviceReturnPage extends StatefulWidget {
  const DeviceReturnPage({super.key});

  @override
  State<DeviceReturnPage> createState() => _DeviceReturnPageState();
}

class _DeviceReturnPageState extends State<DeviceReturnPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz İade'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_return,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Cihaz İade',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cihaz iade formu buraya gelecek',
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
