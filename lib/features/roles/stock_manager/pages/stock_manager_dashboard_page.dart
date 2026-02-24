import 'package:flutter/material.dart';

class StockManagerDashboardPage extends StatefulWidget {
  const StockManagerDashboardPage({super.key});

  @override
  State<StockManagerDashboardPage> createState() =>
      _StockManagerDashboardPageState();
}

class _StockManagerDashboardPageState extends State<StockManagerDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Yöneticisi Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory,
              size: 64,
              color: Colors.purple,
            ),
            SizedBox(height: 16),
            Text(
              'Stok Yöneticisi Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Stok yöneticisi paneli içeriği buraya gelecek',
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
