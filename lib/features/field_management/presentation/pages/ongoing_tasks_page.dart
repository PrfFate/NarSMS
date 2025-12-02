import 'package:flutter/material.dart';

class OngoingTasksPage extends StatefulWidget {
  const OngoingTasksPage({super.key});

  @override
  State<OngoingTasksPage> createState() => _OngoingTasksPageState();
}

class _OngoingTasksPageState extends State<OngoingTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devam Eden Görevler'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.autorenew,
              size: 64,
              color: Colors.purple,
            ),
            SizedBox(height: 16),
            Text(
              'Devam Eden Görevler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Devam eden görevler listesi buraya gelecek',
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
