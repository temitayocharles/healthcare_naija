import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_illustration.dart';
import '../../widgets/healthcare_hero_banner.dart';
import '../../widgets/sync_status_action.dart';

class TelemedicineScreen extends ConsumerWidget {
  const TelemedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemedicine'),
        actions: const [SyncStatusAction()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            const HealthcareHeroBanner(
              title: 'Virtual Clinical Visits',
              subtitle:
                  'Secure remote consultations with verified healthcare providers.',
              icon: Icons.video_camera_front,
              height: 160,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.video_call, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Video Consultation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect with doctors remotely through video call. Get medical advice from the comfort of your home.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // How it works
            Text(
              'How It Works',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _StepCard(
              number: '1',
              title: 'Choose a Doctor',
              description: 'Select from our verified healthcare providers',
            ),
            _StepCard(
              number: '2',
              title: 'Book a Time',
              description: 'Schedule a video consultation at your convenience',
            ),
            _StepCard(
              number: '3',
              title: 'Start Call',
              description: 'Join the video call at the scheduled time',
            ),
            _StepCard(
              number: '4',
              title: 'Get Prescription',
              description: 'Receive your prescription digitally',
            ),
            const SizedBox(height: 24),

            // Features
            Text(
              'Features',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeatureChip(icon: Icons.videocam, label: 'HD Video'),
                _FeatureChip(icon: Icons.mic, label: 'Audio'),
                _FeatureChip(icon: Icons.chat, label: 'Chat'),
                _FeatureChip(icon: Icons.description, label: 'E-Prescription'),
              ],
            ),
            const SizedBox(height: 24),

            // Start consultation button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to provider selection
                },
                icon: const Icon(Icons.video_call),
                label: const Text('Start Video Consultation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent consultations
            Text(
              'Recent Consultations',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  const AppIllustration(
                    asset: 'assets/illustrations/telemedicine_consult.svg',
                    height: 96,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No recent consultations',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(number, style: const TextStyle(color: Colors.white)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}
