import 'package:flutter/material.dart';

import 'screens/engagement_screens.dart';
import 'screens/onboarding_screens.dart';
import 'screens/paywall_screens.dart';
import 'screens/today_screens.dart';

/// Single navigator so taps, deep links from pushes and the demo autopilot
/// share one route stack.
final navKey = GlobalKey<NavigatorState>();

NavigatorState get _nav => navKey.currentState!;

Future<T?> _push<T>(Widget w) => _nav.push<T>(PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => w,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child:
              SlideTransition(position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(c), child: child),
        );
      },
    ));

class Nav {
  // onboarding
  static void goalPick() => _push(const GoalPickScreen());
  static void firstReminder() => _push(const FirstReminderScreen());
  static void pushPrimer() => _push(const PushPrimerScreen());
  static void signUp() => _push(const SignUpScreen());

  // monetization
  static void paywall({String? variant}) => _push(PaywallScreen(forceVariant: variant));
  static void trialEnding() => _push(const TrialEndingScreen());
  static void winBack() => _push(const WinBackScreen());

  // core
  static void today() => _nav.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
  static void supplementDetail() => _push(const SupplementDetailScreen());
  static void addReminder() => showModalBottomSheet<void>(
        context: navKey.currentContext!,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: .35),
        builder: (_) => const AddReminderSheet(),
      );

  // engagement
  static void pushSequence() => _push(const PushSequenceScreen());
  static void checkIn() => _push(const CheckInScreen());
  static void checkInComplete() => _push(const CheckInCompleteScreen());

  static void backToRoot() => _nav.popUntil((r) => r.isFirst);
  static void pop() {
    if (_nav.canPop()) _nav.pop();
  }
}
