import 'package:flutter/material.dart';

// ── Section enum ──────────────────────────────────────────────────────────────
// The developer just adds values here; the plugin registry generates the sidebar.
enum ShaloonSection {
  // People
  staff,
  clients,

  // Operations
  appointments,
  services,
  billing,

  // Settings
  operators,
}

extension ShaloonSectionX on ShaloonSection {
  String get label {
    switch (this) {
      case ShaloonSection.staff:
        return 'Staff';
      case ShaloonSection.clients:
        return 'Clients';
      case ShaloonSection.appointments:
        return 'Appointments';
      case ShaloonSection.services:
        return 'Services';
      case ShaloonSection.billing:
        return 'Billing';
      case ShaloonSection.operators:
        return 'Operators';
    }
  }

  IconData get icon {
    switch (this) {
      case ShaloonSection.staff:
        return Icons.badge_outlined;
      case ShaloonSection.clients:
        return Icons.people_alt_outlined;
      case ShaloonSection.appointments:
        return Icons.calendar_today_outlined;
      case ShaloonSection.services:
        return Icons.content_cut_outlined;
      case ShaloonSection.billing:
        return Icons.receipt_long_outlined;
      case ShaloonSection.operators:
        return Icons.admin_panel_settings_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ShaloonSection.staff:
        return Colors.blue;
      case ShaloonSection.clients:
        return Colors.green;
      case ShaloonSection.appointments:
        return Colors.purple;
      case ShaloonSection.services:
        return Colors.orange;
      case ShaloonSection.billing:
        return Colors.teal;
      case ShaloonSection.operators:
        return Colors.blueGrey;
    }
  }

  int get order {
    switch (this) {
      case ShaloonSection.staff:
        return 0;
      case ShaloonSection.clients:
        return 1;
      case ShaloonSection.appointments:
        return 2;
      case ShaloonSection.services:
        return 3;
      case ShaloonSection.billing:
        return 4;
      case ShaloonSection.operators:
        return 5;
    }
  }
}

// ── Persona / Role enum ───────────────────────────────────────────────────────
enum ShaloonPersona { admin, manager, stylist, receptionist }

extension ShaloonPersonaX on ShaloonPersona {
  String get label {
    switch (this) {
      case ShaloonPersona.admin:
        return 'Admin';
      case ShaloonPersona.manager:
        return 'Manager';
      case ShaloonPersona.stylist:
        return 'Stylist';
      case ShaloonPersona.receptionist:
        return 'Receptionist';
    }
  }
}

// ── Appointment status enum ───────────────────────────────────────────────────
enum AppointmentStatus { scheduled, inProgress, completed, cancelled, noShow }

extension AppointmentStatusX on AppointmentStatus {
  String get label {
    switch (this) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.inProgress:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.noShow:
        return Colors.grey;
    }
  }
}
