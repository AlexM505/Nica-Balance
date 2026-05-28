import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nica_balance/core/theme/app_theme.dart';
import 'package:nica_balance/presentation/calendar/views/calendar_history_view.dart';
import 'package:nica_balance/presentation/goals/views/goals_list_view.dart';
import 'package:nica_balance/presentation/home/views/home_dashboard_view.dart';
import 'package:nica_balance/presentation/income/views/income_form_screen.dart';
import '../../expenses/views/expense_form_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _isMenuOpen = false;
  

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // _views[_selectedIndex],

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250), // Transición rápida y fluida
            switchInCurve: Curves.easeOutCubic,         // Curva suave al entrar
            switchOutCurve: Curves.easeInCubic,          // Curva suave al salir
            // Modificamos el constructor de transición para que haga un Fade + Scale premium
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.75, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            // Es indispensable pasarle una Key única basada en el índice para que reconozca el cambio de pantalla
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _views[_selectedIndex],
            ),
          ),


          // Capa de desenfoque con transición suave al abrir menú
          AnimatedOpacity(
            opacity: _isMenuOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isMenuOpen
                ? GestureDetector(
                    onTap: _toggleMenu,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(color: Colors.black.withOpacity(0.5)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Opciones flotantes con animación de elevación y opacidad
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
        color: AppTheme.surfaceColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
                
                // Divisor sutil vertical para separar el menú del botón de acción
                Container(
                  height: 32,
                  width: 1.5,
                  color: AppTheme.borderColor.withOpacity(0.5),
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
          // INDICADOR DE SELECCIÓN CORREGIDO: Usamos AnimatedScale para evitar anchos/altos negativos
          AnimatedScale(
            scale: isSelected ? 1.0 : 0.0, // Escala de 0% a 100%
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack, // El efecto elástico/rebote ahora es 100% seguro aquí
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // El ícono cambia de color con transiciones suaves
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
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
      turns: _isMenuOpen ? 0.125 : 0, // Convierte de + a x rotando 45 grados
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
                color: (_isMenuOpen ? const Color(0xFFEF4444) : AppTheme.primaryColor).withOpacity(0.3),
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
      curve: Curves.fastOutSlowIn, // Animación de aceleración y frenado natural
      bottom: _isMenuOpen ? 104 : 20, // Sube desde la barra de navegación
      right: 38, // Centrado perfectamente sobre el botón derecho
      child: AnimatedOpacity(
        opacity: _isMenuOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: 
        // _isMenuOpen
        //     ? 
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
            // : const SizedBox.shrink(),
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
        // Etiqueta flotante
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor, width: 1),
          ),
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        // Botón Circular de Acción
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.6), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
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