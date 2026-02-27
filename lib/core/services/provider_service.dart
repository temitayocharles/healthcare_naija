import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/provider.dart' as model;

// Provider service for fetching and managing provider data
class ProviderService {
  final Ref ref;

  ProviderService(this.ref);

  // Sample providers data (in production, fetch from Firebase)
  List<model.HealthcareProvider> getSampleProviders() {
    return [
      model.HealthcareProvider(
        id: '1',
        name: 'Dr. Adaeze Okonkwo',
        type: 'Physician',
        specialty: 'General Practice',
        description: 'Experienced general practitioner with 10+ years of experience in family medicine.',
        phone: '08012345678',
        email: 'adaeze@example.com',
        state: 'Lagos',
        lga: 'Ikoyi',
        address: '15 Adeola Odeku Street, Ikoyi',
        latitude: 6.4281,
        longitude: 3.4219,
        rating: 4.8,
        reviewCount: 124,
        priceMin: 5000,
        priceMax: 15000,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        workingHours: '9:00 AM - 5:00 PM',
        services: ['General Consultation', 'Health Check', 'Vaccination', 'Minor Procedures'],
        acceptedInsurance: ['AXA', 'Leadway', 'AIICO', 'Sunrise'],
        createdAt: DateTime.now(),
        isVerified: true,
      ),
      model.HealthcareProvider(
        id: '2',
        name: 'St. Mary\'s Pharmacy',
        type: 'Pharmacy',
        description: '24/7 pharmacy with home delivery available.',
        phone: '08023456789',
        state: 'Lagos',
        lga: 'Victoria Island',
        address: '25 Ozumba Mbadiwe Avenue',
        latitude: 6.4281,
        longitude: 3.4219,
        rating: 4.5,
        reviewCount: 89,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        workingHours: '24 Hours',
        services: ['Medicine Dispensing', 'Home Delivery', 'Health Advice'],
        createdAt: DateTime.now(),
        isVerified: true,
      ),
      model.HealthcareProvider(
        id: '3',
        name: 'Nurse Amara Johnson',
        type: 'Nurse',
        specialty: 'Home Care',
        description: 'Professional nurse offering home nursing services.',
        phone: '08034567890',
        state: 'Abuja',
        lga: 'Gwagwalada',
        address: 'Zone 5, Gwagwalada',
        latitude: 8.9833,
        longitude: 7.1667,
        rating: 4.7,
        reviewCount: 56,
        priceMin: 3000,
        priceMax: 8000,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        workingHours: '8:00 AM - 6:00 PM',
        services: ['Home Nursing', 'Wound Care', 'Elderly Care'],
        createdAt: DateTime.now(),
        isVerified: true,
      ),
      model.HealthcareProvider(
        id: '4',
        name: 'Dr. Ibrahim Musa',
        type: 'Physician',
        specialty: 'Cardiology',
        description: 'Board-certified cardiologist.',
        phone: '08045678901',
        email: 'ibrahim@example.com',
        state: 'Kano',
        lga: 'Kano Municipal',
        address: '42 Ali Akilu Road',
        latitude: 12.0022,
        longitude: 8.5919,
        rating: 4.9,
        reviewCount: 203,
        priceMin: 10000,
        priceMax: 50000,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        workingHours: '9:00 AM - 4:00 PM',
        services: ['Cardiac Consultation', 'ECG', 'Heart Screening'],
        acceptedInsurance: ['NHS', 'Alliance'],
        createdAt: DateTime.now(),
        isVerified: true,
      ),
      model.HealthcareProvider(
        id: '5',
        name: 'Grace Caregiver Services',
        type: 'Caregiver',
        description: 'Professional caregivers for elderly and disabled care.',
        phone: '08056789012',
        state: 'Rivers',
        lga: 'Port Harcourt',
        address: '20 Woji Road, GRA',
        latitude: 4.7774,
        longitude: 7.0134,
        rating: 4.6,
        reviewCount: 45,
        priceMin: 2000,
        priceMax: 5000,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        workingHours: '24 Hours',
        services: ['Elderly Care', 'Patient Assistance'],
        createdAt: DateTime.now(),
        isVerified: false,
      ),
      model.HealthcareProvider(
        id: '6',
        name: 'Dr. Folake Adeyemi',
        type: 'Physician',
        specialty: 'Pediatrics',
        description: 'Compassionate pediatrician.',
        phone: '08067890123',
        email: 'folake@example.com',
        state: 'Oyo',
        lga: 'Ibadan North',
        address: '78 Ring Road',
        latitude: 7.3775,
        longitude: 3.947,
        rating: 4.8,
        reviewCount: 156,
        priceMin: 8000,
        priceMax: 20000,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        workingHours: '8:00 AM - 5:00 PM',
        services: ['Child Checkup', 'Immunization'],
        acceptedInsurance: ['AXA', 'Leadway'],
        createdAt: DateTime.now(),
        isVerified: true,
      ),
      model.HealthcareProvider(
        id: '7',
        name: 'Life Guard Pharmacy',
        type: 'Pharmacy',
        description: 'Trusted pharmacy with fast delivery.',
        phone: '08078901234',
        state: 'Delta',
        lga: 'Warri',
        address: '15 Effurun Road',
        latitude: 5.5577,
        longitude: 5.7931,
        rating: 4.4,
        reviewCount: 67,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        workingHours: '7:00 AM - 10:00 PM',
        services: ['Medicine Dispensing', 'Home Delivery'],
        createdAt: DateTime.now(),
        isVerified: true,
      ),
      model.HealthcareProvider(
        id: '8',
        name: 'Dr. Chukwuma Okeke',
        type: 'Physician',
        specialty: 'Internal Medicine',
        description: 'Specialist in diabetes and hypertension.',
        phone: '08089012345',
        email: 'chukwuma@example.com',
        state: 'Enugu',
        lga: 'Enugu North',
        address: '52 Enugu Road',
        latitude: 6.4281,
        longitude: 7.5421,
        rating: 4.7,
        reviewCount: 112,
        priceMin: 7000,
        priceMax: 18000,
        isAvailable: true,
        workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        workingHours: '9:00 AM - 4:00 PM',
        services: ['Diabetes Care', 'Hypertension Management'],
        acceptedInsurance: ['AIICO', 'Leadway'],
        createdAt: DateTime.now(),
        isVerified: true,
      ),
    ];
  }

  // Get all providers
  List<model.HealthcareProvider> getAllProviders() {
    return getSampleProviders();
  }

  // Get provider by ID
  model.HealthcareProvider? getProviderById(String id) {
    try {
      return getSampleProviders().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter providers
  List<model.HealthcareProvider> filterProviders({
    String? type,
    String? state,
    String? specialty,
    double? minRating,
    double? maxPrice,
    bool? isAvailable,
  }) {
    var providers = getSampleProviders();

    if (type != null) {
      providers = providers.where((p) => p.type == type).toList();
    }

    if (state != null) {
      providers = providers.where((p) => p.state == state).toList();
    }

    if (specialty != null) {
      providers = providers.where((p) => p.specialty == specialty).toList();
    }

    if (minRating != null) {
      providers = providers.where((p) => p.rating >= minRating).toList();
    }

    if (maxPrice != null) {
      providers = providers.where((p) => (p.priceMin ?? 0) <= maxPrice).toList();
    }

    if (isAvailable != null) {
      providers = providers.where((p) => p.isAvailable == isAvailable).toList();
    }

    return providers;
  }

  // Search providers
  List<model.HealthcareProvider> searchProviders(String query) {
    final q = query.toLowerCase();
    return getSampleProviders().where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.type.toLowerCase().contains(q) ||
          (p.specialty?.toLowerCase().contains(q) ?? false) ||
          p.state.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  // Get providers by type
  List<model.HealthcareProvider> getProvidersByType(String type) {
    return getSampleProviders().where((p) => p.type == type).toList();
  }

  // Get featured providers
  List<model.HealthcareProvider> getFeaturedProviders({int limit = 5}) {
    final providers = List<model.HealthcareProvider>.from(getSampleProviders());
    providers.sort((a, b) => b.rating.compareTo(a.rating));
    return providers.take(limit).toList();
  }
}

final providerServiceProvider = Provider<ProviderService>((ref) {
  return ProviderService(ref);
});
