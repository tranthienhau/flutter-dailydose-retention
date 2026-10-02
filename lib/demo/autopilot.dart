import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';

class DemoStep {
  const DemoStep(this.name, this.action, {this.dwell = const Duration(milliseconds: 1500), this.inVideo = true});
  final String name;
  final void Function(ProviderContainer c) action;
  final Duration dwell;
  final bool inVideo;
}

/// Guided walkthrough: value-first onboarding, both paywall variants, the
/// daily loop, push sequence, trial-end + win-back, evening check-in and the
/// push-denied recovery path. Shared by the demo recording and the
/// integration screenshot test.
List<DemoStep> demoSteps() => [
      DemoStep('01-welcome', (_) {}, dwell: const Duration(milliseconds: 1600)),
      DemoStep('02-goal-pick', (_) => Nav.goalPick()),
      DemoStep('03-first-reminder', (_) => Nav.firstReminder(), dwell: const Duration(milliseconds: 1700)),
      DemoStep('04-push-primer', (c) {
        c.read(remindersProvider.notifier).add(const Reminder(
            id: 'd3',
            name: 'Vitamin D3',
            detail: '2000 IU',
            kind: ReminderKind.supplement,
            time: TimeOfDay(hour: 8, minute: 0),
            subtitle: 'Morning routine',
            withFood: true));
        Nav.pushPrimer();
      }, dwell: const Duration(milliseconds: 1700)),
      DemoStep('05-sign-up', (c) {
        c.read(pushPermissionProvider.notifier).state = PushPermission.granted;
        Nav.signUp();
      }),
      DemoStep('06-paywall-a', (_) => Nav.paywall(variant: 'a'), dwell: const Duration(milliseconds: 2000)),
      DemoStep('07-paywall-b', (_) {
        Nav.pop();
        Nav.paywall(variant: 'b');
      }, dwell: const Duration(milliseconds: 2000)),
      DemoStep('08-today', (c) {
        c.read(customerInfoProvider.notifier).seedTrial(kInstallDate);
        c.read(tabProvider.notifier).state = 0;
        Nav.today();
      }, dwell: const Duration(milliseconds: 1900)),
      DemoStep('09-add-reminder', (_) => Nav.addReminder(), dwell: const Duration(milliseconds: 1500)),
      DemoStep('10-supplement-detail', (_) {
        Nav.pop();
        Nav.supplementDetail();
      }),
      DemoStep('11-routines', (c) {
        Nav.backToRoot();
        c.read(tabProvider.notifier).state = 1;
      }),
      DemoStep('12-progress', (c) => c.read(tabProvider.notifier).state = 2),
      DemoStep('13-profile', (c) => c.read(tabProvider.notifier).state = 3),
      DemoStep('14-push-sequence', (_) => Nav.pushSequence(), dwell: const Duration(milliseconds: 2200)),
      DemoStep('15-trial-ending', (_) {
        Nav.pop();
        Nav.trialEnding();
      }, dwell: const Duration(milliseconds: 1900)),
      DemoStep('16-win-back', (_) => Nav.winBack(), dwell: const Duration(milliseconds: 1900)),
      DemoStep('17-daily-check-in', (c) {
        Nav.backToRoot();
        c.read(tabProvider.notifier).state = 0;
        Nav.checkIn();
      }, dwell: const Duration(milliseconds: 1900)),
      DemoStep('18-check-in-complete', (c) {
        c.read(streakProvider.notifier).state = 7;
        Nav.checkInComplete();
      }, dwell: const Duration(milliseconds: 1900)),
      DemoStep('19-push-recovery', (c) {
        Nav.backToRoot();
        // Next morning, for a user who tapped "Not now" on the push primer.
        // Applied after the pop transition so the closing screen does not flicker.
        Future<void>.delayed(const Duration(milliseconds: 350), () {
          c.read(pushPermissionProvider.notifier).state = PushPermission.denied;
          c.read(missedYesterdayProvider.notifier).state = {'mag'};
          c.read(dayOffsetProvider.notifier).state = 1;
          c.read(streakProvider.notifier).state = 2;
          c.read(doneProvider.notifier).set({'d3'});
        });
      }, dwell: const Duration(milliseconds: 2600)),
      DemoStep('20-today-empty', (c) => c.read(remindersProvider.notifier).clear(), inVideo: false),
    ];

class Autopilot {
  Future<void> run() async {
    final c = ProviderScope.containerOf(navKey.currentContext!);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    for (final s in demoSteps().where((s) => s.inVideo)) {
      s.action(c);
      await Future<void>.delayed(s.dwell);
    }
    debugPrint('AUTOPILOT_DONE');
  }
}
