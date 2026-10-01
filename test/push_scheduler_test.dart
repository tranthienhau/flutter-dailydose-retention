import 'package:dailydose/data/mock_data.dart';
import 'package:dailydose/models/models.dart';
import 'package:dailydose/services/push_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const s = PushScheduler();
  const prefs = NotificationPrefs();

  List<PushMessage> plan({PushPermission p = PushPermission.granted, NotificationPrefs pr = prefs}) => s.plan(
        install: kInstallDate,
        reminders: kSeedReminders,
        prefs: pr,
        permission: p,
        trialStart: kInstallDate,
      );

  test('nothing is scheduled without push permission', () {
    expect(plan(p: PushPermission.denied), isEmpty);
    expect(plan(p: PushPermission.notDetermined), isEmpty);
  });

  test('sequence has day 1, 3, trial-end (day 5) and day 7 in order', () {
    final seq = s.sequence(plan());
    expect(seq.map((m) => m.dayIndex), [1, 3, 5, 7]);
    expect(seq.first.title, 'Day 1 - Vitamin D3 at 8:00 AM');
    expect(seq[1].body, contains('Magnesium'));
    expect(seq[2].kind, PushKind.trial);
    expect(seq[2].at, DateTime(2026, 10, 2, 10, 0)); // 2 days before the Oct 4 billing date
  });

  test('daily check-in fires at 8 PM every day of the week', () {
    final checkIns = plan().where((m) => m.kind == PushKind.checkIn).toList();
    expect(checkIns, hasLength(7));
    expect(checkIns.every((m) => m.at.hour == 20 && m.at.minute == 0), isTrue);
  });

  test('a reminder inside quiet hours moves to the end of the window', () {
    final late = s.plan(
      install: kInstallDate,
      reminders: const [
        Reminder(id: 'x', name: 'Melatonin', kind: ReminderKind.supplement, time: TimeOfDay(hour: 22, minute: 30)),
      ],
      prefs: prefs.copyWith(dailyCheckIn: false),
      permission: PushPermission.granted,
      days: 1,
    );
    final dose = late.firstWhere((m) => m.kind == PushKind.dose);
    expect(dose.at, DateTime(2026, 9, 28, 7, 0));
  });

  test('turning dose reminders off keeps the lifecycle sequence', () {
    final p = plan(pr: prefs.copyWith(doseReminders: false));
    expect(p.where((m) => m.kind == PushKind.dose), isEmpty);
    expect(s.sequence(p), hasLength(4));
  });
}
