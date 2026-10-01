import 'package:flutter/material.dart';

import '../models/models.dart';

/// Builds the lifecycle push plan for one user: dose reminders, the
/// day 1 / 3 / 5 / 7 activation sequence, the daily 8 PM check-in and the
/// trial-ending nudge two days before billing.
///
/// Pure function of its inputs so it is unit-tested and can run on device
/// (local notifications) or server side (OneSignal / Braze journeys).
class PushScheduler {
  const PushScheduler();

  List<PushMessage> plan({
    required DateTime install,
    required List<Reminder> reminders,
    required NotificationPrefs prefs,
    required PushPermission permission,
    DateTime? trialStart,
    int trialDays = 7,
    int days = 7,
  }) {
    if (permission != PushPermission.granted) return const [];
    final out = <PushMessage>[];
    final day0 = DateTime(install.year, install.month, install.day);
    final first = reminders.isEmpty ? null : reminders.first;

    for (var d = 0; d < days; d++) {
      final date = day0.add(Duration(days: d));
      if (prefs.doseReminders) {
        for (final r in reminders) {
          out.add(PushMessage(
            id: 'dose_${r.id}_$d',
            kind: PushKind.dose,
            at: _at(date, r.time, prefs),
            title: '${r.name} at ${_fmt(r.time)}',
            body: r.kind == ReminderKind.supplement ? 'Time for your daily dose' : 'Time to move',
            actions: const ['Done', 'Snooze 15 min'],
          ));
        }
      }
      if (prefs.dailyCheckIn) {
        out.add(PushMessage(
          id: 'checkin_$d',
          kind: PushKind.checkIn,
          at: _at(date, prefs.checkInTime, prefs),
          title: 'Evening check-in',
          body: 'How did today go? 20 seconds to log it',
        ));
      }
    }

    // Activation sequence (day numbers are 1-based for humans).
    if (first != null) {
      out.add(PushMessage(
        id: 'seq_day1',
        kind: PushKind.sequence,
        dayIndex: 1,
        at: _at(day0, first.time, prefs),
        title: 'Day 1 - ${first.name} at ${_fmt(first.time)}',
        body: 'Tap Done to start your streak',
        actions: const ['Done', 'Snooze 15 min'],
      ));
    }
    final evening = reminders.where((r) => r.time.hour >= 17).toList();
    out.add(PushMessage(
      id: 'seq_day3',
      kind: PushKind.sequence,
      dayIndex: 3,
      at: _at(day0.add(const Duration(days: 2)),
          evening.isEmpty ? const TimeOfDay(hour: 19, minute: 0) : evening.first.time, prefs),
      title: 'Day 3 - 3 days in a row!',
      body: evening.isEmpty ? 'Keep it going tonight' : 'Keep it going with your evening ${evening.first.name}',
    ));
    if (trialStart != null) {
      final ts = DateTime(trialStart.year, trialStart.month, trialStart.day);
      out.add(PushMessage(
        id: 'seq_trial_end',
        kind: PushKind.trial,
        dayIndex: trialDays - 2,
        at: _at(ts.add(Duration(days: trialDays - 2)), const TimeOfDay(hour: 10, minute: 0), prefs),
        title: 'Day ${trialDays - 2} - Your free trial ends in 2 days',
        body: 'See what you built',
      ));
    }
    out.add(PushMessage(
      id: 'seq_day7',
      kind: PushKind.sequence,
      dayIndex: 7,
      at: _at(day0.add(const Duration(days: 6)), const TimeOfDay(hour: 18, minute: 0), prefs),
      title: 'Day 7 - 7 day streak',
      body: 'Your weekly report is ready',
    ));

    out.sort((a, b) => a.at.compareTo(b.at));
    return out;
  }

  /// The four lifecycle messages shown on the lock screen preview.
  List<PushMessage> sequence(List<PushMessage> plan) =>
      plan.where((m) => m.kind == PushKind.sequence || m.kind == PushKind.trial).toList();

  /// Moves anything inside quiet hours to the end of the quiet window.
  DateTime _at(DateTime date, TimeOfDay t, NotificationPrefs prefs) {
    final at = DateTime(date.year, date.month, date.day, t.hour, t.minute);
    if (!isQuiet(t, prefs)) return at;
    final end = DateTime(date.year, date.month, date.day, prefs.quietEnd.hour, prefs.quietEnd.minute);
    return t.hour >= prefs.quietStart.hour ? end.add(const Duration(days: 1)) : end;
  }

  bool isQuiet(TimeOfDay t, NotificationPrefs p) {
    final m = t.hour * 60 + t.minute;
    final s = p.quietStart.hour * 60 + p.quietStart.minute;
    final e = p.quietEnd.hour * 60 + p.quietEnd.minute;
    return s > e ? (m >= s || m < e) : (m >= s && m < e);
  }

  static String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final mm = t.minute.toString().padLeft(2, '0');
    return '$h:$mm ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
}
