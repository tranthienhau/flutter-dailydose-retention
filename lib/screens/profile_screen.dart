import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../nav.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'paywall_screens.dart';

/// 14 - Profile: plan badge, notification preferences, subscription management.
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);
    final info = ref.watch(customerInfoProvider);
    final setPrefs = ref.read(notificationPrefsProvider.notifier);
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        const Row(children: [BrandMark()]),
        const SizedBox(height: 14),
        const Text('Profile', style: AppText.display),
        const SizedBox(height: 16),
        AppCard(
          child: Column(children: [
            Row(children: [
              const Avatar(Img.mayaProfile, size: 84),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text(kUserFullName, style: AppText.headline),
                  const Text(kUserEmail, style: AppText.caption),
                  const SizedBox(height: 8),
                  Pill(plusBadge(info, kNow), dense: true, icon: Icons.auto_awesome_outlined),
                ]),
              ),
            ]),
            const Divider(height: 32, color: AppColors.border),
            Row(children: [
              const Expanded(child: _Num('6', 'Day streak', accent: true)),
              Container(width: 1, height: 36, color: AppColors.border),
              const Expanded(child: _Num('86%', 'Consistency')),
              Container(width: 1, height: 36, color: AppColors.border),
              Expanded(child: _Num('${ref.watch(remindersProvider).length}', 'Routines')),
            ]),
          ]),
        ),
        const SizedBox(height: 22),
        const SectionLabel('Notifications'),
        _Group(children: [
          _ToggleRow(Icons.alarm_rounded, 'Dose reminders', 'Scheduled reminder alarms', prefs.doseReminders,
              (v) => setPrefs.state = prefs.copyWith(doseReminders: v)),
          _ToggleRow(Icons.wb_twilight_rounded, 'Daily check-in', '8:00 PM evening review', prefs.dailyCheckIn,
              (v) => setPrefs.state = prefs.copyWith(dailyCheckIn: v)),
          _ToggleRow(Icons.forward_to_inbox_outlined, 'Weekly progress email', 'Every Sunday evening summary',
              prefs.weeklyEmail, (v) => setPrefs.state = prefs.copyWith(weeklyEmail: v)),
          _ToggleRow(Icons.card_giftcard_outlined, 'Tips and offers', 'New features and wellness tips',
              prefs.tipsAndOffers, (v) => setPrefs.state = prefs.copyWith(tipsAndOffers: v)),
          _NavRow(Icons.bedtime_outlined, 'Quiet hours', 'No pushes while you sleep',
              trailing: '${fmtTime(prefs.quietStart)} - ${fmtTime(prefs.quietEnd)}'),
          _NavRow(Icons.notifications_active_outlined, 'Push schedule', 'Day 1, 3, 5 and 7 messages',
              onTap: () => Nav.pushSequence()),
        ]),
        const SizedBox(height: 22),
        const SectionLabel('Account'),
        _Group(children: [
          _NavRow(Icons.workspace_premium_outlined, 'Manage subscription', null,
              chip: info.isPlus ? 'Trial active' : 'Free', onTap: () => Nav.trialEnding()),
          const _NavRow(Icons.restore_rounded, 'Restore purchases', null),
          const _NavRow(Icons.help_outline_rounded, 'Help and feedback', null),
          const _NavRow(Icons.logout_rounded, 'Sign out', null, danger: true),
        ]),
      ]),
    );
  }
}

class _Num extends StatelessWidget {
  const _Num(this.value, this.label, {this.accent = false});
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: AppText.title.copyWith(fontSize: 24, color: accent ? AppColors.accentFill : AppColors.textPrimary)),
        Text(label, style: AppText.caption),
      ]);
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (final (i, c) in children.indexed) ...[
            c,
            if (i < children.length - 1) const Divider(height: 1, color: AppColors.border),
          ],
        ]),
      );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow(this.icon, this.title, this.sub, this.value, this.onChanged);
  final IconData icon;
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          CircleIcon(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.label.copyWith(fontSize: 16)),
              Text(sub, style: AppText.caption),
            ]),
          ),
          Switch(value: value, onChanged: onChanged),
        ]),
      );
}

class _NavRow extends StatelessWidget {
  const _NavRow(this.icon, this.title, this.sub, {this.trailing, this.chip, this.danger = false, this.onTap});
  final IconData icon;
  final String title;
  final String? sub;
  final String? trailing;
  final String? chip;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            CircleIcon(icon,
                bg: danger ? const Color(0xFFFDECEC) : AppColors.accentTint,
                fg: danger ? AppColors.danger : AppColors.accentFill),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style:
                        AppText.label.copyWith(fontSize: 16, color: danger ? AppColors.danger : AppColors.textPrimary)),
                if (sub != null) Text(sub!, style: AppText.caption),
              ]),
            ),
            if (trailing != null) Text(trailing!, style: AppText.label.copyWith(color: AppColors.textSecondary)),
            if (chip != null) Pill(chip!, dense: true),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: danger ? AppColors.danger : AppColors.textTertiary),
          ]),
        ),
      );
}
