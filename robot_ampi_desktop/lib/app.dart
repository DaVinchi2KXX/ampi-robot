import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'features/connection/presentation/pages/connection_page.dart';
import 'features/control_panel/presentation/pages/control_panel_page.dart';
import 'features/joystick/presentation/pages/joystick_page.dart';
import 'features/animation_editor/presentation/pages/animation_editor_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'shared/theme/app_theme.dart';

class RobotAmPiApp extends StatelessWidget {
  const RobotAmPiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robot-AmPI Controller',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 1; // Start with Control Panel

  static const List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: Icon(Symbols.cable),
      label: 'Connection',
      selectedIcon: Icon(Symbols.cable, fill: 1),
    ),
    NavigationDestination(
      icon: Icon(Symbols.gamepad),
      label: 'Control',
      selectedIcon: Icon(Symbols.gamepad, fill: 1),
    ),
    NavigationDestination(
      icon: Icon(Symbols.joystick),
      label: 'Joystick',
      selectedIcon: Icon(Symbols.joystick, fill: 1),
    ),
    NavigationDestination(
      icon: Icon(Symbols.movie),
      label: 'Animation',
      selectedIcon: Icon(Symbols.movie, fill: 1),
    ),
    NavigationDestination(
      icon: Icon(Symbols.settings),
      label: 'Settings',
      selectedIcon: Icon(Symbols.settings, fill: 1),
    ),
  ];

  static const List<Widget> pages = [
    ConnectionPage(),
    ControlPanelPage(),
    JoystickPage(),
    AnimationEditorPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: destinations,
        backgroundColor: theme.colorScheme.surfaceContainerLow,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
