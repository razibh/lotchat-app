import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AgencyListScreen extends StatelessWidget {
  final String countryId;
  final String filter;

  const AgencyListScreen({
    super.key,
    required this.countryId,
    this.filter = 'all',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agencies'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Country ID: $countryId'),
            Text('Filter: $filter'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('countryId', countryId));
    properties.add(StringProperty('filter', filter));
  }
}