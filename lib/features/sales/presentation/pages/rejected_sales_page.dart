import 'package:flutter/material.dart';

class RejectedSalesPage extends StatefulWidget {
  const RejectedSalesPage({super.key});

  @override
  State<RejectedSalesPage> createState() => _RejectedSalesPageState();
}

class _RejectedSalesPageState extends State<RejectedSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reddedilen Satışlar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Reddedilen Satışlar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Reddedilen satışlar listesi buraya gelecek',
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
