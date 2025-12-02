import 'package:flutter/material.dart';

class CancelledTasksPage extends StatefulWidget {
  const CancelledTasksPage({super.key});

  @override
  State<CancelledTasksPage> createState() => _CancelledTasksPageState();
}

class _CancelledTasksPageState extends State<CancelledTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İptal Edilen Görevler'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'İptal Edilen Görevler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'İptal edilen görevler listesi buraya gelecek',
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
