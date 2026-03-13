import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AgencyBadgeWidget extends StatelessWidget {

  const AgencyBadgeWidget({
    Key? key,
    required this.agencyName,
    required this.commissionRate,
    this.isVerified = false,
    this.onTap,
  }) : super(key: key);
  final String agencyName;
  final double commissionRate;
  final bool isVerified;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <>[Color(0xFF9C27B0), Color(0xFF7B1FA2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: <>[
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Icon(
              Icons.business,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              agencyName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isVerified) ...<>[
              const SizedBox(width: 4),
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 12,
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$commissionRate%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}