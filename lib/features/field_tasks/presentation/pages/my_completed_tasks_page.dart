import 'package:flutter/material.dart';

class MyCompletedTasksPage extends StatefulWidget {
  const MyCompletedTasksPage({super.key});

  @override
  State<MyCompletedTasksPage> createState() => _MyCompletedTasksPageState();
}

class _MyCompletedTasksPageState extends State<MyCompletedTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamamladığım Görevler'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.done_all,
              size: 64,
              color: Colors.teal,
            ),
            SizedBox(height: 16),
            Text(
              'Tamamladığım Görevler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tamamladığım görevler listesi buraya gelecek',
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
