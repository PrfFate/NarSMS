import 'package:flutter/material.dart';

class DeliveredSalesPage extends StatefulWidget {
  const DeliveredSalesPage({super.key});

  @override
  State<DeliveredSalesPage> createState() => _DeliveredSalesPageState();
}

class _DeliveredSalesPageState extends State<DeliveredSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teslim Edilen Satışlar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: Colors.teal,
            ),
            SizedBox(height: 16),
            Text(
              'Teslim Edilen Satışlar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Teslim edilen satışlar listesi buraya gelecek',
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
