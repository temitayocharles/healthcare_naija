class NigeriaUtils {
  // Nigerian states with major cities
  static const Map<String, List<String>> statesAndLGAs = {
    'Lagos': ['Alimosho', 'Ajeromi-Ifelodun', 'Kosofe', 'Mushin', 'Oshodi-Isolo', 'Ikeja', 'Surulere', 'Apapa', 'Lagos Island', 'Lagos Mainland', 'Eti-Osa', 'Ojo', 'Badagry', 'Ikorodu', 'Epe', 'Ibeju-Lekki'],
    'Abuja': ['Abaji', 'Abuja Municipal', 'Gwagwalada', 'Kuje', 'Kwali', 'Bwari'],
    'Oyo': ['Ibadan North', 'Ibadan North-East', 'Ibadan South-West', 'Ibadan South-East', 'Oyo', 'Ogbomoso North', 'Ogbomoso South', 'Saki East', 'Saki West', 'Iseyin', 'Kishi'],
    'Rivers': ['Port Harcourt', 'Obio-Akpor', 'Okrika', 'Ogu-Bolo', 'Eleme', 'Tai', 'Gokana', 'Khana', 'Oyigbo', 'Afam', 'Etche', 'Omuma'],
    'Delta': ['Warri', 'Uvwie', 'Udu', 'Okpe', 'Sapele', 'Ethiope West', 'Ethiope East', 'Ika North-East', 'Ika South-West', 'Ndokwa West', 'Ndokwa East', 'Aniocha South', 'Aniocha North', 'Oshimili North', 'Oshimili South'],
    'Enugu': ['Enugu North', 'Enugu South', 'Enugu East', 'Nkanu West', 'Nkanu East', 'Udi Agwu', 'Oji River', 'Awgu', 'Uzo-Uwani', 'Igbo-Ekiti', 'Nkanu'],
    'Kano': ['Kano Municipal', 'Kano North', 'Kano South', 'Dala', 'Fagge', 'Gwale', 'Kumbotso', 'Minjibir', 'Nasarawa', 'Tarauni', 'Ungogo', 'Warawa'],
    'Ogun': ['Abeokuta North', 'Abeokuta South', 'Ewekoro', 'Ifo', 'Ijebu North', 'Ijebu North-East', 'Ijebu Ode', 'Ikenne', 'Imeko-Afon', 'Ipokia', 'Obafemi Owode', 'Ogun Waterside', 'Remo North', 'Remo South', 'Sagamu'],
    'Anambra': ['Awka North', 'Awka South', 'Anambra West', 'Anambra East', 'Ogidi', 'Onitsha North', 'Onitsha South', 'Idemili North', 'Idemili South', 'Orumba North', 'Orumba South'],
    'Kaduna': ['Kaduna North', 'Kaduna South', 'Zaria', 'Soba', 'Kudan', 'Makarfi', 'Igabi', 'Chikun', 'Kajuru', 'Birnin-Gwari', 'Giwa'],
  };

  // Get all states
  static List<String> getStates() {
    return statesAndLGAs.keys.toList()..sort();
  }

  // Get LGAs for a state
  static List<String> getLGAs(String state) {
    return statesAndLGAs[state] ?? [];
  }

  // Format phone number (Nigerian format)
  static String formatPhoneNumber(String phone) {
    // Remove any spaces or dashes
    var cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // Add country code if not present
    if (cleaned.startsWith('0')) {
      cleaned = '+234${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }

    return cleaned;
  }

  // Format price in Naira
  static String formatPrice(double price) {
    return '₦${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  // Get provider type display name
  static String getProviderTypeName(String type) {
    switch (type) {
      case 'Physician':
        return 'Doctor';
      case 'Nurse':
        return 'Nurse';
      case 'Caregiver':
        return 'Caregiver';
      case 'Pharmacy':
        return 'Pharmacy';
      case 'Hospital':
        return 'Hospital';
      default:
        return type;
    }
  }

  // Emergency numbers
  static const Map<String, String> emergencyNumbers = {
    'National Emergency': '199',
    'Police': '199',
    'Fire Service': '199',
    'Ambulance': '199',
    'FRSC': '122',
    'Lagos Emergency': '767',
    'Abuja Emergency': '112',
  };

  // Common symptoms in Nigerian context
  static const List<String> commonSymptoms = [
    'Headache',
    'Fever',
    'Cough',
    'Malaria',
    'Typhoid',
    'Stomach pain',
    'Diarrhea',
    'Vomiting',
    'Body aches',
    'Fatigue',
    'Sore throat',
    'Runny nose',
    'Chest pain',
    'Shortness of breath',
    'Dizziness',
    'Rash',
    'Joint pain',
    'Back pain',
  ];

  // Common specialties
  static const List<String> specialties = [
    'General Practice',
    'Internal Medicine',
    'Pediatrics',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Gynecology',
    'Obstetrics',
    'Ophthalmology',
    'ENT',
    'Psychiatry',
    'Surgery',
    'Dentistry',
    'Physiotherapy',
  ];
}
