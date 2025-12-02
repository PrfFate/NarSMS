import 'package:flutter/material.dart';

class PartiallyShippedSalesPage extends StatefulWidget {
  const PartiallyShippedSalesPage({super.key});

  @override
  State<PartiallyShippedSalesPage> createState() =>
      _PartiallyShippedSalesPageState();
}

class _PartiallyShippedSalesPageState
    extends State<PartiallyShippedSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kısmi Kargolanan Satışlar'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.amber,
            ),
            SizedBox(height: 16),
            Text(
              'Kısmi Kargolanan Satışlar',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kısmi kargolanan satışlar listesi buraya gelecek',
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
