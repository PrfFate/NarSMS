import 'package:flutter/material.dart';

class MyOngoingTasksPage extends StatefulWidget {
  const MyOngoingTasksPage({super.key});

  @override
  State<MyOngoingTasksPage> createState() => _MyOngoingTasksPageState();
}

class _MyOngoingTasksPageState extends State<MyOngoingTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devam Eden Görevlerim'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.loop,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Devam Eden Görevlerim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Devam eden görevlerim listesi buraya gelecek',
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
