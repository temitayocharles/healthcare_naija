import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/result/app_result.dart';
import '../../core/services/appointment_service.dart';
import '../../models/appointment.dart';
import '../../widgets/sync_status_action.dart';

final _appointmentsForCurrentUserProvider =
    FutureProvider.autoDispose<List<Appointment>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return <Appointment>[];
  }
  final result = await ref.read(appointmentRepositoryProvider).getForUser(user.id);
  if (result is AppSuccess<List<Appointment>>) {
    return result.data;
  }
  return <Appointment>[];
});

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(_appointmentsForCurrentUserProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appointments'),
          actions: const [
            SyncStatusAction(),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: appointmentsAsync.when(
          data: (appointments) => TabBarView(
            children: [
              _AppointmentList(
                appointments: appointments.where((a) {
                  final now = DateTime.now();
                  return a.status != 'cancelled' && a.dateTime.isAfter(now);
                }).toList(),
              ),
              _AppointmentList(
                appointments: appointments.where((a) {
                  final now = DateTime.now();
                  return a.status == 'completed' || a.dateTime.isBefore(now);
                }).toList(),
              ),
              _AppointmentList(
                appointments: appointments.where((a) => a.status == 'cancelled').toList(),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Failed to load appointments: $error')),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/providers'),
          icon: const Icon(Icons.add),
          label: const Text('New Booking'),
        ),
      ),
    );
  }
}

class _AppointmentList extends ConsumerWidget {
  const _AppointmentList({required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book an appointment with a provider',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(appointment.providerName),
            subtitle: Text(
              '${appointment.providerType} • ${appointment.dateTime.toLocal()}\nStatus: ${appointment.status}',
            ),
            isThreeLine: true,
            trailing: appointment.status == 'pending'
                ? TextButton(
                    onPressed: () async {
                      await ref.read(appointmentServiceProvider).cancelAppointment(appointment.id);
                      ref.invalidate(_appointmentsForCurrentUserProvider);
                    },
                    child: const Text('Cancel'),
                  )
                : null,
          ),
        );
      },
    );
  }
}
