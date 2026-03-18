import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class RecruitmentScreen extends StatelessWidget {
  final String countryId;
  final String recruitmentType;

  const RecruitmentScreen({
    super.key,
    required this.countryId,
    this.recruitmentType = 'agencies',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recruitment'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country: $countryId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Recruitment Type: $recruitmentType'),
            const SizedBox(height: 24),
            const Text(
              'Open Positions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.person, color: Colors.green),
                      ),
                      title: Text('Position ${index + 1}'),
                      subtitle: Text('Type: ${index % 2 == 0 ? 'Agency' : 'Host'}'),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  );
                },
              ),
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
    properties.add(StringProperty('recruitmentType', recruitmentType));
  }
}