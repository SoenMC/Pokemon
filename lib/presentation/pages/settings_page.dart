import 'package:flutter/material.dart'; // Import Flutter Material package for UI widgets
import 'package:flutter_bloc/flutter_bloc.dart';// Import Flutter Bloc package for state management
import '../cubits/theme_cubit.dart';// Import the ThemeCubit to manage dark/light theme

// Stateless widget representing the settings screen
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Builds the UI of the settings page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with the title "Settings"
      appBar: AppBar(title: const Text('Settings')),
      // Body contains a scrollable list of settings
      body: ListView(
        children: [
          // BlocBuilder listens to ThemeCubit to rebuild when theme changes
          BlocBuilder<ThemeCubit, bool>(
            builder: (context, isDark) {
              return SwitchListTile(
                // Label for the switch
                title: const Text('Dark Mode'),
                // Switch value: true if dark mode, false if light mode
                value: isDark,
                // Toggle dark/light mode when switch is changed
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
              );
            },
          ),
        ],
      ),
    );
  }
}
