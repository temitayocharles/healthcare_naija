import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/providers.dart';
import '../../models/provider.dart' as model;
import '../../widgets/sync_status_action.dart';

class ProviderSearchScreen extends ConsumerStatefulWidget {
  const ProviderSearchScreen({super.key});

  @override
  ConsumerState<ProviderSearchScreen> createState() => _ProviderSearchScreenState();
}

class _ProviderSearchScreenState extends ConsumerState<ProviderSearchScreen> {
  String _searchQuery = '';
  String? _selectedType;
  String? _selectedState;
  String _sortBy = 'rating';

  List<model.Provider> _filteredProviders(List<model.Provider> sourceProviders) {
    var providers = sourceProviders.where((p) {
      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!p.name.toLowerCase().contains(query) &&
            !(p.specialty?.toLowerCase().contains(query) ?? false) &&
            !(p.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Filter by type
      if (_selectedType != null && p.type != _selectedType) {
        return false;
      }

      // Filter by state
      if (_selectedState != null && p.state != _selectedState) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'rating':
        providers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'distance':
        // Sort by distance (placeholder - would use actual location)
        break;
      case 'price_low':
        providers.sort((a, b) => (a.priceMin ?? 0).compareTo(b.priceMin ?? 0));
        break;
      case 'price_high':
        providers.sort((a, b) => (b.priceMin ?? 0).compareTo(a.priceMin ?? 0));
        break;
    }

    return providers;
  }

  IconData _getProviderIcon(String type) {
    switch (type) {
      case 'Physician':
        return Icons.medical_services;
      case 'Nurse':
        return Icons.person;
      case 'Pharmacy':
        return Icons.local_pharmacy;
      case 'Caregiver':
        return Icons.elderly;
      default:
        return Icons.local_hospital;
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providersProvider);
    final filteredProviders = _filteredProviders(providers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Providers'),
        actions: const [
          SyncStatusAction(),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search doctors, nurses, pharmacies...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Filters row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Type filter
                      _FilterDropdown(
                        value: _selectedType,
                        hint: 'Type',
                        items: AppConstants.providerTypes,
                        onChanged: (v) => setState(() => _selectedType = v),
                      ),
                      const SizedBox(width: 8),
                      // State filter
                      _FilterDropdown(
                        value: _selectedState,
                        hint: 'State',
                        items: AppConstants.nigerianStates.take(10).toList(),
                        onChanged: (v) => setState(() => _selectedState = v),
                      ),
                      const SizedBox(width: 8),
                      // Sort
                      _FilterDropdown(
                        value: _sortBy,
                        hint: 'Sort by',
                        items: ['rating', 'distance', 'price_low', 'price_high'],
                        labels: const ['Rating', 'Distance', 'Price: Low', 'Price: High'],
                        onChanged: (v) => setState(() => _sortBy = v ?? 'rating'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${filteredProviders.length} providers found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Provider list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredProviders.length,
              itemBuilder: (context, index) {
                final provider = filteredProviders[index];
                return _ProviderCard(
                  provider: provider,
                  icon: _getProviderIcon(provider.type),
                  onTap: () => _showProviderDetails(provider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showProviderDetails(model.Provider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getProviderIcon(provider.type),
                      size: 32,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (provider.isVerified)
                              const Icon(Icons.verified, color: AppTheme.primaryColor, size: 20),
                          ],
                        ),
                        Text(
                          '${provider.type}${provider.specialty != null ? ' - ${provider.specialty}' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rating
              Row(
                children: [
                  ...List.generate(5, (i) {
                    return Icon(
                      i < provider.rating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.rating} (${provider.reviewCount} reviews)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              if (provider.description != null) ...[
                Text(
                  provider.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],

              // Details
              _DetailRow(icon: Icons.location_on, text: '${provider.address}, ${provider.state}'),
              _DetailRow(icon: Icons.phone, text: provider.phone),
              if (provider.workingHours != null)
                _DetailRow(icon: Icons.access_time, text: provider.workingHours!),
              const SizedBox(height: 16),

              // Services
              if (provider.services != null && provider.services!.isNotEmpty) ...[
                Text(
                  'Services',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.services!.map((s) => Chip(label: Text(s))).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Price
              if (provider.priceMin != null)
                _DetailRow(
                  icon: Icons.attach_money,
                  text: '₦${provider.priceMin!.toStringAsFixed(0)} - ₦${provider.priceMax?.toStringAsFixed(0) ?? ''}',
                ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Call provider
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to booking
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Book'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<String> items;
  final List<String>? labels;
  final Function(String?) onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint),
        underline: const SizedBox(),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('All $hint'),
          ),
          ...items.asMap().entries.map((e) {
            return DropdownMenuItem<String>(
              value: e.value,
              child: Text(labels != null ? labels![e.key] : e.value),
            );
          }),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final model.Provider provider;
  final IconData icon;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (provider.isVerified)
                          const Icon(Icons.verified, color: AppTheme.primaryColor, size: 18),
                      ],
                    ),
                    Text(
                      '${provider.type}${provider.specialty != null ? ' - ${provider.specialty}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.rating}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          provider.state,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
