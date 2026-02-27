import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_env.dart';
import '../constants/app_constants.dart';

class AIService {
  static const String _openAiApiKey = AppEnv.openAiApiKey;
  static const String _baseUrl = AppEnv.openAiBaseUrl;
  static const String _model = AppEnv.openAiModel;
  static const bool _enableAiTriage = AppEnv.enableAiTriage;

  static const String safetyDisclaimer =
      'This tool provides triage guidance only and is not a medical diagnosis. '
      'If symptoms are severe, worsening, or you feel unsafe, seek immediate in-person care.';

  static const int _maxSymptomsPerRequest = 12;

  static const Set<String> _redFlagSymptoms = {
    'chest pain',
    'difficulty breathing',
    'shortness of breath',
    'fainting',
    'unconscious',
    'unresponsiveness',
    'severe bleeding',
    'stroke symptoms',
    'seizure',
    'suicidal thoughts',
  };

  static final Map<String, Map<String, dynamic>> _symptomDatabase = {
    'headache': {
      'conditions': ['Migraine', 'Tension Headache', 'Sinusitis', 'Dehydration'],
      'severity': 'normal',
      'recommendation': 'Hydrate and rest. Seek clinical care if symptoms persist or worsen.',
    },
    'fever': {
      'conditions': ['Viral Infection', 'Bacterial Infection', 'Malaria', 'Flu'],
      'severity': 'urgent',
      'recommendation':
          'Monitor temperature and seek clinical review if high fever persists.',
    },
    'cough': {
      'conditions': ['Common Cold', 'Flu', 'Bronchitis', 'Pneumonia'],
      'severity': 'normal',
      'recommendation':
          'Hydrate and monitor. Seek care for breathing issues, blood, or prolonged symptoms.',
    },
    'stomach pain': {
      'conditions': ['Indigestion', 'Food Poisoning', 'Gastritis', 'Appendicitis'],
      'severity': 'urgent',
      'recommendation': 'Seek urgent care if pain is severe, persistent, or associated with vomiting blood.',
    },
    'chest pain': {
      'conditions': ['Cardiac Emergency', 'Pulmonary Emergency', 'Acute Illness'],
      'severity': 'emergency',
      'recommendation': 'Call emergency services immediately and seek urgent in-person care.',
    },
    'difficulty breathing': {
      'conditions': ['Respiratory Emergency', 'Cardiac Emergency', 'Severe Infection'],
      'severity': 'emergency',
      'recommendation': 'Call emergency services immediately and seek urgent in-person care.',
    },
    'rash': {
      'conditions': ['Allergic Reaction', 'Dermatitis', 'Skin Infection'],
      'severity': 'normal',
      'recommendation': 'Monitor and seek care if rash is spreading, painful, or accompanied by fever.',
    },
    'nausea': {
      'conditions': ['Gastritis', 'Food-Related Illness', 'Migraine'],
      'severity': 'normal',
      'recommendation': 'Hydrate and monitor. Seek care for persistent or severe symptoms.',
    },
    'fatigue': {
      'conditions': ['Anemia', 'Infection', 'Metabolic Condition'],
      'severity': 'normal',
      'recommendation': 'Seek medical evaluation for prolonged fatigue.',
    },
    'body aches': {
      'conditions': ['Viral Illness', 'Inflammatory Condition', 'Systemic Infection'],
      'severity': 'urgent',
      'recommendation': 'Seek clinical review if severe or persistent, especially with fever.',
    },
    'sore throat': {
      'conditions': ['Upper Respiratory Infection', 'Pharyngitis', 'Tonsillitis'],
      'severity': 'normal',
      'recommendation': 'Hydrate and monitor. Seek care if swallowing is difficult or symptoms persist.',
    },
    'diarrhea': {
      'conditions': ['Gastroenteritis', 'Foodborne Illness', 'Infection'],
      'severity': 'urgent',
      'recommendation': 'Use oral rehydration and seek care for blood, dehydration, or persistent symptoms.',
    },
    'back pain': {
      'conditions': ['Musculoskeletal Strain', 'Nerve Irritation', 'Renal Cause'],
      'severity': 'normal',
      'recommendation': 'Seek care for severe pain, weakness, numbness, or persistent symptoms.',
    },
    'joint pain': {
      'conditions': ['Arthritis', 'Inflammatory Condition', 'Infection'],
      'severity': 'normal',
      'recommendation': 'Seek care if swollen, warm, severe, or persistent.',
    },
    'dizziness': {
      'conditions': ['Dehydration', 'Low Blood Pressure', 'Neurological/Cardiac Cause'],
      'severity': 'urgent',
      'recommendation':
          'Sit/lie down safely and seek urgent care if associated with chest pain, weakness, or fainting.',
    },
  };

  List<String> _normalizeSymptoms(List<String> symptoms) {
    final normalized = symptoms
        .map((s) => s.toLowerCase().trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return normalized.take(_maxSymptomsPerRequest).toList();
  }

  bool _containsRedFlag(List<String> symptoms) {
    for (final symptom in symptoms) {
      if (_redFlagSymptoms.contains(symptom)) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> _safeResponse({
    required List<String> possibleConditions,
    required String severity,
    required String recommendation,
    required bool isOffline,
    required List<String> matchedSymptoms,
    required bool redFlagTriggered,
  }) {
    return {
      'possible_conditions': possibleConditions,
      'severity': severity,
      'recommendation': recommendation,
      'is_offline': isOffline,
      'safety_disclaimer': safetyDisclaimer,
      'triage_only': true,
      'emergency_contacts': AppConstants.emergencyNumbers,
      'matched_symptoms': matchedSymptoms,
      'red_flag_triggered': redFlagTriggered,
    };
  }

  Map<String, dynamic> analyzeSymptomsLocal(List<String> symptoms) {
    final normalizedSymptoms = _normalizeSymptoms(symptoms);

    if (normalizedSymptoms.isEmpty) {
      return _safeResponse(
        possibleConditions: const <String>[],
        severity: 'normal',
        recommendation: 'No symptoms provided. If unwell, consult a licensed clinician.',
        isOffline: true,
        matchedSymptoms: const <String>[],
        redFlagTriggered: false,
      );
    }

    if (_containsRedFlag(normalizedSymptoms)) {
      return _safeResponse(
        possibleConditions: const <String>['Potential medical emergency'],
        severity: 'emergency',
        recommendation:
            'Red-flag symptoms detected. Call emergency services immediately and seek in-person care.',
        isOffline: true,
        matchedSymptoms: normalizedSymptoms,
        redFlagTriggered: true,
      );
    }

    final allConditions = <Map<String, dynamic>>[];
    var highestSeverity = 'normal';
    final matched = <String>[];

    for (final symptom in normalizedSymptoms) {
      final data = _symptomDatabase[symptom];
      if (data == null) {
        continue;
      }
      matched.add(symptom);
      final severity = data['severity'] as String;
      if (severity == 'urgent') {
        highestSeverity = 'urgent';
      }
      for (final condition in data['conditions'] as List<dynamic>) {
        allConditions.add({
          'condition': condition.toString(),
          'severity': severity,
        });
      }
    }

    if (matched.isEmpty) {
      return _safeResponse(
        possibleConditions: const <String>['Unrecognized symptom pattern'],
        severity: 'urgent',
        recommendation:
            'Symptoms are not recognized confidently. Seek licensed clinical evaluation soon.',
        isOffline: true,
        matchedSymptoms: normalizedSymptoms,
        redFlagTriggered: false,
      );
    }

    allConditions.sort((a, b) {
      const order = {'emergency': 0, 'urgent': 1, 'normal': 2};
      return (order[a['severity']] ?? 9).compareTo(order[b['severity']] ?? 9);
    });

    final uniqueConditions = <String>{};
    final filteredConditions = <String>[];
    for (final item in allConditions) {
      final c = item['condition'] as String;
      if (uniqueConditions.add(c)) {
        filteredConditions.add(c);
      }
      if (filteredConditions.length >= 5) {
        break;
      }
    }

    final recommendation = highestSeverity == 'urgent'
        ? 'Urgent review recommended. If symptoms worsen, seek emergency care.'
        : 'Monitor symptoms and consult a clinician if they persist or worsen.';

    return _safeResponse(
      possibleConditions: filteredConditions,
      severity: highestSeverity,
      recommendation: recommendation,
      isOffline: true,
      matchedSymptoms: matched,
      redFlagTriggered: false,
    );
  }

  Future<Map<String, dynamic>> analyzeSymptomsAI(List<String> symptoms) async {
    final normalizedSymptoms = _normalizeSymptoms(symptoms);

    if (_containsRedFlag(normalizedSymptoms)) {
      return analyzeSymptomsLocal(normalizedSymptoms);
    }

    if (!_enableAiTriage || _openAiApiKey.isEmpty) {
      return analyzeSymptomsLocal(normalizedSymptoms);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a triage assistant. Do not diagnose. Return JSON with keys '
                      'possible_conditions (array max 5), severity (emergency|urgent|normal), recommendation (string).',
            },
            {
              'role': 'user',
              'content': 'Symptoms: ${normalizedSymptoms.join(', ')}',
            }
          ],
          'temperature': 0.1,
        }),
      );

      if (response.statusCode != 200) {
        return analyzeSymptomsLocal(normalizedSymptoms);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          ((data['choices'] as List<dynamic>).first as Map<String, dynamic>)['message']['content'];
      final parsed = jsonDecode(content as String) as Map<String, dynamic>;

      final severityRaw = parsed['severity']?.toString().toLowerCase() ?? 'normal';
      final safeSeverity = {'emergency', 'urgent', 'normal'}.contains(severityRaw)
          ? severityRaw
          : 'normal';
      final conditions = parsed['possible_conditions'] is List
          ? List<String>.from(parsed['possible_conditions'] as List<dynamic>)
          : <String>[];

      return _safeResponse(
        possibleConditions: conditions.take(5).toList(),
        severity: safeSeverity,
        recommendation: parsed['recommendation']?.toString() ??
            'Consult a licensed clinician for further evaluation.',
        isOffline: false,
        matchedSymptoms: normalizedSymptoms,
        redFlagTriggered: false,
      );
    } catch (_) {
      return analyzeSymptomsLocal(normalizedSymptoms);
    }
  }

  Future<Map<String, dynamic>> analyzeSymptoms(
    List<String> symptoms, {
    bool forceOffline = false,
  }) async {
    final normalizedSymptoms = _normalizeSymptoms(symptoms);
    if (forceOffline) {
      return analyzeSymptomsLocal(normalizedSymptoms);
    }
    return analyzeSymptomsAI(normalizedSymptoms);
  }

  List<String> getKnownSymptoms() {
    return _symptomDatabase.keys.toList()..sort();
  }
}
