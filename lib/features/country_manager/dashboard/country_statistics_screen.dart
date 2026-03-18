import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CountryStatisticsScreen extends StatelessWidget {
  final String countryId;
  final String period;

  const CountryStatisticsScreen({
    super.key,
    required this.countryId,
    this.period = 'month',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Statistics'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country: $countryId',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Period: $period'),
            const SizedBox(height: 24),

            // Statistics Cards
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total Agencies', '24', Icons.business, Colors.blue),
                _buildStatCard('Total Hosts', '156', Icons.people, Colors.green),
                _buildStatCard('Active Users', '2,345', Icons.person, Colors.orange),
                _buildStatCard('Revenue', '৳125K', Icons.monetization_on, Colors.purple),
                _buildStatCard('Growth', '+15%', Icons.trending_up, Colors.teal),
                _buildStatCard('Engagement', '78%', Icons.thumb_up, Colors.pink),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
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
    properties.add(StringProperty('period', period));
  }
}