import 'package:flutter/material.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/analytics/views/analytics_screen.dart';
import 'package:nica_balance/presentation/settings/views/settings_screen.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/nicabalance.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NicaBalance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              Text(
                'Controla tu dinero inteligentemente',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
            );
          },
          icon: const Icon(Icons.analytics_rounded),
        ),

        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          icon: const Icon(Icons.settings_suggest_rounded),
        ),
      ],
    );
  }
}