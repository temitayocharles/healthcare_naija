import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../models/symptom_record.dart';
import '../../widgets/sync_status_action.dart';

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends ConsumerState<SymptomCheckerScreen> {
  final _symptomController = TextEditingController();
  final List<String> _selectedSymptoms = [];
  bool _isAnalyzing = false;
  bool _consentChecked = false;
  Map<String, dynamic>? _analysisResult;

  final List<String> _commonSymptoms = [
    'Headache',
    'Fever',
    'Cough',
    'Stomach pain',
    'Chest pain',
    'Difficulty breathing',
    'Rash',
    'Nausea',
    'Fatigue',
    'Body aches',
    'Sore throat',
    'Diarrhea',
    'Back pain',
    'Joint pain',
    'Dizziness',
  ];

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  void _addSymptom(String symptom) {
    final normalized = symptom.toLowerCase().trim();
    if (normalized.isNotEmpty && !_selectedSymptoms.contains(normalized)) {
      setState(() {
        _selectedSymptoms.add(normalized);
        _symptomController.clear();
      });
    }
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
    });
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one symptom.')),
      );
      return;
    }

    if (!_consentChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm the triage safety notice before continuing.'),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    final aiService = ref.read(aiServiceProvider);
    final result = await aiService.analyzeSymptoms(_selectedSymptoms);

    final user = ref.read(currentUserProvider);
    final record = SymptomRecord(
      id: const Uuid().v4(),
      userId: user?.id ?? 'guest_user',
      symptoms: _selectedSymptoms,
      aiDiagnosis: result['possible_conditions']?.join(', '),
      severity: result['severity']?.toString() ?? 'normal',
      recommendedAction: result['recommendation']?.toString(),
      possibleConditions: result['possible_conditions'] != null
          ? List<String>.from(result['possible_conditions'] as List<dynamic>)
          : null,
      timestamp: DateTime.now(),
    );

    ref.read(symptomRecordsProvider.notifier).addRecord(record);
    await ref.read(symptomRepositoryProvider).create(record);

    setState(() {
      _isAnalyzing = false;
      _analysisResult = result;
    });
  }

  void _reset() {
    setState(() {
      _selectedSymptoms.clear();
      _analysisResult = null;
      _consentChecked = false;
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'emergency':
        return AppTheme.errorColor;
      case 'urgent':
        return AppTheme.warningColor;
      default:
        return AppTheme.successColor;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'emergency':
        return Icons.warning;
      case 'urgent':
        return Icons.priority_high;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final analysis = _analysisResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Triage'),
        actions: [
          const SyncStatusAction(),
          if (_selectedSymptoms.isNotEmpty || analysis != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text(
                        'Safety Notice',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This feature is triage guidance only and does not provide medical diagnosis. '
                    'For severe symptoms, use emergency care immediately.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  CheckboxListTile(
                    value: _consentChecked,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I understand and want triage guidance.'),
                    onChanged: (v) => setState(() => _consentChecked = v ?? false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What symptoms are you experiencing?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _symptomController,
              decoration: InputDecoration(
                hintText: 'Type a symptom...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addSymptom(_symptomController.text),
                ),
              ),
              onSubmitted: _addSymptom,
            ),
            const SizedBox(height: 16),
            Text(
              'Common symptoms:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((symptom) {
                return FilterChip(
                  label: Text(symptom),
                  selected: _selectedSymptoms.contains(symptom.toLowerCase()),
                  onSelected: (selected) {
                    if (selected) {
                      _addSymptom(symptom.toLowerCase());
                    } else {
                      _removeSymptom(symptom.toLowerCase());
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            if (_selectedSymptoms.isNotEmpty) ...[
              Text(
                'Selected symptoms:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedSymptoms.map((symptom) {
                  return Chip(
                    label: Text(
                      symptom[0].toUpperCase() + symptom.substring(1),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppTheme.primaryColor,
                    deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () => _removeSymptom(symptom),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeSymptoms,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(_isAnalyzing ? 'Analyzing...' : 'Run Triage Check'),
                ),
              ),
            ],
            if (analysis != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getSeverityColor(analysis['severity']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getSeverityColor(analysis['severity'])),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSeverityIcon(analysis['severity']),
                      color: _getSeverityColor(analysis['severity']),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Triage urgency: ${analysis['severity'].toString().toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getSeverityColor(analysis['severity']),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(analysis['recommendation']?.toString() ?? ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                analysis['safety_disclaimer']?.toString() ?? '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
              ),
              const SizedBox(height: 16),
              if (analysis['possible_conditions'] != null &&
                  (analysis['possible_conditions'] as List).isNotEmpty) ...[
                Text(
                  'Potential causes (non-diagnostic):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...((analysis['possible_conditions'] as List).cast<String>()).map((condition) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services, size: 18, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(condition)),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              if (analysis['severity'] == 'emergency')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/emergency'),
                    icon: const Icon(Icons.emergency),
                    label: const Text('Open Emergency Services'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
