import 'package:flutter/material.dart';

class MessageReportDialog extends StatefulWidget {

  const MessageReportDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);
  final Function(String, String) onSubmit;

  @override
  State<MessageReportDialog> createState() => _MessageReportDialogState();
}

class _MessageReportDialogState extends State<MessageReportDialog> {
  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _reasons = <String>[
    'Harassment',
    'Spam',
    'Inappropriate content',
    'Violence',
    'Hate speech',
    'Nudity',
    'Fake account',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report Message'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Text(
              'Why are you reporting this message?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._reasons.map((String reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
              );
            }),
            if (_selectedReason == 'Other') ...<>[
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Please describe the issue...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: <>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedReason != null
              ? () {
                  widget.onSubmit(
                    _selectedReason!,
                    _descriptionController.text,
                  );
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Report'),
        ),
      ],
    );
  }
}