import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BlocBuilder<ThemeCubit, bool>(
            builder: (context, isDark) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (_) => context.read<ThemeCubit>().toggle(),
              );
            },
          ),
        ],
      ),
    );
  }
}