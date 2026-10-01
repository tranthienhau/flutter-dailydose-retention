import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Event names used by the activation funnel. Same names go to PostHog
/// (`posthog.capture`) and, via the AppsFlyer -> PostHog join, carry the ad
/// campaign so drop-off can be split by acquisition source.
class Ev {
  static const appOpened = 'app_opened';
  static const onboardingStep = 'onboarding_step_viewed';
  static const goalSelected = 'goal_selected';
  static const firstReminderSet = 'first_reminder_set'; // activation event
  static const pushPrimerShown = 'push_primer_shown';
  static const pushPermission = 'push_permission_result';
  static const signedUp = 'signed_up';
  static const paywallViewed = 'paywall_viewed';
  static const trialStarted = 'trial_started';
  static const doseLogged = 'dose_logged';
  static const checkInCompleted = 'checkin_completed';
  static const trialEndingViewed = 'trial_ending_viewed';
  static const winBackShown = 'winback_offer_shown';
  static const winBackAccepted = 'winback_accepted';
  static const subscriptionCancelled = 'subscription_cancelled';
}

/// Ordered activation funnel, install to paid.
const kFunnel = [
  Ev.appOpened,
  Ev.goalSelected,
  Ev.firstReminderSet,
  Ev.pushPermission,
  Ev.signedUp,
  Ev.paywallViewed,
  Ev.trialStarted,
];

/// Thin PostHog-shaped client: capture with super properties, kept in memory
/// for the demo and printed to the console.
class Analytics {
  Analytics({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<AnalyticsEvent> events = [];
  final Map<String, Object> superProps = {};

  void register(Map<String, Object> props) => superProps.addAll(props);

  void capture(String name, [Map<String, Object> props = const {}]) {
    final e = AnalyticsEvent(name, _clock(), {...superProps, ...props});
    events.add(e);
    if (kDebugMode) debugPrint('[posthog] $name ${e.props}');
  }

  /// Furthest funnel step reached (index into [kFunnel]), -1 if none.
  int funnelStep() {
    var reached = -1;
    for (var i = 0; i < kFunnel.length; i++) {
      if (events.any((e) => e.name == kFunnel[i])) reached = i;
    }
    return reached;
  }
}

/// Deterministic 50/50 split so a user always sees the same paywall
/// (PostHog feature flag / RevenueCat Experiments do the same server side).
String paywallVariant(String userId) {
  var h = 0;
  for (final c in userId.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h.isEven ? 'a' : 'b';
}
