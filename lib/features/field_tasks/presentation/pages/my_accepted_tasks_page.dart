import 'package:flutter/material.dart';

class MyAcceptedTasksPage extends StatefulWidget {
  const MyAcceptedTasksPage({super.key});

  @override
  State<MyAcceptedTasksPage> createState() => _MyAcceptedTasksPageState();
}

class _MyAcceptedTasksPageState extends State<MyAcceptedTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kabul Ettiğim Görevler'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.thumb_up,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Kabul Ettiğim Görevler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kabul ettiğim görevler listesi buraya gelecek',
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
