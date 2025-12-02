import 'package:flutter/material.dart';

class DepotDevicesPage extends StatefulWidget {
  const DepotDevicesPage({super.key});

  @override
  State<DepotDevicesPage> createState() => _DepotDevicesPageState();
}

class _DepotDevicesPageState extends State<DepotDevicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Depo Cihazları'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warehouse,
              size: 64,
              color: Colors.purple,
            ),
            SizedBox(height: 16),
            Text(
              'Depo Cihazları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Depodaki cihazlar listesi buraya gelecek',
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
