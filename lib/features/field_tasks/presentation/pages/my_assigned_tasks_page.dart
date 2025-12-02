import 'package:flutter/material.dart';

class MyAssignedTasksPage extends StatefulWidget {
  const MyAssignedTasksPage({super.key});

  @override
  State<MyAssignedTasksPage> createState() => _MyAssignedTasksPageState();
}

class _MyAssignedTasksPageState extends State<MyAssignedTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atanan Görevlerim'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 64,
              color: Colors.blue,
            ),
            SizedBox(height: 16),
            Text(
              'Atanan Görevlerim',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bana atanan görevler listesi buraya gelecek',
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
