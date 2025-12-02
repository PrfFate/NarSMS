import 'package:flutter/material.dart';

class ServiceCompletedPage extends StatefulWidget {
  const ServiceCompletedPage({super.key});

  @override
  State<ServiceCompletedPage> createState() => _ServiceCompletedPageState();
}

class _ServiceCompletedPageState extends State<ServiceCompletedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tamamlanan İşlemler'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Tamamlanan İşlemler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tamamlanan servis işlemleri buraya gelecek',
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
