import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../services/analytics.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 01 - Welcome. Promise the habit, no sign-up wall.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: h * .58,
          child: ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.black, Colors.transparent],
              stops: [0, .72, 1],
            ).createShader(r),
            blendMode: BlendMode.dstIn,
            child: Image.asset(Img.welcome, fit: BoxFit.cover, alignment: const Alignment(0, -.2)),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              Row(children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .9), borderRadius: BorderRadius.circular(999)),
                  child: const BrandMark(size: 20),
                ),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(999)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.timer_outlined, size: 16, color: AppColors.accentFill),
                  SizedBox(width: 6),
                  Text('60-second setup',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accentFill, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 14),
              const Text('Build your daily routine in 60 seconds', style: AppText.display),
              const SizedBox(height: 12),
              const Text('Supplements, workouts and reminders in one place', style: AppText.bodyMuted),
              const SizedBox(height: 24),
              PrimaryButton('Get started', trailingArrow: true, onTap: () => Nav.goalPick()),
              const SizedBox(height: 4),
              Center(
                  child:
                      TextAction('I already have an account', color: AppColors.accentFill, onTap: () => Nav.today())),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// 02 - Goal picker.
class GoalPickScreen extends ConsumerStatefulWidget {
  const GoalPickScreen({super.key});

  @override
  ConsumerState<GoalPickScreen> createState() => _GoalPickScreenState();
}

class _GoalPickScreenState extends ConsumerState<GoalPickScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).capture(Ev.onboardingStep, {'step': 'goal_pick'});
  }

  static const goals = [
    ('supplements', 'Supplements', Img.goalSupplements),
    ('workouts', 'Workouts', Img.goalWorkouts),
    ('hydration', 'Hydration', Img.goalHydration),
    ('sleep', 'Sleep', Img.goalSleep),
  ];

  @override
  Widget build(BuildContext context) {
    final sel = ref.watch(selectedGoalsProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            OnboardingTopBar(step: 0, onSkip: () => Nav.firstReminder()),
            const SizedBox(height: 16),
            const Text('What do you want to stay on top of?', style: AppText.headline),
            const SizedBox(height: 8),
            const Text('Pick all that apply', style: AppText.bodyMuted),
            const SizedBox(height: 22),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: .86,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final g in goals)
                    _GoalTile(
                      label: g.$2,
                      image: g.$3,
                      selected: sel.contains(g.$1),
                      onTap: () {
                        final next = {...sel};
                        next.contains(g.$1) ? next.remove(g.$1) : next.add(g.$1);
                        ref.read(selectedGoalsProvider.notifier).state = next;
                      },
                    ),
                ],
              ),
            ),
            PrimaryButton('Continue', trailingArrow: true, onTap: () {
              ref.read(analyticsProvider).capture(Ev.goalSelected, {'goals': sel.join(',')});
              Nav.firstReminder();
            }),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.label, required this.image, required this.selected, required this.onTap});
  final String label;
  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: selected ? AppColors.accentFill : Colors.transparent, width: 2.5),
            boxShadow: kCardShadow,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Stack(children: [
                Positioned.fill(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(14), child: Image.asset(image, fit: BoxFit.cover))),
                if (selected)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.accentFill,
                        child: Icon(Icons.check_rounded, size: 17, color: Colors.white)),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
              child: Text(label, style: AppText.label.copyWith(fontSize: 16)),
            ),
          ]),
        ),
      );
}

/// 03 - First reminder, set BEFORE sign-up. This is the activation event.
class FirstReminderScreen extends ConsumerWidget {
  const FirstReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(firstReminderProvider);
    final t = draft.time;
    String two(int v) => v.toString().padLeft(2, '0');
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            OnboardingTopBar(step: 1, onSkip: () => Nav.pushPrimer()),
            const SizedBox(height: 16),
            const Text('Set your first reminder', style: AppText.headline),
            const SizedBox(height: 6),
            const Text('Pick a consistent time to build the habit effortlessly.', style: AppText.bodyMuted),
            const SizedBox(height: 20),
            AppCard(
              child: Column(children: [
                Row(children: [
                  const CircleIcon(Icons.schedule_rounded, size: 34),
                  const SizedBox(width: 10),
                  const Text('MORNING DOSE', style: AppText.overline),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(999)),
                    child: const Text('Recommended',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentFill)),
                  ),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _Wheel(
                        prev: two((h + 10) % 12 + 1),
                        cur: two(h),
                        next: two(h % 12 + 1),
                        onUp: () => _shift(ref, -60),
                        onDown: () => _shift(ref, 60)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(':', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
                    ),
                    _Wheel(
                        prev: two((t.minute + 45) % 60),
                        cur: two(t.minute),
                        next: two((t.minute + 15) % 60),
                        onUp: () => _shift(ref, -15),
                        onDown: () => _shift(ref, 15)),
                    const SizedBox(width: 14),
                    Column(children: [
                      _AmPm('AM', t.period == DayPeriod.am),
                      const SizedBox(height: 6),
                      _AmPm('PM', t.period == DayPeriod.pm),
                    ]),
                  ]),
                ),
                const SizedBox(height: 12),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.bolt_rounded, size: 16, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text('Best taken with breakfast and healthy fats', style: AppText.caption),
                ]),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Which supplement?', style: AppText.label),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final o in kFirstReminderOptions)
                Pill(o.name,
                    selected: draft.optionId == o.id,
                    icon: draft.optionId == o.id ? Icons.check_rounded : null,
                    onTap: () => ref.read(firstReminderProvider.notifier).state = draft.copyWith(optionId: o.id)),
            ]),
            const SizedBox(height: 22),
            const Row(children: [
              Text('Repeat', style: AppText.label),
              Spacer(),
              Text('Every day', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accentFill)),
            ]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.accentFill,
                  child: Text(d, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                ),
            ]),
            const Spacer(),
            const Center(child: Text('You can add more later', style: AppText.caption)),
            const SizedBox(height: 10),
            PrimaryButton('Save my reminder', trailingArrow: true, onTap: () => saveFirstReminder(ref)),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  static void _shift(WidgetRef ref, int minutes) {
    final d = ref.read(firstReminderProvider);
    final m = (d.time.hour * 60 + d.time.minute + minutes) % (24 * 60);
    ref.read(firstReminderProvider.notifier).state = d.copyWith(time: TimeOfDay(hour: m ~/ 60, minute: m % 60));
  }
}

/// Persists the onboarding reminder and fires the activation event.
void saveFirstReminder(WidgetRef ref) {
  final d = ref.read(firstReminderProvider);
  final o = kFirstReminderOptions.firstWhere((x) => x.id == d.optionId);
  ref.read(remindersProvider.notifier).add(Reminder(
      id: o.id,
      name: o.name,
      detail: o.detail,
      kind: ReminderKind.supplement,
      time: d.time,
      subtitle: 'Morning routine'));
  final secondsSinceOpen = 41;
  ref.read(analyticsProvider).capture(Ev.firstReminderSet, {
    'supplement': o.name,
    'time': fmtTime(d.time),
    'seconds_since_open': secondsSinceOpen,
  });
  Nav.pushPrimer();
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.prev, required this.cur, required this.next, required this.onUp, required this.onDown});
  final String prev;
  final String cur;
  final String next;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onVerticalDragEnd: (d) => (d.primaryVelocity ?? 0) < 0 ? onDown() : onUp(),
        child: Column(children: [
          GestureDetector(
              onTap: onUp, child: Text(prev, style: const TextStyle(fontSize: 18, color: AppColors.textTertiary))),
          Text(cur, style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w800, height: 1.15)),
          GestureDetector(
              onTap: onDown, child: Text(next, style: const TextStyle(fontSize: 18, color: AppColors.textTertiary))),
        ]),
      );
}

class _AmPm extends StatelessWidget {
  const _AmPm(this.label, this.on);
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        padding: const EdgeInsets.symmetric(vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: on ? AppColors.accentFill : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label,
            style: TextStyle(fontWeight: FontWeight.w800, color: on ? Colors.white : AppColors.textTertiary)),
      );
}

/// 04 - Push primer: a soft ask right after the reminder exists, so the
/// one-shot iOS system prompt is only shown to users who already said yes.
class PushPrimerScreen extends ConsumerStatefulWidget {
  const PushPrimerScreen({super.key});

  @override
  ConsumerState<PushPrimerScreen> createState() => _PushPrimerScreenState();
}

class _PushPrimerScreenState extends ConsumerState<PushPrimerScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).capture(Ev.pushPrimerShown);
  }

  @override
  Widget build(BuildContext context) {
    final d = ref.watch(firstReminderProvider);
    final name = kFirstReminderOptions.firstWhere((o) => o.id == d.optionId).name;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            OnboardingTopBar(step: 2, onSkip: () => decidePush(ref, false)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    gradient: AppColors.heroGradient, borderRadius: BorderRadius.circular(28), boxShadow: kCardShadow),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(Img.pushPhoto, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text('Never miss your ${fmtTime(d.time)} dose', textAlign: TextAlign.center, style: AppText.headline),
            const SizedBox(height: 10),
            Text('One gentle nudge for your $name, right when you need it.',
                textAlign: TextAlign.center, style: AppText.bodyMuted),
            const SizedBox(height: 18),
            const AppCard(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(children: [
                _Benefit(
                    Icons.notifications_none_rounded, 'One gentle reminder', 'Delivered at the exact time you picked'),
                _Benefit(Icons.local_fire_department_outlined, 'Keep your streak going',
                    'Watch your consistency grow day by day'),
                _Benefit(Icons.bedtime_outlined, 'Quiet hours, no spam', 'Nothing between 10 PM and 7 AM'),
              ]),
            ),
            const SizedBox(height: 18),
            PrimaryButton('Turn on reminders', trailingArrow: true, onTap: () => decidePush(ref, true)),
            TextAction('Not now', onTap: () => decidePush(ref, false)),
          ]),
        ),
      ),
    );
  }
}

/// Simulates the iOS system prompt result (no real APNs on the simulator demo).
void decidePush(WidgetRef ref, bool allow) {
  ref.read(pushPermissionProvider.notifier).state = allow ? PushPermission.granted : PushPermission.denied;
  ref.read(analyticsProvider).capture(Ev.pushPermission, {'granted': allow, 'asked_after': 'first_reminder_set'});
  Nav.signUp();
}

class _Benefit extends StatelessWidget {
  const _Benefit(this.icon, this.title, this.sub);
  final IconData icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: AppColors.accentFill),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.label.copyWith(fontSize: 16)),
              Text(sub, style: AppText.caption),
            ]),
          ),
        ]),
      );
}

/// 05 - Sign up AFTER value: the routine already exists, account just saves it.
class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final d = ref.watch(firstReminderProvider);
    final o = kFirstReminderOptions.firstWhere((x) => x.id == d.optionId);
    final pushOn = ref.watch(pushPermissionProvider) == PushPermission.granted;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(onPressed: () => Nav.pop(), icon: const Icon(Icons.arrow_back_rounded)),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.accent,
                      child: Icon(Icons.check_rounded, color: Colors.white, size: 20)),
                  SizedBox(width: 10),
                  Text('Your routine is ready', style: AppText.title),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(Img.vitaminBottle, width: 56, height: 56, fit: BoxFit.cover)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o.name, style: AppText.label.copyWith(fontSize: 16)),
                        Text('Every day at ${fmtTime(d.time)}', style: AppText.caption),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Pill(pushOn ? 'Reminders on' : 'Reminders off',
                    dense: true, icon: pushOn ? Icons.notifications_active_outlined : Icons.notifications_off_outlined),
              ]),
            ),
            const SizedBox(height: 30),
            const Text('Save your routine', style: AppText.display),
            const SizedBox(height: 8),
            const Text('Create a free account so you never lose your streak.', style: AppText.bodyMuted),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => _signedUp(ref, 'apple'),
                style: FilledButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
                icon: const Icon(Icons.apple, size: 24),
                label: const Text('Sign in with Apple', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            SecondaryButton('Continue with email', onTap: () => _signedUp(ref, 'email')),
            const SizedBox(height: 14),
            const Center(child: Text('By continuing you agree to Terms and Privacy', style: AppText.caption)),
            const SizedBox(height: 12),
          ]),
        ),
      ),
    );
  }

  void _signedUp(WidgetRef ref, String method) {
    ref.read(analyticsProvider).capture(Ev.signedUp, {'method': method});
    Nav.paywall();
  }
}
