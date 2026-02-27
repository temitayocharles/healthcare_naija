// App Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Nigeria Health Care';
  static const String appVersion = '1.0.0';

  // Colors (Healthcare-appropriate for Nigeria)
  static const int primaryColor = 0xFF00897B; // Teal
  static const int secondaryColor = 0xFFFF6F00; // Orange
  static const int accentColor = 0xFFFFFFFF; // White
  static const int errorColor = 0xFFD32F2F; // Red
  static const int successColor = 0xFF388E3C; // Green
  static const int warningColor = 0xFFFFA000; // Amber

  // Severity Levels
  static const String severityEmergency = 'emergency';
  static const String severityUrgent = 'urgent';
  static const String severityNormal = 'normal';

  // User Roles
  static const String rolePatient = 'patient';
  static const String rolePhysician = 'physician';
  static const String roleNurse = 'nurse';
  static const String roleCaregiver = 'caregiver';
  static const String rolePharmacy = 'pharmacy';

  // Provider Types
  static const List<String> providerTypes = [
    'Physician',
    'Nurse',
    'Caregiver',
    'Pharmacy',
    'Hospital',
  ];

  // Nigerian States
  static const List<String> nigerianStates = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
    'FCT',
  ];

  // Emergency Numbers (Nigeria)
  // Note: state-level numbers vary and may change; use as quick-call fallback.
  static const Map<String, String> emergencyNumbers = {
    'National Emergency': '112',
    'Police': '112',
    'Fire Service': '112',
    'Ambulance': '112',
    'FRSC': '122',
    'NEMA': '112',
    'Abia Emergency': '112',
    'Adamawa Emergency': '112',
    'Akwa Ibom Emergency': '112',
    'Anambra Emergency': '112',
    'Bauchi Emergency': '112',
    'Bayelsa Emergency': '112',
    'Benue Emergency': '112',
    'Borno Emergency': '112',
    'Cross River Emergency': '112',
    'Delta Emergency': '112',
    'Ebonyi Emergency': '112',
    'Edo Emergency': '112',
    'Ekiti Emergency': '112',
    'Enugu Emergency': '112',
    'Gombe Emergency': '112',
    'Imo Emergency': '112',
    'Jigawa Emergency': '112',
    'Kaduna Emergency': '112',
    'Kano Emergency': '112',
    'Katsina Emergency': '112',
    'Kebbi Emergency': '112',
    'Kogi Emergency': '112',
    'Kwara Emergency': '112',
    'Lagos Emergency': '112',
    'Nasarawa Emergency': '112',
    'Niger Emergency': '112',
    'Ogun Emergency': '112',
    'Ondo Emergency': '112',
    'Osun Emergency': '112',
    'Oyo Emergency': '112',
    'Plateau Emergency': '112',
    'Rivers Emergency': '112',
    'Sokoto Emergency': '112',
    'Taraba Emergency': '112',
    'Yobe Emergency': '112',
    'Zamfara Emergency': '112',
    'FCT Emergency': '112',
  };

  // Cache Keys
  static const String userCacheKey = 'cached_user';
  static const String appointmentsCacheKey = 'cached_appointments';
  static const String symptomHistoryCacheKey = 'cached_symptoms';
  static const String providersCacheKey = 'cached_providers';
}
