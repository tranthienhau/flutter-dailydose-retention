import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/analytics.dart';
import '../services/purchases_service.dart';
import '../services/push_scheduler.dart';

final clockProvider = Provider<DateTime Function()>((_) => () => kNow);

final analyticsProvider = Provider<Analytics>((ref) {
  final a = Analytics(clock: ref.watch(clockProvider));
  a.register({'distinct_id': kUserId, 'campaign': 'meta_ads_supplements_oct', 'media_source': 'facebook_ads'});
  return a;
});

// ---------------------------------------------------------------- experiment

/// Paywall A/B variant, assigned deterministically from the user id.
final paywallVariantProvider = StateProvider<String>((_) => paywallVariant(kUserId));

// ---------------------------------------------------------------- purchases

final purchasesProvider = Provider<PurchasesService>((ref) => PurchasesService(clock: ref.watch(clockProvider)));

class CustomerInfoNotifier extends Notifier<CustomerInfo> {
  PurchasesService get _svc => ref.read(purchasesProvider);

  @override
  CustomerInfo build() => _svc.customerInfo;

  void purchase(Package p) {
    state = _svc.purchase(p);
    ref.read(analyticsProvider).capture(Ev.trialStarted,
        {'product_id': p.productId, 'variant': ref.read(paywallVariantProvider), 'trial_days': p.trialDays});
  }

  void seedTrial(DateTime start) {
    _svc.seedTrial(start);
    state = _svc.customerInfo;
  }

  void acceptWinBack() {
    state = _svc.applyWinBack();
    ref.read(analyticsProvider).capture(Ev.winBackAccepted, {'offer': PurchasesService.winBackYearly.id});
  }

  void cancel() {
    state = _svc.cancel();
    ref.read(analyticsProvider).capture(Ev.subscriptionCancelled);
  }
}

final customerInfoProvider = NotifierProvider<CustomerInfoNotifier, CustomerInfo>(CustomerInfoNotifier.new);

final selectedPackageProvider = StateProvider<Package>((_) => PurchasesService.yearly);

// ---------------------------------------------------------------- onboarding

final selectedGoalsProvider = StateProvider<Set<String>>((_) => {'supplements'});

class FirstReminderDraft {
  const FirstReminderDraft({this.optionId = 'd3', this.time = const TimeOfDay(hour: 8, minute: 0), this.days = 7});
  final String optionId;
  final TimeOfDay time;
  final int days;

  FirstReminderDraft copyWith({String? optionId, TimeOfDay? time}) =>
      FirstReminderDraft(optionId: optionId ?? this.optionId, time: time ?? this.time, days: days);
}

final firstReminderProvider = StateProvider<FirstReminderDraft>((_) => const FirstReminderDraft());

// ---------------------------------------------------------------- routine

class RemindersNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() => kSeedReminders;

  void add(Reminder r) {
    final i = state.indexWhere((x) => x.id == r.id);
    if (i >= 0) {
      state = [...state]..[i] = r;
      return;
    }
    int key(Reminder x) => x.time.hour * 60 + x.time.minute;
    final at = state.indexWhere((x) => key(x) > key(r));
    state = [...state]..insert(at < 0 ? state.length : at, r);
  }

  void clear() => state = const [];
  void reset() => state = kSeedReminders;
}

final remindersProvider = NotifierProvider<RemindersNotifier, List<Reminder>>(RemindersNotifier.new);

class DoneNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => kSeedDone;

  void toggle(String id) {
    final now = !state.contains(id);
    state = now ? {...state, id} : ({...state}..remove(id));
    if (now) ref.read(analyticsProvider).capture(Ev.doseLogged, {'reminder_id': id});
  }

  void set(Set<String> ids) => state = ids;
}

final doneProvider = NotifierProvider<DoneNotifier, Set<String>>(DoneNotifier.new);

final streakProvider = StateProvider<int>((_) => 6);

/// Reminders missed yesterday (drives the push-recovery banner).
final missedYesterdayProvider = StateProvider<Set<String>>((_) => const {});

/// Shifts the demo clock to "tomorrow" for the push-recovery scene.
final dayOffsetProvider = StateProvider<int>((_) => 0);

// ---------------------------------------------------------------- push

final pushPermissionProvider = StateProvider<PushPermission>((_) => PushPermission.granted);
final pushBannerDismissedProvider = StateProvider<bool>((_) => false);

final notificationPrefsProvider = StateProvider<NotificationPrefs>((_) => const NotificationPrefs());

final pushPlanProvider = Provider<List<PushMessage>>((ref) {
  final info = ref.watch(customerInfoProvider);
  return const PushScheduler().plan(
    install: kInstallDate,
    reminders: ref.watch(remindersProvider),
    prefs: ref.watch(notificationPrefsProvider),
    permission: ref.watch(pushPermissionProvider),
    trialStart: info.trialStart ?? kInstallDate,
  );
});

final pushSequenceProvider =
    Provider<List<PushMessage>>((ref) => const PushScheduler().sequence(ref.watch(pushPlanProvider)));

// ---------------------------------------------------------------- check-in

class CheckInDraft {
  const CheckInDraft({this.mood = Mood.good, this.energy = 7, this.note = ''});
  final Mood mood;
  final int energy;
  final String note;

  CheckInDraft copyWith({Mood? mood, int? energy, String? note}) =>
      CheckInDraft(mood: mood ?? this.mood, energy: energy ?? this.energy, note: note ?? this.note);
}

final checkInDraftProvider = StateProvider<CheckInDraft>((_) => const CheckInDraft());
final checkInsProvider = StateProvider<List<CheckIn>>((_) => const []);

// ---------------------------------------------------------------- shell

final tabProvider = StateProvider<int>((_) => 0);
final routinesSegmentProvider = StateProvider<int>((_) => 1);
