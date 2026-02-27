import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/sync_status_action.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Services'),
        backgroundColor: AppTheme.errorColor,
        actions: const [
          SyncStatusAction(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'In case of medical emergency',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stay calm and call the appropriate emergency service immediately.',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Numbers
            Text(
              'Emergency Numbers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use these as quick-call references. Emergency routing coverage may vary by network and location.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            ...AppConstants.emergencyNumbers.entries.map((entry) {
              return _EmergencyCard(
                title: entry.key,
                number: entry.value,
                onCall: () => _makeCall(entry.value),
              );
            }),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.local_hospital,
                    label: 'Find Hospital',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.local_pharmacy,
                    label: 'Find Pharmacy',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.directions_car,
                    label: 'Ambulance',
                    onTap: () => _makeCall('199'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.person,
                    label: 'Emergency Contact',
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // First Aid Tips
            Text(
              'First Aid Tips',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _FirstAidCard(
              title: 'Unconscious Person',
              steps: '1. Check responsiveness\n2. Call for help\n3. Place in recovery position\n4. Monitor breathing',
            ),
            _FirstAidCard(
              title: 'Severe Bleeding',
              steps: '1. Apply direct pressure\n2. Elevate the wound\n3. Do not remove blood-soaked cloth\n4. Call emergency',
            ),
            _FirstAidCard(
              title: 'Choking',
              steps: '1. Encourage coughing\n2. Back blows\n3. Heimlich maneuver\n4. Call emergency if fails',
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final String title;
  final String number;
  final VoidCallback onCall;

  const _EmergencyCard({
    required this.title,
    required this.number,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.phone, color: AppTheme.errorColor),
        ),
        title: Text(title),
        subtitle: Text(number),
        trailing: ElevatedButton(
          onPressed: onCall,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
          ),
          child: const Text('Call'),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        foregroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _FirstAidCard extends StatelessWidget {
  final String title;
  final String steps;

  const _FirstAidCard({
    required this.title,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(title),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(steps),
          ),
        ],
      ),
    );
  }
}
