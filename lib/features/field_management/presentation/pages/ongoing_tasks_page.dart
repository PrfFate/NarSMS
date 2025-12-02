import 'package:flutter/material.dart';

class OngoingTasksPage extends StatefulWidget {
  const OngoingTasksPage({super.key});

  @override
  State<OngoingTasksPage> createState() => _OngoingTasksPageState();
}

class _OngoingTasksPageState extends State<OngoingTasksPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Devam Eden Görevler',
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
                      Icons.autorenew,
                      size: 64,
                      color: Color(0xFFF57C00),
                    ),
                    SizedBox(height: 16),
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
            ),
          ),
        ],
      ),
    );
  }
}
