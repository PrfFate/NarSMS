import 'package:flutter/material.dart';

class CompletedSalesPage extends StatefulWidget {
  const CompletedSalesPage({super.key});

  @override
  State<CompletedSalesPage> createState() => _CompletedSalesPageState();
}

class _CompletedSalesPageState extends State<CompletedSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamamlanan Satışlar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done_all,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Tamamlanan Satışlar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tamamlanan satışlar listesi buraya gelecek',
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
