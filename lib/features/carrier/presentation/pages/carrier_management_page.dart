import 'package:flutter/material.dart';

class CarrierManagementPage extends StatefulWidget {
  const CarrierManagementPage({super.key});

  @override
  State<CarrierManagementPage> createState() => _CarrierManagementPageState();
}

class _CarrierManagementPageState extends State<CarrierManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kargo Yönetimi',
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
                      Icons.local_shipping,
                      size: 64,
                      color: Color(0xFFF57C00),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Kargo firmaları yönetimi buraya gelecek',
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
