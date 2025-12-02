import 'package:flutter/material.dart';

class DepotBackupDevicesPage extends StatefulWidget {
  const DepotBackupDevicesPage({super.key});

  @override
  State<DepotBackupDevicesPage> createState() => _DepotBackupDevicesPageState();
}

class _DepotBackupDevicesPageState extends State<DepotBackupDevicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depodaki Yedek Cihazlar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.backup,
              size: 64,
              color: Colors.teal,
            ),
            SizedBox(height: 16),
            Text(
              'Depodaki Yedek Cihazlar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Depodaki yedek cihazlar listesi buraya gelecek',
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
