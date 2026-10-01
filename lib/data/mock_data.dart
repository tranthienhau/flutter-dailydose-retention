import 'package:flutter/material.dart';

import '../models/models.dart';

/// Fixed demo clock so every run, screenshot and test is deterministic.
final kNow = DateTime(2026, 10, 2, 8, 0);

/// The user installed yesterday after a paid ad and is on day 6 of the streak.
final kInstallDate = DateTime(2026, 9, 27, 7, 40);

const kUserId = 'usr_maya_8f21';
const kUserName = 'Maya';
const kUserFullName = 'Maya Collins';
const kUserEmail = 'maya.collins@example.com';

class Img {
  static const welcome = 'assets/images/hero-welcome-kitchen.jpg';
  static const goalSupplements = 'assets/images/goal-supplements.jpg';
  static const goalWorkouts = 'assets/images/goal-workouts.jpg';
  static const goalHydration = 'assets/images/goal-hydration.jpg';
  static const goalSleep = 'assets/images/goal-sleep.jpg';
  static const pushPhoto = 'assets/images/photo-push-lockscreen.jpg';
  static const emptyOrganizer = 'assets/images/photo-empty-organizer.jpg';
  static const vitaminBottle = 'assets/images/thumb-vitamin-bottle.jpg';
  static const vitaminD3 = 'assets/images/product-vitamin-d3.jpg';
  static const mayaToday = 'assets/images/avatar-maya-today.jpg';
  static const mayaProfile = 'assets/images/avatar-maya-profile.jpg';
  static const paywallB = 'assets/images/hero-paywall-b-man.jpg';
  static const lockWallpaper = 'assets/images/wallpaper-lockscreen-park.jpg';
  static const walk = 'assets/images/workout-morning-walk.jpg';
  static const stretch = 'assets/images/workout-stretch.jpg';
  static const plank = 'assets/images/workout-core-plank.jpg';
  static const yoga = 'assets/images/workout-evening-yoga.jpg';
  static const logo = 'assets/brand/icon-transparent.png';
}

const kSeedReminders = [
  Reminder(
      id: 'd3',
      name: 'Vitamin D3',
      detail: '2000 IU',
      kind: ReminderKind.supplement,
      time: TimeOfDay(hour: 8, minute: 0),
      subtitle: 'Morning routine',
      withFood: true),
  Reminder(
      id: 'omega3',
      name: 'Omega-3',
      kind: ReminderKind.supplement,
      time: TimeOfDay(hour: 8, minute: 0),
      subtitle: 'Heart and cognitive'),
  Reminder(
      id: 'walk',
      name: 'Morning walk',
      detail: '20 min',
      kind: ReminderKind.workout,
      time: TimeOfDay(hour: 8, minute: 30),
      subtitle: 'Outdoor mobility'),
  Reminder(
      id: 'mag',
      name: 'Magnesium',
      detail: '200 mg',
      kind: ReminderKind.supplement,
      time: TimeOfDay(hour: 21, minute: 30),
      subtitle: 'Evening relaxation'),
  Reminder(
      id: 'stretch',
      name: 'Stretching',
      detail: '10 min',
      kind: ReminderKind.workout,
      time: TimeOfDay(hour: 21, minute: 45),
      subtitle: 'Bedtime mobility'),
];

const kSeedDone = {'d3', 'omega3', 'walk'};

class SupplementOption {
  const SupplementOption(this.id, this.name, this.detail);
  final String id;
  final String name;
  final String detail;
}

const kFirstReminderOptions = [
  SupplementOption('d3', 'Vitamin D3', '2000 IU'),
  SupplementOption('omega3', 'Omega-3', ''),
  SupplementOption('mag', 'Magnesium', '200 mg'),
  SupplementOption('multi', 'Multivitamin', ''),
];

class Workout {
  const Workout(this.id, this.name, this.minutes, this.schedule, this.image);
  final String id;
  final String name;
  final int minutes;
  final String schedule;
  final String image;
}

const kWorkouts = [
  Workout('walk', 'Morning walk', 20, 'Daily, 7:30 AM', Img.walk),
  Workout('stretch', 'Full-body stretch', 10, 'Daily, 9:45 PM', Img.stretch),
  Workout('core', 'Core strength', 15, 'Mon, Wed, Fri', Img.plank),
  Workout('yoga', 'Evening yoga', 12, 'Tue, Thu', Img.yoga),
];

/// Completion % for the last 7 days (oldest first), today last.
const kWeekCompletion = [80, 100, 60, 100, 80, 100, 60];

/// 30-day intake history for Vitamin D3 (true = taken).
final kD3History = List<bool>.generate(30, (i) => !{4, 11, 19, 23}.contains(i));

class Badge {
  const Badge(this.name, this.icon, this.unlocked);
  final String name;
  final IconData icon;
  final bool unlocked;
}

const kBadges = [
  Badge('First week', Icons.event_available_rounded, true),
  Badge('Early bird', Icons.wb_twilight_rounded, true),
  Badge('50 doses', Icons.medication_outlined, false),
];
