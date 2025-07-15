import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

class SettingsButton extends ConsumerWidget {
  final bool showSignOut;
  final VoidCallback? onSettingsTap;

  const SettingsButton({
    super.key,
    this.showSignOut = true,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'settings') {
            if (onSettingsTap != null) {
              onSettingsTap!();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming Soon!')),
              );
            }
          } else if (value == 'signout' && showSignOut) {
            await ref.read(authProvider.notifier).signOut();
            if (context.mounted) {
              context.go('/onboarding');
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings),
                SizedBox(width: 8),
                Text('Settings'),
              ],
            ),
          ),
          if (showSignOut)
            const PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
        ],
        child: Icon(
          Icons.settings,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
} 