import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// 11 - Routines: workouts with real photos, supplements list.
class RoutinesTab extends ConsumerWidget {
  const RoutinesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seg = ref.watch(routinesSegmentProvider);
    final supplements = ref.watch(remindersProvider).where((r) => r.kind == ReminderKind.supplement).toList();
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        Row(children: [
          const Text('Routines', style: AppText.display),
          const Spacer(),
          Material(
            color: AppColors.accentFill,
            shape: const CircleBorder(),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.add_rounded, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(999)),
          child: Row(children: [
            for (final (i, l) in const ['Supplements', 'Workouts'].indexed)
              Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(routinesSegmentProvider.notifier).state = i,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: seg == i ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: seg == i ? kCardShadow : null),
                    child: Text(l,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: seg == i ? AppColors.accentFill : AppColors.textSecondary)),
                  ),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 18),
        if (seg == 1) ...[
          _FeaturedWorkout(w: kWorkouts.first),
          const SizedBox(height: 16),
          for (final w in kWorkouts.skip(1)) ...[_WorkoutRow(w: w), const SizedBox(height: 12)],
        ] else
          for (final r in supplements) ...[
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(r.id == 'd3' ? Img.vitaminD3 : Img.goalSupplements,
                      width: 60, height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.title, style: AppText.label.copyWith(fontSize: 16)),
                    Text(r.subtitle, style: AppText.caption),
                  ]),
                ),
                TimeChip(fmtTime(r.time)),
              ]),
            ),
            const SizedBox(height: 12),
          ],
      ]),
    );
  }
}

class _FeaturedWorkout extends StatelessWidget {
  const _FeaturedWorkout({required this.w});
  final Workout w;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 230,
          child: Stack(fit: StackFit.expand, children: [
            Image.asset(w.image, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC0C1F1D)]),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Pill('Featured', dense: true),
                const SizedBox(height: 8),
                Text(w.name, style: AppText.headline.copyWith(color: Colors.white)),
                Text('${w.minutes} min - ${w.schedule}', style: const TextStyle(color: Colors.white, fontSize: 15)),
              ]),
            ),
          ]),
        ),
      );
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.w});
  final Workout w;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(w.image, width: 84, height: 72, fit: BoxFit.cover)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.name, style: AppText.label.copyWith(fontSize: 16)),
              Text('${w.minutes} min', style: AppText.caption),
              const SizedBox(height: 6),
              Pill(w.schedule, dense: true),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ]),
      );
}

/// 12 - Progress: streak, weekly completion, badges.
class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    const days = ['F', 'S', 'S', 'M', 'T', 'W', 'Th'];
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        const Row(children: [BrandMark()]),
        const SizedBox(height: 14),
        Row(children: [
          const Text('Progress', style: AppText.display),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border)),
            child: const Text('Sep 26 - Oct 2', style: AppText.label),
          ),
        ]),
        const SizedBox(height: 16),
        AppCard(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Pill('Active streak', dense: true, icon: Icons.local_fire_department_outlined),
                const SizedBox(height: 8),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('$streak', style: AppText.display.copyWith(fontSize: 72, height: 1)),
                  const SizedBox(width: 10),
                  const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('day streak', style: AppText.title)),
                ]),
                const SizedBox(height: 6),
                const Text('On track to beat your personal best.', style: AppText.caption),
              ]),
            ),
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.accentTint, shape: BoxShape.circle),
              child: const Icon(Icons.local_fire_department_outlined, color: AppColors.accent, size: 44),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Daily completion', style: AppText.title)),
              Container(width: 16, height: 3, color: AppColors.support),
              const SizedBox(width: 6),
              const Text('Goal 80%', style: AppText.caption),
            ]),
            const SizedBox(height: 18),
            SizedBox(
              height: 170,
              child: Stack(children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 24 + 112 * .2 + 6,
                  child: Container(height: 2, color: AppColors.support.withValues(alpha: .7)),
                ),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (final (i, v) in kWeekCompletion.indexed)
                    Expanded(
                      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('$v%',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: i == 6 ? AppColors.accentFill : AppColors.textTertiary)),
                        const SizedBox(height: 6),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          height: 112 * v / 100,
                          decoration: BoxDecoration(
                            color: i == 6 ? AppColors.accentFill : AppColors.accent.withValues(alpha: .85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(days[i],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: i == 6 ? AppColors.accentFill : AppColors.textTertiary)),
                      ]),
                    ),
                ]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        const Row(children: [
          Expanded(child: _MiniStat('Best streak', '14 days', 'Achieved in Sept', Icons.emoji_events_outlined)),
          SizedBox(width: 12),
          Expanded(child: _MiniStat('This month', '86%', 'Adherence rate', Icons.calendar_month_outlined)),
        ]),
        const SizedBox(height: 14),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Milestones and badges', style: AppText.title),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              for (final b in kBadges)
                Column(children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: b.unlocked ? AppColors.accentTint : AppColors.surfaceAlt,
                    ),
                    child: Icon(b.unlocked ? b.icon : Icons.lock_outline_rounded,
                        color: b.unlocked ? AppColors.accentFill : AppColors.textTertiary, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(b.name,
                      style:
                          AppText.label.copyWith(color: b.unlocked ? AppColors.textPrimary : AppColors.textTertiary)),
                  Text(b.unlocked ? 'Earned' : '38/50 done',
                      style:
                          AppText.caption.copyWith(color: b.unlocked ? AppColors.accentFill : AppColors.textTertiary)),
                ]),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value, this.sub, this.icon);
  final String label;
  final String value;
  final String sub;
  final IconData icon;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(label, style: AppText.caption), const Spacer(), CircleIcon(icon, size: 34)]),
          const SizedBox(height: 10),
          Text(value, style: AppText.headline),
          Text(sub, style: AppText.caption),
        ]),
      );
}
