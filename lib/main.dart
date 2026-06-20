import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/data/repositories/debt_repository.dart';
import 'package:nica_balance/data/repositories/goal_repository.dart';
import 'package:nica_balance/data/repositories/income_repository.dart';
import 'package:nica_balance/presentation/analytics/viewmodels/analytics_viewmodel.dart';
import 'package:nica_balance/presentation/calendar/viewmodels/calendar_viewmodel.dart';
import 'package:nica_balance/presentation/debts/viewmodels/debt_viewmodel.dart';
import 'package:nica_balance/presentation/goals/viewmodels/goals_viewmodel.dart';
import 'package:nica_balance/presentation/home/viewmodels/dashboard_viewmodel.dart';
import 'package:nica_balance/presentation/home/views/main_navigation_screen.dart';
import 'package:nica_balance/presentation/income/viewmodels/income_viewmodel.dart';
import 'package:nica_balance/presentation/onboarding/onboarding_screen.dart';
import 'package:nica_balance/presentation/settings/viewmodels/preferences_viewmodel.dart';
import 'package:nica_balance/presentation/statistics/viewmodels/statistics_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/objectbox_store.dart';
import 'data/repositories/expense_repository.dart';
import 'presentation/expenses/viewmodels/expense_viewmodel.dart';

void main() async {

  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('show_onboarding') ?? true;

  // Inicialización de ObjectBox
  final database = await ObjectBoxStore.create();
  // Repositorio directo\
  final expenseRepository = ExpenseRepository(database);
  final incomeRepository = IncomeRepository(database);
  final goalRepository = GoalRepository(database);
  final debtRepository = DebtRepository(database);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseViewModel(expenseRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => IncomeViewModel(incomeRepository),
        ),

        ChangeNotifierProxyProvider2<ExpenseViewModel, IncomeViewModel, DashboardViewModel>(
          create: (context) => DashboardViewModel(
            expenseViewModel: context.read<ExpenseViewModel>(),
            incomeViewModel: context.read<IncomeViewModel>(),
          ),
          update: (context, expenseVM, incomeVM, previousDashboardVM) =>
              DashboardViewModel(expenseViewModel: expenseVM, incomeViewModel: incomeVM),
        ),

        ChangeNotifierProvider(
          create: (_) => GoalsViewModel(goalRepository: goalRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => CalendarViewModel(),
        ),

        ChangeNotifierProxyProvider<DashboardViewModel, AnalyticsViewModel>(
          create: (context) => AnalyticsViewModel(dashboardViewModel: context.read<DashboardViewModel>()),
          update: (context, dashboardVM, previous) => AnalyticsViewModel(dashboardViewModel: dashboardVM),
        ),

        ChangeNotifierProxyProvider<DashboardViewModel, StatisticsViewModel>(
          create: (context) => StatisticsViewModel(dashboardViewModel: context.read<DashboardViewModel>()),
          update: (context, dashboardVM, previous) => StatisticsViewModel(dashboardViewModel: dashboardVM),
        ),

        ChangeNotifierProvider(
          create: (_) => DebtViewModel(debtRepository: debtRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => PreferencesViewModel()
        ),
      ],
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    
    final prefsVM = context.watch<PreferencesViewModel>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: prefsVM.themeMode,
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.premiumDarkTheme,
      home: showOnboarding ? const OnboardingScreen() : const MainNavigationScreen(),
    );
  }
}