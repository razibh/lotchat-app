import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 80,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Under Maintenance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We are currently performing scheduled maintenance.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}