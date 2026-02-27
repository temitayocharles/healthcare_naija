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
  static const Map<String, String> emergencyNumbers = {
    'Police': '199',
    'Fire Service': '199',
    'Ambulance': '199',
    'FRSC': '122',
    'Lagos Emergency': '767',
    'Abuja Emergency': '112',
  };

  // Cache Keys
  static const String userCacheKey = 'cached_user';
  static const String appointmentsCacheKey = 'cached_appointments';
  static const String symptomHistoryCacheKey = 'cached_symptoms';
  static const String providersCacheKey = 'cached_providers';
}
