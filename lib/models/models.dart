import 'package:flutter/material.dart';

enum ReminderKind { supplement, workout }

class Reminder {
  const Reminder({
    required this.id,
    required this.name,
    required this.kind,
    required this.time,
    this.detail = '',
    this.subtitle = '',
    this.withFood = false,
  });

  final String id;
  final String name;
  final ReminderKind kind;
  final TimeOfDay time;
  final String detail;
  final String subtitle;
  final bool withFood;

  String get title => detail.isEmpty ? name : '$name $detail';
}

enum Mood { great, good, okay, tired, rough }

class CheckIn {
  const CheckIn({required this.date, required this.mood, required this.energy, this.note = ''});
  final DateTime date;
  final Mood mood;
  final int energy;
  final String note;
}

/// A RevenueCat-style package inside an offering.
class Package {
  const Package({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.period,
    this.trialDays = 0,
    this.badge,
    this.perMonth,
  });

  final String id;
  final String productId;
  final String title;
  final double price;
  final String period; // 'year' | 'month'
  final int trialDays;
  final String? badge;
  final double? perMonth;

  String get priceLabel => '\$${price.toStringAsFixed(2)}';
}

/// A RevenueCat-style offering. The current offering is picked by the A/B experiment.
class Offering {
  const Offering({required this.id, required this.variant, required this.packages});
  final String id;
  final String variant; // 'a' | 'b'
  final List<Package> packages;
}

enum EntitlementStatus { none, trial, active, cancelled }

class CustomerInfo {
  const CustomerInfo({
    this.status = EntitlementStatus.none,
    this.productId,
    this.trialStart,
    this.trialDays = 7,
    this.promoApplied = false,
  });

  final EntitlementStatus status;
  final String? productId;
  final DateTime? trialStart;
  final int trialDays;
  final bool promoApplied;

  bool get isPlus => status == EntitlementStatus.trial || status == EntitlementStatus.active;
  DateTime? get trialEnd => trialStart?.add(Duration(days: trialDays));

  int daysLeft(DateTime now) {
    final end = trialEnd;
    if (end == null) return 0;
    final d = end.difference(DateTime(now.year, now.month, now.day)).inDays;
    return d < 0 ? 0 : d;
  }

  CustomerInfo copyWith({EntitlementStatus? status, String? productId, DateTime? trialStart, bool? promoApplied}) =>
      CustomerInfo(
        status: status ?? this.status,
        productId: productId ?? this.productId,
        trialStart: trialStart ?? this.trialStart,
        trialDays: trialDays,
        promoApplied: promoApplied ?? this.promoApplied,
      );
}

enum PushKind { dose, sequence, checkIn, trial }

/// One scheduled local / remote push.
class PushMessage {
  const PushMessage({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    this.actions = const [],
    this.dayIndex,
  });

  final String id;
  final PushKind kind;
  final DateTime at;
  final String title;
  final String body;
  final List<String> actions;
  final int? dayIndex;
}

enum PushPermission { notDetermined, granted, denied }

class NotificationPrefs {
  const NotificationPrefs({
    this.doseReminders = true,
    this.dailyCheckIn = true,
    this.weeklyEmail = true,
    this.tipsAndOffers = false,
    this.quietStart = const TimeOfDay(hour: 22, minute: 0),
    this.quietEnd = const TimeOfDay(hour: 7, minute: 0),
    this.checkInTime = const TimeOfDay(hour: 20, minute: 0),
  });

  final bool doseReminders;
  final bool dailyCheckIn;
  final bool weeklyEmail;
  final bool tipsAndOffers;
  final TimeOfDay quietStart;
  final TimeOfDay quietEnd;
  final TimeOfDay checkInTime;

  NotificationPrefs copyWith({bool? doseReminders, bool? dailyCheckIn, bool? weeklyEmail, bool? tipsAndOffers}) =>
      NotificationPrefs(
        doseReminders: doseReminders ?? this.doseReminders,
        dailyCheckIn: dailyCheckIn ?? this.dailyCheckIn,
        weeklyEmail: weeklyEmail ?? this.weeklyEmail,
        tipsAndOffers: tipsAndOffers ?? this.tipsAndOffers,
        quietStart: quietStart,
        quietEnd: quietEnd,
        checkInTime: checkInTime,
      );
}

/// A PostHog-style captured event.
class AnalyticsEvent {
  const AnalyticsEvent(this.name, this.at, [this.props = const {}]);
  final String name;
  final DateTime at;
  final Map<String, Object> props;
}
