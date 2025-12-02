import 'package:flutter/material.dart';

class ApprovalMechanismPage extends StatefulWidget {
  const ApprovalMechanismPage({super.key});

  @override
  State<ApprovalMechanismPage> createState() => _ApprovalMechanismPageState();
}

class _ApprovalMechanismPageState extends State<ApprovalMechanismPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onay Adımları'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.approval,
              size: 64,
              color: Colors.indigo,
            ),
            SizedBox(height: 16),
            Text(
              'Onay Adımları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Satış onay mekanizması yönetimi buraya gelecek',
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
