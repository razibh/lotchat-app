import 'package:flutter/material.dart';
import '../../core/models/gift_model.dart';

class GiftPreviewDialog extends StatelessWidget {

  const GiftPreviewDialog({Key? key, required this.gift}) : super(key: key);
  final GiftModel gift;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            // Gift animation
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: gift.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                gift.icon,
                color: gift.color,
                size: 80,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Gift name
            Text(
              gift.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Gift description
            Text(
              gift.description,
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <>[
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gift.price} coins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Close button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: gift.color,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}