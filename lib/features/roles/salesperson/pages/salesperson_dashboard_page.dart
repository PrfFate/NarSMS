import 'package:flutter/material.dart';

class SalespersonDashboardPage extends StatefulWidget {
  const SalespersonDashboardPage({super.key});

  @override
  State<SalespersonDashboardPage> createState() =>
      _SalespersonDashboardPageState();
}

class _SalespersonDashboardPageState extends State<SalespersonDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satış Elemanı Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 64,
              color: Colors.teal,
            ),
            SizedBox(height: 16),
            Text(
              'Satış Elemanı Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Satış elemanı paneli içeriği buraya gelecek',
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
