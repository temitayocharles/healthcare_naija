import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/sync_status_action.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = user == null || user.id.startsWith('guest_');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          const SyncStatusAction(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Guest User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.role ?? 'patient',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () async {
                      if (isGuest) {
                        context.go('/login');
                        return;
                      }
                      await ref.read(currentUserProvider.notifier).clearUser();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    child: Text(isGuest ? 'Sign In / Register' : 'Sign Out'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu Items
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.history,
              title: 'Medical History',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.bloodtype,
              title: 'Blood Type & Allergies',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.health_and_safety,
              title: 'Insurance Information',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.calendar_month,
              title: 'Appointment History',
              onTap: () => context.go('/appointments'),
            ),
            _MenuItem(
              icon: Icons.folder,
              title: 'Health Records',
              onTap: () => context.push('/records'),
            ),
            _MenuItem(
              icon: Icons.chat_bubble_outline,
              title: 'Chat with Caregiver',
              onTap: () => context.push('/chat'),
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.sync,
              title: 'Sync Diagnostics',
              onTap: () => context.push('/sync-diagnostics'),
            ),
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy & Security',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
