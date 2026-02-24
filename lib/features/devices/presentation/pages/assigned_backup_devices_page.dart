import 'package:flutter/material.dart';

class AssignedBackupDevicesPage extends StatefulWidget {
  const AssignedBackupDevicesPage({super.key});

  @override
  State<AssignedBackupDevicesPage> createState() =>
      _AssignedBackupDevicesPageState();
}

class _AssignedBackupDevicesPageState extends State<AssignedBackupDevicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atanmış Yedek Cihazlar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 64,
              color: Colors.indigo,
            ),
            SizedBox(height: 16),
            Text(
              'Atanmış Yedek Cihazlar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Atanmış yedek cihazlar listesi buraya gelecek',
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
