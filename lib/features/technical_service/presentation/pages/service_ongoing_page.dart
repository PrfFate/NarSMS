import 'package:flutter/material.dart';

class ServiceOngoingPage extends StatefulWidget {
  const ServiceOngoingPage({super.key});

  @override
  State<ServiceOngoingPage> createState() => _ServiceOngoingPageState();
}

class _ServiceOngoingPageState extends State<ServiceOngoingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devam Eden İşlemler'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pending_actions,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Devam Eden İşlemler',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Devam eden servis işlemleri buraya gelecek',
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
