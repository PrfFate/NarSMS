import 'package:flutter/material.dart';

class DeviceReportsPage extends StatefulWidget {
  const DeviceReportsPage({super.key});

  @override
  State<DeviceReportsPage> createState() => _DeviceReportsPageState();
}

class _DeviceReportsPageState extends State<DeviceReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Raporları'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Cihaz Raporları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cihaz raporları buraya gelecek',
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
