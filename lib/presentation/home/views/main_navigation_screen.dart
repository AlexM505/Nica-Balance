import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nica_balance/core/services/bio_auth_service.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/calendar/views/calendar_history_view.dart';
import 'package:nica_balance/presentation/goals/views/goals_list_view.dart';
import 'package:nica_balance/presentation/home/views/home_dashboard_view.dart';
import 'package:nica_balance/presentation/income/views/income_form_screen.dart';
import 'package:nica_balance/presentation/settings/viewmodels/preferences_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../expenses/views/expense_form_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver{
  int _selectedIndex = 0;
  bool _isMenuOpen = false;
  bool _isAuthenticated = true;

  final List<Widget> _views = [
    const HomeDashboardView(),
    const CalendarHistoryView(),
    const GoalsListView()
  ];

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();

    WidgetsBinding.instance.addObserver(this);
    
    final prefsVM = context.read<PreferencesViewModel>();
    if (prefsVM.biometricAuth) {
      _isAuthenticated = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    final prefsVM = context.read<PreferencesViewModel>();
    if (state == AppLifecycleState.resumed) {
      if (prefsVM.biometricAuth) {
        setState(() {
          _isAuthenticated = false;
        });
      }
    }
  }

  /// Método manual disparado únicamente por la acción táctil del usuario
  Future<void> _executeManualDesblock() async {
    final prefsVM = context.read<PreferencesViewModel>();
    final success = await BioAuthService.authenticate();
    if (success) {
      await prefsVM.toggleBiometricAuth(false);
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final prefsVM = context.watch<PreferencesViewModel>();

    if (!prefsVM.biometricAuth && !_isAuthenticated) {
      _isAuthenticated = true;
    }

    if (prefsVM.biometricAuth && _isAuthenticated) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            _isAuthenticated = false; 
          });
        }
      });
    }

    // Si requiere autenticación y no la ha superado, mostramos cortina de seguridad premium
    if (prefsVM.biometricAuth && !_isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppTheme.primaryColor.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 24),
              Text(
                'Aplicación Bloqueada',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usa tu huella o rostro para desbloquear',
                style: TextStyle(color: AppTheme.getTextSecondary(context), fontSize: 13),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                // LA CLAVE: El sensor se abre SOLO si presionan este botón
                onPressed: _executeManualDesblock, 
                icon: const Icon(Icons.fingerprint_rounded, size: 24),
                label: const Text(
                  'Desbloquear con Huella',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _views[_selectedIndex],
            ),
          ),

          AnimatedOpacity(
            opacity: _isMenuOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isMenuOpen
                ? GestureDetector(
                    onTap: _toggleMenu,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(color: Colors.black.withValues(alpha: 0.5)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          _buildAnimatedQuickMenu(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  // Diseño Asimétrico del Bottom Navigation Bar con Íconos Limpios
  Widget _buildCustomBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.getBorderColor(context).withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Grupo de Íconos del Menú (Alineados a la izquierda y centro)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(index: 0, icon: Icons.grid_view_rounded),
                      _buildNavItem(index: 1, icon: Icons.calendar_today_rounded),
                      _buildNavItem(index: 2, icon: Icons.track_changes_rounded),
                    ],
                  ),
                ),
                
                Container(
                  height: 32,
                  width: 1.5,
                  color: AppTheme.getBorderColor(context).withValues(alpha: 0.5),
                ),
                const SizedBox(width: 12),

                // Botón de acción reubicado al extremo derecho
                _buildActionMenuButton(),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Item de navegación optimizado con animación de burbuja indicadora
  Widget _buildNavItem({required int index, required IconData icon}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (_isMenuOpen) _toggleMenu();
        setState(() => _selectedIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Botón Gatillo con rotación fluida integrado en la misma barra
  Widget _buildActionMenuButton() {
    return AnimatedRotation(
      turns: _isMenuOpen ? 0.125 : 0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isMenuOpen ? const Color(0xFFEF4444) : AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_isMenuOpen ? const Color(0xFFEF4444) : AppTheme.primaryColor).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.add, size: 26, color: Colors.white),
        ),
      ),
    );
  }

  // Menú desplegable animado en vertical sobre el botón derecho
  Widget _buildAnimatedQuickMenu() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      bottom: _isMenuOpen ? 104 : 20,
      right: 38,
      child: AnimatedOpacity(
        opacity: _isMenuOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: 
          IgnorePointer(
            ignoring: !_isMenuOpen,
            child: 
            Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildQuickActionButton(
                    label: 'Ingreso',
                    icon: Icons.call_received_rounded,
                    color: AppTheme.accentColor,
                    onTap: () {
                      _toggleMenu();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const IncomeFormScreen()), // Nueva navegación enlazada
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionButton(
                    label: 'Gasto',
                    icon: Icons.arrow_outward_rounded,
                    color: const Color(0xFFEF4444),
                    onTap: () {
                      _toggleMenu();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
                      );
                    },
                  ),
                ],
              )
          )
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
          ),
          child: Text(
            label,
            style: TextStyle(color: AppTheme.getTextPrimary(context), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ),
      ],
    );
  }
}