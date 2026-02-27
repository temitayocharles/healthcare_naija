import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // For external AI API (OpenAI/Anthropic) - configure with your API key
  static const String? _openAiApiKey = null; // Set your API key here
  static const String _baseUrl = 'https://api.openai.com/v1';

  // Local symptom database for offline mode
  static final Map<String, Map<String, dynamic>> _symptomDatabase = {
    'headache': {
      'conditions': ['Migraine', 'Tension Headache', 'Sinusitis', 'Dehydration'],
      'severity': 'normal',
      'recommendation': 'Rest, hydration, over-the-counter pain reliever. See a doctor if persists >3 days.',
    },
    'fever': {
      'conditions': ['Viral Infection', 'Bacterial Infection', 'Malaria', 'Flu'],
      'severity': 'urgent',
      'recommendation': 'Monitor temperature, take paracetamol. Seek medical attention if >39°C or persists >2 days.',
    },
    'cough': {
      'conditions': ['Common Cold', 'Flu', 'Bronchitis', 'Pneumonia', 'COVID-19'],
      'severity': 'normal',
      'recommendation': 'Stay hydrated, rest. See doctor if cough persists >2 weeks or with blood.',
    },
    'stomach pain': {
      'conditions': ['Indigestion', 'Food Poisoning', 'Gastritis', 'Appendicitis'],
      'severity': 'urgent',
      'recommendation': 'Rest, light meals. Seek immediate care if severe or with vomiting blood.',
    },
    'chest pain': {
      'conditions': ['Heart Attack', 'Angina', 'Acid Reflux', 'Panic Attack'],
      'severity': 'emergency',
      'recommendation': 'CALL EMERGENCY immediately. Chest pain can be life-threatening.',
    },
    'difficulty breathing': {
      'conditions': ['Asthma', 'Pneumonia', 'Heart Failure', 'COVID-19', 'Allergic Reaction'],
      'severity': 'emergency',
      'recommendation': 'CALL EMERGENCY immediately. This is life-threatening.',
    },
    'rash': {
      'conditions': ['Allergic Reaction', 'Eczema', 'Heat Rash', 'Infection'],
      'severity': 'normal',
      'recommendation': 'Avoid scratching, keep clean. See doctor if spreading or with fever.',
    },
    'nausea': {
      'conditions': ['Food Poisoning', 'Pregnancy', 'Migraine', 'Gastritis'],
      'severity': 'normal',
      'recommendation': 'Rest, small sips of water, bland diet. See doctor if persistent.',
    },
    'fatigue': {
      'conditions': ['Anemia', 'Depression', 'Thyroid', 'Chronic Fatigue', 'Malaria'],
      'severity': 'normal',
      'recommendation': 'Rest, proper nutrition. See doctor if persistent >2 weeks.',
    },
    'body aches': {
      'conditions': ['Flu', 'Malaria', 'Dengue', 'Muscle Strain'],
      'severity': 'urgent',
      'recommendation': 'Rest, hydration. See doctor if with high fever or severe symptoms.',
    },
    'sore throat': {
      'conditions': ['Strep Throat', 'Cold', 'Flu', 'Tonsillitis'],
      'severity': 'normal',
      'recommendation': 'Warm salt water, rest. See doctor if difficulty swallowing or >3 days.',
    },
    'diarrhea': {
      'conditions': ['Food Poisoning', 'Stomach Flu', 'Bacterial Infection'],
      'severity': 'urgent',
      'recommendation': 'Stay hydrated, ORS solution. Seek care if blood in stool or dehydration.',
    },
    'back pain': {
      'conditions': ['Muscle Strain', 'Kidney Stone', 'Herniated Disc'],
      'severity': 'normal',
      'recommendation': 'Rest, heat compress, gentle stretching. See doctor if severe or with numbness.',
    },
    'joint pain': {
      'conditions': ['Arthritis', 'Gout', 'Injury', 'Infection'],
      'severity': 'normal',
      'recommendation': 'Rest, ice, anti-inflammatory. See doctor if swollen or severe.',
    },
    'dizziness': {
      'conditions': ['Low Blood Sugar', 'Dehydration', 'Vertigo', 'Anemia'],
      'severity': 'urgent',
      'recommendation': 'Sit down, hydrate. Seek immediate care if with chest pain or fainting.',
    },
  };

  // Analyze symptoms using local database (works offline)
  Map<String, dynamic> analyzeSymptomsLocal(List<String> symptoms) {
    List<Map<String, dynamic>> allConditions = [];
    String highestSeverity = 'normal';

    for (String symptom in symptoms) {
      final normalizedSymptom = symptom.toLowerCase().trim();
      if (_symptomDatabase.containsKey(normalizedSymptom)) {
        final data = _symptomDatabase[normalizedSymptom]!;
        final severity = data['severity'] as String;

        // Track highest severity
        if (severity == 'emergency') {
          highestSeverity = 'emergency';
        } else if (severity == 'urgent' && highestSeverity != 'emergency') {
          highestSeverity = 'urgent';
        }

        for (String condition in data['conditions']) {
          allConditions.add({
            'condition': condition,
            'matched_symptom': normalizedSymptom,
            'severity': severity,
          });
        }
      }
    }

    // Sort by severity and remove duplicates
    allConditions.sort((a, b) {
      final severityOrder = {'emergency': 0, 'urgent': 1, 'normal': 2};
      return severityOrder[a['severity']]!.compareTo(severityOrder[b['severity']]!);
    });

    // Get unique conditions
    final uniqueConditions = <String>{};
    final filteredConditions = <Map<String, dynamic>>[];
    for (var c in allConditions) {
      if (uniqueConditions.add(c['condition'])) {
        filteredConditions.add(c);
      }
    }

    String recommendation;
    if (highestSeverity == 'emergency') {
      recommendation = 'IMMEDIATE MEDICAL ATTENTION REQUIRED. Call emergency services or go to nearest hospital immediately.';
    } else if (highestSeverity == 'urgent') {
      recommendation = 'Schedule a doctor appointment soon. Monitor symptoms closely.';
    } else {
      recommendation = 'Rest and monitor. Consult a doctor if symptoms worsen or persist.';
    }

    return {
      'possible_conditions': filteredConditions.take(5).map((c) => c['condition']).toList(),
      'severity': highestSeverity,
      'recommendation': recommendation,
      'is_offline': true,
    };
  }

  // Analyze symptoms using external AI (when online)
  Future<Map<String, dynamic>> analyzeSymptomsAI(List<String> symptoms) async {
    if (_openAiApiKey == null) {
      // Fallback to local if no API key
      return analyzeSymptomsLocal(symptoms);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a medical symptom analyzer. Analyze the symptoms and provide: 1) Possible conditions 2) Severity level (emergency, urgent, normal) 3) Recommended action. Respond in JSON format: {"possible_conditions": [], "severity": "", "recommendation": ""}',
            },
            {
              'role': 'user',
              'content': 'Patient symptoms: ${symptoms.join(", ")}',
            }
          ],
          'temperature': 0.3,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        // Parse JSON from response
        final parsed = jsonDecode(content);
        return {
          ...parsed,
          'is_offline': false,
        };
      } else {
        return analyzeSymptomsLocal(symptoms);
      }
    } catch (e) {
      // Fallback to local on error
      return analyzeSymptomsLocal(symptoms);
    }
  }

  // Main analysis method - uses AI when online, local when offline
  Future<Map<String, dynamic>> analyzeSymptoms(
    List<String> symptoms, {
    bool forceOffline = false,
  }) async {
    if (forceOffline) {
      return analyzeSymptomsLocal(symptoms);
    }
    return analyzeSymptomsAI(symptoms);
  }

  // Get list of all known symptoms
  List<String> getKnownSymptoms() {
    return _symptomDatabase.keys.toList()..sort();
  }
}
