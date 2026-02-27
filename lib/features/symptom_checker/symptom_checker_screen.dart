import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/providers.dart';
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
        const SnackBar(content: Text('Please add at least one symptom')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    final aiService = ref.read(aiServiceProvider);
    final result = await aiService.analyzeSymptoms(_selectedSymptoms);

    // Save to records
    final record = SymptomRecord(
      id: const Uuid().v4(),
      userId: 'current_user', // Replace with actual user ID
      symptoms: _selectedSymptoms,
      aiDiagnosis: result['possible_conditions']?.join(', '),
      severity: result['severity'] ?? 'normal',
      recommendedAction: result['recommendation'],
      possibleConditions: result['possible_conditions'] != null
          ? List<String>.from(result['possible_conditions'])
          : null,
      timestamp: DateTime.now(),
    );

    ref.read(symptomRecordsProvider.notifier).addRecord(record);

    setState(() {
      _isAnalyzing = false;
      _analysisResult = result;
    });
  }

  void _reset() {
    setState(() {
      _selectedSymptoms.clear();
      _analysisResult = null;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Symptom Checker'),
        actions: [
          const SyncStatusAction(),
          if (_selectedSymptoms.isNotEmpty || _analysisResult != null)
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
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Describe your symptoms and our AI will help identify possible conditions.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add Symptoms
            Text(
              'What symptoms are you experiencing?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Input field
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Common symptoms chips
            Text(
              'Common symptoms:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
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

            // Selected symptoms
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

              // Analyze button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeSymptoms,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Symptoms'),
                ),
              ),
            ],

            // Results
            if (_analysisResult != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Severity
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getSeverityColor(_analysisResult!['severity']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getSeverityColor(_analysisResult!['severity']),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getSeverityIcon(_analysisResult!['severity']),
                      color: _getSeverityColor(_analysisResult!['severity']),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Severity: ${_analysisResult!['severity'].toString().toUpperCase()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getSeverityColor(_analysisResult!['severity']),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _analysisResult!['recommendation'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Possible conditions
              if (_analysisResult!['possible_conditions'] != null &&
                  (_analysisResult!['possible_conditions'] as List).isNotEmpty) ...[
                Text(
                  'Possible Conditions:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(_analysisResult!['possible_conditions'] as List).map((condition) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services, size: 18, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(condition),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 24),

              // Action buttons
              if (_analysisResult!['severity'] == 'emergency')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to emergency
                    },
                    icon: const Icon(Icons.emergency),
                    label: const Text('Call Emergency Services'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                    ),
                  ),
                ),
              if (_analysisResult!['severity'] == 'urgent')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to providers
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Find a Doctor'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
