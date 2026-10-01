import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../services/analytics.dart';
import '../services/purchases_service.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Paywall entry point: renders the variant the experiment assigned and
/// reports `paywall_viewed` with the offering id so PostHog can compare
/// trial start rate per variant.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key, this.forceVariant});
  final String? forceVariant;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    final String v = widget.forceVariant ?? ref.read(paywallVariantProvider);
    final offering = ref.read(purchasesProvider).currentOffering(v);
    ref
        .read(analyticsProvider)
        .capture(Ev.paywallViewed, {'variant': v, 'offering': offering.id, 'placement': 'onboarding'});
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.forceVariant ?? ref.watch(paywallVariantProvider);
    return v == 'b' ? const _PaywallB() : const _PaywallA();
  }
}

void _startTrial(WidgetRef ref) {
  ref.read(customerInfoProvider.notifier).purchase(ref.read(selectedPackageProvider));
  Nav.today();
}

class _PaywallHeader extends StatelessWidget {
  const _PaywallHeader();

  @override
  Widget build(BuildContext context) => Row(children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 0,
          child: IconButton(onPressed: () => Nav.today(), icon: const Icon(Icons.close_rounded)),
        ),
        const Spacer(),
        const TextAction('Restore'),
      ]);
}

/// 06 - Variant A: trial timeline (what happens on day 0, 5, 7).
class _PaywallA extends ConsumerWidget {
  const _PaywallA();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPackageProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), children: [
              const _PaywallHeader(),
              const SizedBox(height: 8),
              AppCard(
                gradient: AppColors.heroGradient,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.auto_awesome_outlined, size: 16, color: AppColors.accentFill),
                      SizedBox(width: 6),
                      Text('DAILYDOSE PLUS',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: AppColors.accentFill,
                              fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  const Text('Stay consistent with DailyDose Plus',
                      textAlign: TextAlign.center, style: AppText.headline),
                  const SizedBox(height: 8),
                  const Text('Unlimited reminders, workout plans and insights.',
                      textAlign: TextAlign.center, style: AppText.bodyMuted),
                ]),
              ),
              const SizedBox(height: 16),
              const AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('How your trial works', style: AppText.title),
                  SizedBox(height: 14),
                  _TimelineStep(
                      Icons.lock_open_rounded, 'Today', 'Full access unlocked', 'Explore every premium feature now.',
                      badge: 'Instant'),
                  _TimelineStep(Icons.notifications_active_outlined, 'Day 5', 'Friendly reminder',
                      'We remind you 2 days before billing.'),
                  _TimelineStep(Icons.credit_card_rounded, 'Day 7', 'Billing starts, cancel anytime',
                      'Renews unless cancelled in Settings.',
                      last: true),
                ]),
              ),
              const SizedBox(height: 16),
              _PlanCard(p: PurchasesService.yearly, selected: sel.id == PurchasesService.yearly.id),
              const SizedBox(height: 12),
              _PlanCard(p: PurchasesService.monthly, selected: sel.id == PurchasesService.monthly.id),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(children: [
              PrimaryButton(sel.trialDays > 0 ? 'Start 7-day free trial' : 'Subscribe monthly',
                  trailingArrow: true, onTap: () => _startTrial(ref)),
              const SizedBox(height: 8),
              const Text('Cancel anytime in Settings - No commitment', style: AppText.caption),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep(this.icon, this.day, this.title, this.sub, {this.badge, this.last = false});
  final IconData icon;
  final String day;
  final String title;
  final String sub;
  final String? badge;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Column(children: [
            CircleIcon(icon, size: 40),
            if (!last) Expanded(child: Container(width: 2, color: AppColors.border)),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 10, top: 2),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(day, style: AppText.label.copyWith(fontSize: 16)),
                  if (badge != null) ...[const SizedBox(width: 8), Pill(badge!, dense: true)],
                ]),
                const SizedBox(height: 2),
                Text(title, style: AppText.body.copyWith(fontSize: 15)),
                Text(sub, style: AppText.caption),
              ]),
            ),
          ),
        ]),
      );
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.p, required this.selected, this.compact = false});
  final Package p;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearly = p.period == 'year';
    return GestureDetector(
      onTap: () => ref.read(selectedPackageProvider.notifier).state = p,
      child: Stack(clipBehavior: Clip.none, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(compact ? 14 : 18),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentTint : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: selected ? AppColors.accentFill : AppColors.border, width: selected ? 2 : 1),
          ),
          child: compact
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SizedBox(height: 6),
                  Text(p.title, style: AppText.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(p.priceLabel, style: AppText.title.copyWith(color: AppColors.accentFill)),
                  Text(yearly ? 'per year, \$${p.perMonth}/mo' : 'per month', style: AppText.caption),
                ])
              : Row(children: [
                  Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: selected ? AppColors.accentFill : AppColors.border, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${p.title} Access', style: AppText.title.copyWith(fontSize: 19)),
                      Text(yearly ? '${p.priceLabel}/year after trial' : 'Billed monthly', style: AppText.caption),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(yearly ? '\$${p.perMonth}/mo' : '${p.priceLabel}/mo',
                        style: AppText.title.copyWith(color: yearly ? AppColors.accentFill : AppColors.textPrimary)),
                    Text(yearly ? 'Billed annually' : 'Billed monthly', style: AppText.caption),
                  ]),
                ]),
        ),
        if (p.badge != null || (compact && p.trialDays > 0))
          Positioned(
            top: -11,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppColors.accentFill, borderRadius: BorderRadius.circular(999)),
              child: Text(compact && p.trialDays > 0 ? '${p.trialDays} days free' : p.badge!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ),
      ]),
    );
  }
}

/// 15 - Variant B: social proof + the user's own plan + free-trial toggle.
class _PaywallB extends ConsumerWidget {
  const _PaywallB();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectedPackageProvider);
    final reminders = ref.watch(remindersProvider).take(2).toList();
    final trialOn = sel.trialDays > 0;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), children: [
              const _PaywallHeader(),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                    aspectRatio: 2.3,
                    child: Image.asset(Img.paywallB, fit: BoxFit.cover, alignment: const Alignment(0, -.3))),
              ),
              const SizedBox(height: 18),
              const Text('People who start a trial keep their streak 3x longer', style: AppText.headline),
              const SizedBox(height: 14),
              const Wrap(spacing: 10, children: [
                Pill('4.8', dense: true, icon: Icons.star_rounded),
                Pill('12,000+ daily routines kept', dense: true),
              ]),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Column(children: [
                  const SectionLabel('Your personalized plan',
                      trailing: Icon(Icons.verified_outlined, color: AppColors.accent)),
                  for (final r in reminders)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        const CheckCircle(done: true, size: 26),
                        const SizedBox(width: 12),
                        Expanded(child: Text(r.name, style: AppText.body)),
                        Text(fmtTime(r.time), style: AppText.caption),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration:
                    BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.card)),
                child: Row(children: [
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Free trial enabled', style: AppText.label),
                      Text('7 days free, cancel anytime', style: AppText.caption),
                    ]),
                  ),
                  Switch(
                    value: trialOn,
                    onChanged: (on) => ref.read(selectedPackageProvider.notifier).state =
                        on ? PurchasesService.yearly : PurchasesService.monthly,
                  ),
                ]),
              ),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                    child: _PlanCard(
                        p: PurchasesService.yearly, selected: sel.id == PurchasesService.yearly.id, compact: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _PlanCard(
                        p: PurchasesService.monthly, selected: sel.id == PurchasesService.monthly.id, compact: true)),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(children: [
              PrimaryButton(trialOn ? 'Try free for 7 days' : 'Subscribe for \$7.99/mo',
                  trailingArrow: true, onTap: () => _startTrial(ref)),
              const SizedBox(height: 8),
              Text(trialOn ? 'Then \$39.99/year. Cancel anytime.' : 'Billed monthly. Cancel anytime.',
                  style: AppText.caption),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// 13 - Trial ending (opened from the day 5 push): recap value, then ask.
class TrialEndingScreen extends ConsumerStatefulWidget {
  const TrialEndingScreen({super.key});

  @override
  ConsumerState<TrialEndingScreen> createState() => _TrialEndingScreenState();
}

class _TrialEndingScreenState extends ConsumerState<TrialEndingScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).capture(Ev.trialEndingViewed, {'days_left': 2});
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(customerInfoProvider);
    final end = info.trialEnd ?? kNow.add(const Duration(days: 2));
    final billing = DateFormat('MMM d').format(end);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), children: [
              Row(children: [
                IconButton(onPressed: () => Nav.pop(), icon: const Icon(Icons.close_rounded)),
                const Spacer(),
                const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.accentFill),
                const SizedBox(width: 4),
                const Text('Apple ID protected',
                    style: TextStyle(color: AppColors.accentFill, fontWeight: FontWeight.w600)),
                const Spacer(),
                const TextAction('Restore'),
              ]),
              const SizedBox(height: 8),
              AppCard(
                gradient: AppColors.heroGradient,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Pill('TRIAL ENDING SOON', dense: true, icon: Icons.bolt_rounded),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.accentFill, borderRadius: BorderRadius.circular(999)),
                      child:
                          const Text('2 days left', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  const Text('Your trial ends in 2 days', style: AppText.headline),
                  const SizedBox(height: 6),
                  Text('Billing starts $billing - cancel anytime, no hassle', style: AppText.bodyMuted),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Text('Free trial: ', style: AppText.caption),
                    const Text('Day 5 of 7',
                        style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.accentFill)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                            value: 5 / 7, minHeight: 6, color: AppColors.accentFill, backgroundColor: Colors.white),
                      ),
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Your first 5 days', style: AppText.title),
                  const Text('Look at the consistency you built', style: AppText.caption),
                  const SizedBox(height: 14),
                  const Row(children: [
                    Expanded(child: _Stat('41', 'Doses taken', Icons.check_circle_outline_rounded)),
                    SizedBox(width: 10),
                    Expanded(child: _Stat('6', 'Day streak', Icons.local_fire_department_outlined)),
                    SizedBox(width: 10),
                    Expanded(child: _Stat('4', 'Workouts', Icons.fitness_center_rounded)),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(16)),
                    child: const Row(children: [
                      Icon(Icons.spa_outlined, color: AppColors.accentFill),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text('Members who continue past day 7 are 3.4x more likely to keep their routine.',
                              style: AppText.caption)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              const _PlanCard(p: PurchasesService.yearly, selected: true),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(children: [
              PrimaryButton('Keep DailyDose Plus', trailingArrow: true, onTap: () => Nav.pop()),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextAction('Remind me tomorrow', color: AppColors.accentFill, onTap: () => Nav.pop()),
                TextAction('Manage subscription', onTap: () => Nav.winBack()),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.icon);
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: AppColors.accentFill, size: 22),
          const SizedBox(height: 8),
          Text(value, style: AppText.headline),
          Text(label, style: AppText.caption.copyWith(color: AppColors.textPrimary)),
        ]),
      );
}

/// 19 - Win-back: recap + RevenueCat promotional offer before cancelling.
class WinBackScreen extends ConsumerStatefulWidget {
  const WinBackScreen({super.key});

  @override
  ConsumerState<WinBackScreen> createState() => _WinBackScreenState();
}

class _WinBackScreenState extends ConsumerState<WinBackScreen> {
  int choice = 0;
  String? reason;

  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).capture(Ev.winBackShown, {'offer': PurchasesService.winBackYearly.id});
  }

  @override
  Widget build(BuildContext context) {
    const reasons = ['Too expensive', 'Not using it', 'Too many notifications', 'Other'];
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), children: [
              Row(children: [
                IconButton(onPressed: () => Nav.pop(), icon: const Icon(Icons.arrow_back_rounded)),
                const Spacer(),
                const BrandMark(size: 18),
                const Spacer(),
                const SizedBox(width: 48),
              ]),
              const SizedBox(height: 10),
              const Text('Before you go, Maya', style: AppText.display),
              const SizedBox(height: 6),
              const Text('Here is what you achieved during your trial.', style: AppText.bodyMuted),
              const SizedBox(height: 16),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Pill('TRIAL HIGHLIGHTS', dense: true, icon: Icons.verified_outlined),
                  const SizedBox(height: 12),
                  const Text('In 5 days you took 41 doses and kept a 6 day streak', style: AppText.title),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 54,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      for (final (i, v) in kWeekCompletion.indexed)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 54 * v / 100,
                            decoration: BoxDecoration(
                              color: i == 2 ? AppColors.support : AppColors.accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              const SectionLabel('Special offer for Maya'),
              _OfferRow(
                selected: choice == 0,
                badge: '50% off',
                title: 'Stay for \$19.99 your first year',
                strike: '\$39.99',
                sub: 'Keep all your progress and smart reminders',
                onTap: () => setState(() => choice = 0),
              ),
              const SizedBox(height: 10),
              _OfferRow(
                selected: choice == 1,
                title: 'Switch to Monthly, \$7.99',
                sub: 'Flexible month to month',
                onTap: () => setState(() => choice = 1),
              ),
              const SizedBox(height: 10),
              _OfferRow(
                selected: choice == 2,
                title: 'Pause reminders for 2 weeks',
                sub: 'Keep your plan, take a break',
                onTap: () => setState(() => choice = 2),
              ),
              const SizedBox(height: 18),
              const Text('Why are you leaving?', style: AppText.label),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final r in reasons)
                  Pill(r, dense: true, selected: reason == r, onTap: () => setState(() => reason = r)),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(children: [
              PrimaryButton(choice == 0 ? 'Claim 50% off' : (choice == 1 ? 'Switch to monthly' : 'Pause for 2 weeks'),
                  trailingArrow: true, onTap: () {
                if (choice == 0) ref.read(customerInfoProvider.notifier).acceptWinBack();
                Nav.backToRoot();
              }),
              TextAction('Continue to cancel', onTap: () {
                ref.read(customerInfoProvider.notifier).cancel();
                Nav.backToRoot();
              }),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow(
      {required this.selected, required this.title, required this.sub, required this.onTap, this.badge, this.strike});
  final bool selected;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final String? badge;
  final String? strike;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: selected ? AppColors.accentFill : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.accentFill, borderRadius: BorderRadius.circular(999)),
                    child: Text(badge!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8, children: [
                  Text(title, style: AppText.label.copyWith(fontSize: 16)),
                  if (strike != null)
                    Text(strike!,
                        style: AppText.caption
                            .copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textTertiary)),
                ]),
                const SizedBox(height: 2),
                Text(sub, style: AppText.caption),
              ]),
            ),
            Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.accentFill : AppColors.border),
          ]),
        ),
      );
}

/// Formats the current entitlement for the profile badge.
String plusBadge(CustomerInfo info, DateTime now) => switch (info.status) {
      EntitlementStatus.trial => 'Plus trial - ${info.daysLeft(now)} days left',
      EntitlementStatus.active => info.promoApplied ? 'Plus - 50% off first year' : 'Plus member',
      EntitlementStatus.cancelled => 'Plus ends after trial',
      EntitlementStatus.none => 'Free plan',
    };
