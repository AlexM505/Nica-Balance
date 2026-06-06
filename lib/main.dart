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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/objectbox_store.dart';
import 'data/repositories/expense_repository.dart';
import 'presentation/expenses/viewmodels/expense_viewmodel.dart';

void main() async {

  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Leemos si es la primera vez que se abre la app (por defecto será true si no existe la llave)
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

        ChangeNotifierProvider(
          create: (_) => DebtViewModel(debtRepository: debtRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.premiumDarkTheme,
        themeMode: ThemeMode.dark,
        home: showOnboarding ? const OnboardingScreen() :const MainNavigationScreen(),
      ),
    ),
  );
}