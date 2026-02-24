import 'package:flutter/material.dart';

class PendingSalesPage extends StatefulWidget {
  const PendingSalesPage({super.key});

  @override
  State<PendingSalesPage> createState() => _PendingSalesPageState();
}

class _PendingSalesPageState extends State<PendingSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bekleyen Satışlar',
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
                      Icons.hourglass_empty,
                      size: 64,
                      color: Color(0xFFF57C00),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bekleyen satışlar listesi buraya gelecek',
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
