import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'profile_screen.dart';
import 'routines_progress_screens.dart';

/// Tab shell. One bottom bar, same 4 tabs everywhere (Today, Routines, Progress, Profile).
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(tabProvider);
    const pages = [TodayTab(), RoutinesTab(), ProgressTab(), ProfileTab()];
    return Scaffold(
      body: IndexedStack(index: tab, children: pages),
      floatingActionButton: tab == 0 && ref.watch(remindersProvider).isNotEmpty
          ? FloatingActionButton(
              onPressed: () => Nav.addReminder(),
              backgroundColor: AppColors.accentFill,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 32),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(children: [
              for (final (i, t) in const [
                (Icons.wb_sunny_outlined, 'Today'),
                (Icons.checklist_rounded, 'Routines'),
                (Icons.show_chart_rounded, 'Progress'),
                (Icons.person_outline_rounded, 'Profile'),
              ].indexed)
                Expanded(
                  child: InkWell(
                    onTap: () => ref.read(tabProvider.notifier).state = i,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(t.$1, color: tab == i ? AppColors.accentFill : AppColors.textTertiary, size: 26),
                      const SizedBox(height: 3),
                      Text(t.$2,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: tab == i ? FontWeight.w800 : FontWeight.w600,
                              color: tab == i ? AppColors.accentFill : AppColors.textTertiary)),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// 07 / 08 / 20 - Today: checklist, first-run empty state, push-recovery banner.
class TodayTab extends ConsumerWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final done = ref.watch(doneProvider);
    final streak = ref.watch(streakProvider);
    final offset = ref.watch(dayOffsetProvider);
    final today = kNow.add(Duration(days: offset));
    final denied = ref.watch(pushPermissionProvider) == PushPermission.denied;
    final showBanner = denied && !ref.watch(pushBannerDismissedProvider);
    final missed = ref.watch(missedYesterdayProvider);
    final dateLabel = DateFormat('EEEE, MMM d').format(today);

    if (reminders.isEmpty) return _EmptyToday(dateLabel: dateLabel);

    final n = reminders.where((r) => done.contains(r.id)).length;
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), children: [
        Row(children: [
          const BrandMark(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border)),
            child: Row(children: [
              const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 4),
              Text('$streak ${streak == 1 ? 'Day' : 'Days'}', style: AppText.label),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          const Avatar(Img.mayaToday, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Good morning, $kUserName', style: AppText.headline),
              Text(dateLabel, style: AppText.bodyMuted),
            ]),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
                onPressed: () => Nav.pushSequence(),
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary)),
          ),
        ]),
        const SizedBox(height: 18),
        if (showBanner) ...[const _PushRecoveryBanner(), const SizedBox(height: 14)],
        AppCard(
          gradient: AppColors.heroGradient,
          child: Row(children: [
            Ring(
              value: reminders.isEmpty ? 0 : n / reminders.length,
              size: 104,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$n/${reminders.length}',
                    style:
                        AppText.title.copyWith(color: AppColors.accentFill, fontSize: 24, fontWeight: FontWeight.w800)),
                const Text('DONE', style: AppText.overline),
              ]),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Pill('Day $streak streak', dense: true, icon: Icons.local_fire_department_outlined),
                const SizedBox(height: 10),
                Text("You're ${(n * 100 / reminders.length).round()}% done today", style: AppText.title),
                const SizedBox(height: 4),
                const Text('Keep your morning momentum going.', style: AppText.caption),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        Row(children: [
          const Text('Today', style: AppText.headline),
          const SizedBox(width: 10),
          Pill('${reminders.length} items', dense: true),
          const Spacer(),
          Text(DateFormat('MMM d').format(today),
              style: const TextStyle(color: AppColors.accentFill, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        for (final r in reminders) ...[
          _ReminderRow(r: r, done: done.contains(r.id), missed: missed.contains(r.id)),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }
}

class _ReminderRow extends ConsumerWidget {
  const _ReminderRow({required this.r, required this.done, required this.missed});
  final Reminder r;
  final bool done;
  final bool missed;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
        onTap: () => r.id == 'd3' ? Nav.supplementDetail() : ref.read(doneProvider.notifier).toggle(r.id),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: kCardShadow,
            border: missed ? const Border(left: BorderSide(color: AppColors.warning, width: 4)) : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CheckCircle(done: done, onTap: () => ref.read(doneProvider.notifier).toggle(r.id)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(r.title,
                      style: AppText.label.copyWith(
                        fontSize: 17,
                        color: done ? AppColors.textTertiary : AppColors.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null,
                      )),
                  Text(r.subtitle, style: AppText.caption),
                ]),
              ),
              TimeChip(fmtTime(r.time), highlighted: done),
            ]),
            if (missed) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppColors.warningTint, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text('Missed last night - scheduled for ${fmtTime(r.time)} tonight',
                          style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 13))),
                ]),
              ),
            ],
          ]),
        ),
      );
}

class _PushRecoveryBanner extends ConsumerWidget {
  const _PushRecoveryBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.accentTint,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.accent.withValues(alpha: .25)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CircleIcon(Icons.notifications_off_outlined, bg: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Reminders are off', style: AppText.label),
              const Text('You missed Magnesium last night', style: AppText.caption),
              const SizedBox(height: 10),
              Row(children: [
                FilledButton(
                  onPressed: () {
                    // Real app: openAppSettings(); the demo flips the permission.
                    ref.read(pushPermissionProvider.notifier).state = PushPermission.granted;
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accentFill, shape: const StadiumBorder()),
                  child: const Text('Turn on in Settings', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 6),
                TextAction('Later', onTap: () => ref.read(pushBannerDismissedProvider.notifier).state = true),
              ]),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: CircleAvatar(radius: 5, backgroundColor: AppColors.warning),
          ),
        ]),
      );
}

class _EmptyToday extends ConsumerWidget {
  const _EmptyToday({required this.dateLabel});
  final String dateLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
        bottom: false,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          Row(children: [
            const BrandMark(),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(999)),
              child: const Row(children: [
                Icon(Icons.local_fire_department_rounded, color: AppColors.accentFill, size: 18),
                SizedBox(width: 4),
                Text('Day 1', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.accentFill)),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          const Text('Hi $kUserName', style: AppText.display),
          Text(dateLabel, style: AppText.bodyMuted),
          const SizedBox(height: 40),
          AppCard(
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(aspectRatio: 1.05, child: Image.asset(Img.emptyOrganizer, fit: BoxFit.cover)),
              ),
              const SizedBox(height: 20),
              const Text('Your day is clear', style: AppText.headline),
              const SizedBox(height: 6),
              const Text('Add your first reminder in under a minute',
                  textAlign: TextAlign.center, style: AppText.bodyMuted),
              const SizedBox(height: 18),
              PrimaryButton('Add reminder', icon: Icons.add_rounded, onTap: () => Nav.addReminder()),
            ]),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Popular to start'),
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final s in const ['Vitamin D3', 'Morning walk', 'Omega-3'])
              Pill('+ $s', onTap: () {
                ref.read(remindersProvider.notifier).reset();
              }),
          ]),
        ]),
      );
}

/// 09 - Add reminder sheet.
class AddReminderSheet extends ConsumerStatefulWidget {
  const AddReminderSheet({super.key});

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  int segment = 0;
  String repeat = 'Daily';
  bool withFood = true;
  bool reorder = true;
  final name = TextEditingController(text: 'Magnesium Glycinate');
  final dose = TextEditingController(text: '200 mg');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + MediaQuery.paddingOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
          ),
          const SizedBox(height: 16),
          const Text('New reminder', style: AppText.headline),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(999)),
            child: Row(children: [
              for (final (i, l) in const ['Supplement', 'Workout'].indexed)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => segment = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: segment == i ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: segment == i ? kCardShadow : null),
                      child: Text(l,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: segment == i ? AppColors.accentFill : AppColors.textSecondary)),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 16),
          _Field(label: 'Name', controller: name, focused: true),
          const SizedBox(height: 12),
          _Field(label: 'Dose', controller: dose),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(16)),
            child: const Row(children: [
              Icon(Icons.schedule_rounded, color: AppColors.accentFill),
              SizedBox(width: 10),
              Text('Time', style: AppText.label),
              Spacer(),
              Text('9:30 PM', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(height: 14),
          const Text('Repeat', style: AppText.label),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            for (final r in const ['Daily', 'Weekdays', 'Custom'])
              Pill(r, dense: true, selected: repeat == r, onTap: () => setState(() => repeat = r)),
          ]),
          const SizedBox(height: 8),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: withFood,
              onChanged: (v) => setState(() => withFood = v),
              title: const Text('Take with food', style: AppText.label)),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: reorder,
              onChanged: (v) => setState(() => reorder = v),
              title: const Text('Remind me to reorder', style: AppText.label)),
          const SizedBox(height: 6),
          PrimaryButton('Save reminder', onTap: () {
            ref.read(remindersProvider.notifier).add(Reminder(
                  id: 'mag',
                  name: 'Magnesium',
                  detail: dose.text,
                  kind: segment == 0 ? ReminderKind.supplement : ReminderKind.workout,
                  time: const TimeOfDay(hour: 21, minute: 30),
                  subtitle: 'Evening relaxation',
                  withFood: withFood,
                ));
            Nav.pop();
          }),
        ]),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller, this.focused = false});
  final String label;
  final TextEditingController controller;
  final bool focused;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: focused ? AppColors.accent : AppColors.border, width: focused ? 2 : 1),
          ),
          child: TextField(
            controller: controller,
            style: AppText.body,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ]);
}

/// 10 - Supplement detail with 30-day history and reorder nudge.
class SupplementDetailScreen extends StatelessWidget {
  const SupplementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taken = kD3History.where((x) => x).length;
    return Scaffold(
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), children: [
          Row(children: [
            IconButton(onPressed: () => Nav.pop(), icon: const Icon(Icons.arrow_back_rounded)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
          ]),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: AspectRatio(aspectRatio: 1.35, child: Image.asset(Img.vitaminD3, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 18),
          const Text('Vitamin D3', style: AppText.display),
          const Text('2000 IU, every day at 8:00 AM', style: AppText.bodyMuted),
          const SizedBox(height: 18),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('$taken/30', style: AppText.display.copyWith(color: AppColors.accentFill)),
                const SizedBox(width: 8),
                const Padding(
                    padding: EdgeInsets.only(bottom: 6), child: Text('taken in 30 days', style: AppText.caption)),
              ]),
              const SizedBox(height: 14),
              Wrap(spacing: 9, runSpacing: 9, children: [
                for (final t in kD3History)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t ? AppColors.accent : AppColors.surfaceAlt,
                      border: t ? null : Border.all(color: AppColors.border),
                    ),
                  ),
              ]),
            ]),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.inventory_2_outlined, color: AppColors.accentFill),
                SizedBox(width: 10),
                Text('About 12 days left', style: AppText.title),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                    value: .4, minHeight: 8, color: AppColors.accent, backgroundColor: AppColors.surfaceAlt),
              ),
              const SizedBox(height: 14),
              const SecondaryButton('Remind me to reorder'),
            ]),
          ),
          const SizedBox(height: 14),
          const AppCard(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.restaurant_outlined, color: AppColors.accentFill),
              SizedBox(width: 10),
              Text('Take with breakfast', style: AppText.label),
            ]),
          ),
        ]),
      ),
    );
  }
}
