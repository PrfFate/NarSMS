import 'package:flutter/material.dart';

class MyCompletedTasksPage extends StatefulWidget {
  const MyCompletedTasksPage({super.key});

  @override
  State<MyCompletedTasksPage> createState() => _MyCompletedTasksPageState();
}

class _MyCompletedTasksPageState extends State<MyCompletedTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tamamladığım Görevler',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.done_all,
                      size: 64,
                      color: Color(0xFFF57C00),
                    ),
                    SizedBox(height: 16),
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
            ),
          ),
        ],
      ),
    );
  }
}
