import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onTap, this.icon, this.trailingArrow = false});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          onPressed: onTap ?? () {},
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentFill,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            elevation: 0,
            textStyle: const TextStyle(fontFamily: kSans, fontSize: 17, fontWeight: FontWeight.w700),
          ).copyWith(overlayColor: WidgetStateProperty.all(AppColors.accentPressed.withValues(alpha: .25))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(label),
            if (trailingArrow) ...[const SizedBox(width: 10), const Icon(Icons.arrow_forward_rounded, size: 20)],
          ]),
        ),
      );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onTap ?? () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentFill,
            side: const BorderSide(color: AppColors.accentFill, width: 1.5),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontFamily: kSans, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          child: Text(label),
        ),
      );
}

class TextAction extends StatelessWidget {
  const TextAction(this.label, {super.key, this.onTap, this.color = AppColors.textSecondary});
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap ?? () {},
        style: TextButton.styleFrom(foregroundColor: color, minimumSize: const Size(44, 44)),
        child:
            Text(label, style: TextStyle(fontFamily: kSans, fontSize: 16, fontWeight: FontWeight.w600, color: color)),
      );
}

class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20),
      this.color,
      this.border,
      this.gradient});
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final BoxBorder? border;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? AppColors.surface) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: border,
          boxShadow: kCardShadow,
        ),
        child: child,
      );
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.selected = false, this.onTap, this.icon, this.dense = false});
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.accentFill : AppColors.accentTint,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 18, vertical: dense ? 6 : 11),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? Colors.white : AppColors.accentFill),
                const SizedBox(width: 6)
              ],
              Text(label,
                  style: TextStyle(
                      fontFamily: kSans,
                      fontSize: dense ? 13 : 15,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.accentFill)),
            ]),
          ),
        ),
      );
}

class ProgressDots extends StatelessWidget {
  const ProgressDots({super.key, required this.index, this.count = 3});
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 26 : 8,
            height: 8,
            decoration: BoxDecoration(
                color: i == index ? AppColors.accent : AppColors.border, borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
}

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({super.key, required this.step, this.onBack, this.onSkip});
  final int step;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: Row(children: [
          IconButton(
              onPressed: onBack ?? () => Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back_rounded)),
          const Spacer(),
          ProgressDots(index: step),
          const Spacer(),
          TextAction('Skip', onTap: onSkip, color: AppColors.textTertiary),
        ]),
      );
}

class CircleIcon extends StatelessWidget {
  const CircleIcon(this.icon,
      {super.key, this.size = 44, this.bg = AppColors.accentTint, this.fg = AppColors.accentFill});
  final IconData icon;
  final double size;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: fg, size: size * .5),
      );
}

class CheckCircle extends StatelessWidget {
  const CheckCircle({super.key, required this.done, this.onTap, this.size = 30});
  final bool done;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.accent : Colors.transparent,
            border: Border.all(color: done ? AppColors.accent : AppColors.border, width: 2),
          ),
          child: done ? Icon(Icons.check_rounded, size: size * .62, color: Colors.white) : null,
        ),
      );
}

class TimeChip extends StatelessWidget {
  const TimeChip(this.label, {super.key, this.highlighted = false});
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.accentTint : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: highlighted ? null : Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: kSans,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: highlighted ? AppColors.accentFill : AppColors.textSecondary)),
      );
}

class Avatar extends StatelessWidget {
  const Avatar(this.asset, {super.key, this.size = 56, this.ring = true});
  final String asset;
  final double size;
  final bool ring;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(ring ? 3 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ring ? const LinearGradient(colors: [AppColors.accent, AppColors.support]) : null,
        ),
        child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover)),
      );
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Image.asset(Img.logo, width: size + 8, height: size + 8),
        const SizedBox(width: 6),
        Text('DailyDose',
            style: TextStyle(
                fontFamily: kSerif, fontSize: size, fontWeight: FontWeight.w700, color: AppColors.accentFill)),
      ]);
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Row(children: [
          Text(text.toUpperCase(), style: AppText.overline),
          const Spacer(),
          if (trailing != null) trailing!
        ]),
      );
}

/// Ring progress used by the streak card.
class Ring extends StatelessWidget {
  const Ring({super.key, required this.value, this.size = 96, this.stroke = 10, this.child});
  final double value;
  final double size;
  final double stroke;
  final Widget? child;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: stroke,
              strokeCap: StrokeCap.round,
              backgroundColor: Colors.white.withValues(alpha: .7),
              color: AppColors.accentFill,
            ),
          ),
          if (child != null) child!,
        ]),
      );
}

String fmtTime(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  return '$h:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
}
