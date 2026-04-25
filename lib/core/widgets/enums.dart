import 'package:flutter/material.dart';

enum EntityType { weekday, taxSlab, availabilityStatus, persona }

enum Role { operator, manager }

enum Section {
  // Living entities
  petOwners,
  pets,
  doctors,
  technicians,
  // Medical services
  pathology,
  consultations,
  groomings,
  services,
  vaccinations,

  //job board
  bookings,
  workInProgress,
  history,

  // Business operations
  dashboard,
  operators,
  billing,
  rateCards,
  // schedules,
  messaging,
  // reports,
  // sub-sections
  doctorSchedule,
  doctorAvailabilitySlots,
}

class SectionGroups {
  static const livingEntities = {
    Section.petOwners,
    Section.pets,
    Section.doctors,
    Section.technicians,
    Section.operators,
  };

  static const medicalServices = {
    Section.consultations,
    Section.vaccinations,
    Section.groomings,
    Section.pathology,
    Section.services,
  };

  static const jobBoard = {
    Section.bookings,
    Section.workInProgress,
    Section.history,
  };

  static const businessOperations = {
    // Section.dashboard,
    Section.billing,
    Section.rateCards,
    // Section.schedules,
    Section.messaging,
    // Section.reports,
  };

  /// All groups in one place
  static const allGroups = {
    "Living Entities": livingEntities,
    "Medical Services": medicalServices,
    "Job Board": jobBoard,
    "Business Operations": businessOperations,
  };
}

extension SectionExtension on Section {
  String get name {
    switch (this) {
      case Section.dashboard:
        return 'Dashboard';
      case Section.petOwners:
        return "Pet Owner";
      case Section.pets:
        return 'Pet';
      case Section.doctors:
        return 'Doctor';
      // case Section.schedules:
      //   return 'Schedules';
      case Section.billing:
        return 'Billing';
      // case Section.reports:
      //   return 'Reports';
      case Section.messaging:
        return 'Messaging';
      case Section.rateCards:
        return 'Rate Cards';
      case Section.technicians:
        return 'Technician';
      case Section.pathology:
        return 'Pathology';
      case Section.consultations:
        return 'Consultation';
      case Section.groomings:
        return 'Grooming';
      case Section.services:
        return 'Medical Service';
      case Section.vaccinations:
        return 'Vaccination';
      case Section.doctorSchedule:
        return 'Doctor Schedule';
      case Section.bookings:
        return 'Booking';
      case Section.history:
        return 'History';
      case Section.workInProgress:
        return 'Work In Progress';
      case Section.doctorAvailabilitySlots:
        return 'Doctor Availability Slots';
      case Section.operators:
        return 'Operator';
    }
  }

  IconData get icon {
    switch (this) {
      case Section.operators:
        return Icons.admin_panel_settings_outlined;
      case Section.dashboard:
        return Icons.dashboard_customize_outlined;
      case Section.petOwners:
        return Icons.people_alt_outlined;
      case Section.pets:
        return Icons.pets_outlined;
      case Section.doctors:
        return Icons.medical_services_outlined;
      // case Section.schedules:
      //   return Icons.schedule_outlined;
      case Section.billing:
        return Icons.receipt_long_outlined;
      // case Section.reports:
      //   return Icons.analytics_outlined;
      case Section.messaging:
        return Icons.message_outlined;
      case Section.rateCards:
        return Icons.currency_rupee_outlined;
      case Section.technicians:
        return Icons.build_outlined;
      case Section.pathology:
        return Icons.bloodtype_outlined;
      case Section.consultations:
        return Icons.medical_services_outlined;
      case Section.groomings:
        return Icons.pets_outlined;
      case Section.services:
        return Icons.business_center_outlined;
      case Section.vaccinations:
        return Icons.health_and_safety_outlined;
      case Section.doctorSchedule:
        return Icons.schedule_outlined;
      case Section.doctorAvailabilitySlots:
        return Icons.schedule_outlined;
      case Section.bookings:
        return Icons.book_online_outlined;
      case Section.history:
        return Icons.history_outlined;
      case Section.workInProgress:
        return Icons.work_outline;
    }
  }

  // Helper method to darken a color
  Color _darken(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // A getter  method to get the section's color
  Color get color {
    return _darken(switch (this) {
      Section.dashboard => Colors.blue,
      Section.petOwners => Colors.green,
      Section.pets => Colors.orange,
      Section.doctors => Colors.purple,
      // Section.schedules => Colors.red,
      Section.billing => Colors.teal,
      // Section.reports => Colors.amber,
      Section.messaging => Colors.cyan,
      Section.rateCards => Colors.deepOrange,
      Section.technicians => Colors.indigo,
      Section.pathology => Colors.red,
      Section.consultations => Colors.blue,
      Section.groomings => Colors.green,
      Section.services => Colors.orange,
      Section.vaccinations => Colors.purple,
      Section.doctorSchedule => Colors.red,
      Section.doctorAvailabilitySlots => Colors.deepPurple,
      Section.operators => Colors.blueGrey,
      Section.bookings => Colors.teal,
      Section.history => Colors.amber,
      Section.workInProgress => Colors.cyan,
    }, 0.1);
  }
}

enum SortOrder { ascending, descending }

enum SortBy { name, id }

enum SuccessStatus { waiting, success, error, warning }

//extend this enum to return color based on status
extension SuccessStatusExtension on SuccessStatus {
  Color get color {
    return switch (this) {
      SuccessStatus.waiting => Colors.grey,
      SuccessStatus.success => Colors.green,
      SuccessStatus.error => Colors.red,
      SuccessStatus.warning => Colors.amber,
    };
  }
}

enum RateCard { medicalService, grooming, pathology, vaccine }

extension RateCardExtension on RateCard {
  String get name {
    switch (this) {
      case RateCard.medicalService:
        return 'Medical Service';
      case RateCard.grooming:
        return 'Grooming';
      case RateCard.pathology:
        return 'Pathology';
      case RateCard.vaccine:
        return 'Vaccine';
    }
  }

  IconData get icon {
    switch (this) {
      case RateCard.medicalService:
        return Icons.medical_services_outlined;
      case RateCard.grooming:
        return Icons.pets_outlined;
      case RateCard.pathology:
        return Icons.bloodtype_outlined;
      case RateCard.vaccine:
        return Icons.vaccines_outlined;
    }
  }

  //color
  Color get color {
    switch (this) {
      case RateCard.medicalService:
        return Colors.blue;
      case RateCard.grooming:
        return Colors.green;
      case RateCard.pathology:
        return Colors.red;
      case RateCard.vaccine:
        return Colors.purple;
    }
  }

  //id string
  String get idString {
    switch (this) {
      case RateCard.medicalService:
        return 'medical_service_ratecard';
      case RateCard.grooming:
        return 'grooming_ratecard';
      case RateCard.pathology:
        return 'pathology_ratecard';
      case RateCard.vaccine:
        return 'vaccine_ratecard';
    }
  }
}

enum TaxSlab { exempt, slab1, slab2, slab3, slab4 }

extension TaxSlabExtension on TaxSlab {
  double get value {
    switch (this) {
      case TaxSlab.exempt:
        return 0.0;
      case TaxSlab.slab1:
        return 5.0;
      case TaxSlab.slab2:
        return 12.0;
      case TaxSlab.slab3:
        return 18.0;
      case TaxSlab.slab4:
        return 28.0;
    }
  }
}

enum Weekday { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

extension WeekdayExtension on Weekday {
  String get name {
    switch (this) {
      case Weekday.monday:
        return 'Monday';
      case Weekday.tuesday:
        return 'Tuesday';
      case Weekday.wednesday:
        return 'Wednesday';
      case Weekday.thursday:
        return 'Thursday';
      case Weekday.friday:
        return 'Friday';
      case Weekday.saturday:
        return 'Saturday';
      case Weekday.sunday:
        return 'Sunday';
    }
  }

  String get value {
    switch (this) {
      case Weekday.monday:
        return 'monday';
      case Weekday.tuesday:
        return 'tuesday';
      case Weekday.wednesday:
        return 'wednesday';
      case Weekday.thursday:
        return 'thursday';
      case Weekday.friday:
        return 'friday';
      case Weekday.saturday:
        return 'saturday';
      case Weekday.sunday:
        return 'sunday';
    }
  }

  int get index {
    switch (this) {
      case Weekday.monday:
        return 1;
      case Weekday.tuesday:
        return 2;
      case Weekday.wednesday:
        return 3;
      case Weekday.thursday:
        return 4;
      case Weekday.friday:
        return 5;
      case Weekday.saturday:
        return 6;
      case Weekday.sunday:
        return 7;
    }
  }

  // String to enum
  static Weekday fromString(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return Weekday.monday;
      case 'tuesday':
        return Weekday.tuesday;
      case 'wednesday':
        return Weekday.wednesday;
      case 'thursday':
        return Weekday.thursday;
      case 'friday':
        return Weekday.friday;
      case 'saturday':
        return Weekday.saturday;
      case 'sunday':
        return Weekday.sunday;
      default:
        throw Exception('Invalid weekday: $day');
    }
  }
}

enum AvailabilityStatus { available, unavailable, unsure }

enum SessionStatus {
  booked,
  workInProgress,
  cancelled,
  workDone,
  noShow,
  expired,
}

SessionStatus? sessionStatusFromJson(dynamic value) {
  if (value == null) return null;
  if (value is SessionStatus) return value;

  switch (value.toString().trim().toLowerCase()) {
    case 'work in progress':
      return SessionStatus.workInProgress;
    case 'cancelled':
      return SessionStatus.cancelled;
    case 'work done':
      return SessionStatus.workDone;
    case 'booked':
      return SessionStatus.booked;
    case 'no show':
      return SessionStatus.noShow;
    case 'expired':
      return SessionStatus.expired;
    default:
      return null;
  }
}

String? sessionStatusToJson(SessionStatus? status) {
  if (status == null) return null;
  switch (status) {
    case SessionStatus.workInProgress:
      return 'work in progress';
    case SessionStatus.noShow:
      return 'no show';
    case SessionStatus.workDone:
      return 'work done';
    default:
      return status.name;
  }
}

extension AvailabilityStatusExtension on AvailabilityStatus {
  String get name {
    switch (this) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.unavailable:
        return 'Unavailable';
      case AvailabilityStatus.unsure:
        return 'Unsure';
    }
  }

  Color get color {
    switch (this) {
      case AvailabilityStatus.available:
        return Colors.green;
      case AvailabilityStatus.unavailable:
        return Colors.red;
      case AvailabilityStatus.unsure:
        return Colors.amber;
    }
  }

  // String to enum
  static AvailabilityStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return AvailabilityStatus.available;
      case 'unavailable':
        return AvailabilityStatus.unavailable;
      case 'unsure':
        return AvailabilityStatus.unsure;
      default:
        throw Exception('Invalid availability status: $status');
    }
  }
}
