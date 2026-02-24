import 'package:flutter/material.dart';

class FielderDashboardPage extends StatefulWidget {
  const FielderDashboardPage({super.key});

  @override
  State<FielderDashboardPage> createState() => _FielderDashboardPageState();
}

class _FielderDashboardPageState extends State<FielderDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saha Görevlisi Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Saha Görevlisi Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Saha görevlisi paneli içeriği buraya gelecek',
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
