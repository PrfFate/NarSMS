import 'package:flutter/material.dart';

class CarrierManagementPage extends StatefulWidget {
  const CarrierManagementPage({super.key});

  @override
  State<CarrierManagementPage> createState() => _CarrierManagementPageState();
}

class _CarrierManagementPageState extends State<CarrierManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kargo Yönetimi'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Kargo Yönetimi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kargo firmaları yönetimi buraya gelecek',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new carrier
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
