import 'package:flutter/material.dart';
import 'package:nica_balance/presentation/settings/viewmodels/preferences_viewmodel.dart';
import 'package:provider/provider.dart';

class Metric extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;

  const Metric({super.key, 
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final prefsVM = context.watch<PreferencesViewModel>();
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              prefsVM.hideBalances 
              ? '•••••••' 
              : '\$ ${value.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        )
      ],
    );
  }
}