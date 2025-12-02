import 'package:flutter/material.dart';

class ServiceFinalChecksPage extends StatefulWidget {
  const ServiceFinalChecksPage({super.key});

  @override
  State<ServiceFinalChecksPage> createState() => _ServiceFinalChecksPageState();
}

class _ServiceFinalChecksPageState extends State<ServiceFinalChecksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Son Kontroller'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fact_check,
              size: 64,
              color: Colors.purple,
            ),
            SizedBox(height: 16),
            Text(
              'Son Kontroller',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Son kontrol aşamasındaki servisler buraya gelecek',
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
