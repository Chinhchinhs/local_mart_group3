import 'package:flutter/material.dart';
import 'package:local_mart/core/utils/currency_formatter.dart';

class FreeShipProgressBar extends StatelessWidget {
  final double totalPrice;
  final double threshold;

  const FreeShipProgressBar({
    super.key,
    required this.totalPrice,
    this.threshold = 200000,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (totalPrice / threshold).clamp(0.0, 1.0);
    double remaining = threshold - totalPrice;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  totalPrice >= threshold
                      ? "Bạn đã được MIỄN PHÍ vận chuyển! 🎉"
                      : "Mua thêm ${CurrencyFormatter.formatVND(remaining)} để được Freeship",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
