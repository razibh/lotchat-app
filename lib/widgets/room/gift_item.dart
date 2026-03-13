import 'package:flutter/material.dart';
import '../../core/models/gift_model.dart';

class GiftItem extends StatelessWidget {

  const GiftItem({
    Key? key,
    required this.gift,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);
  final GiftModel gift;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? gift.color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? gift.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            // Gift icon with animation indicator
            Stack(
              children: <>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: gift.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    gift.icon,
                    color: gift.color,
                    size: 30,
                  ),
                ),
                if (gift.isAnimated)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.animation,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                if (gift.isVip)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                if (gift.isSvip)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <>[Colors.purple, Colors.pink],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Gift name
            Text(
              gift.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Gift price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                const Icon(
                  Icons.monetization_on,
                  size: 10,
                  color: Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  '${gift.price}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}