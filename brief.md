# DailyDose - Source Brief

## Title
DailyDose - daily supplements, workouts and reminders

## Description
DailyDose helps people keep a daily health routine: supplements, short workouts and the reminders that make them stick. A new user picks what they want to stay on top of, sets their first reminder (for example Vitamin D3 at 8:00 AM) in under a minute, and only then creates an account to save it. After a 7-day free trial of DailyDose Plus, the app keeps people coming back with actionable push reminders, an 8 PM evening check-in and a visible streak, and it recaps what they built before the trial ends.

## Store links
Not yet published (proof of concept).

## Platform
Both - iOS and Android from one Flutter codebase.

## Category
Health and Fitness

## Features
- Value-first onboarding: goal pick, first reminder, push permission primer, then sign-up
- Soft push primer before the one-shot iOS permission prompt, plus a recovery banner when reminders are off
- Two paywall variants split 50/50 per user: trial timeline (A) and social proof with a personalised plan and free-trial toggle (B)
- Yearly plan with a 7-day trial and a monthly plan, restore purchases
- Day 5 trial-ending screen with a recap of doses, streak and workouts
- Cancel flow with a 50% first-year promotional offer, switch to monthly, or pause reminders
- Lifecycle push plan: dose reminders with Done / Snooze actions, day 1 / 3 / 7 messages, trial-end nudge, daily check-in, quiet hours 10 PM - 7 AM
- Evening check-in (mood, energy, finish today's routine) and a streak celebration with tomorrow's plan
- Today checklist with progress ring, add-reminder sheet, supplement detail with 30-day history and reorder nudge
- Routines (workouts with photos, supplements), progress (weekly completion, best streak, badges), profile with notification preferences
- Funnel analytics events from install to trial start, tagged with ad campaign and paywall variant

## Tech stack
- Flutter / Dart, iOS + Android
- State: Riverpod (Notifier + StateProvider)
- Monetization: RevenueCat-shaped purchases service (offerings, packages, trial, promotional offer), ready to swap for `purchases_flutter`
- Push: pure `PushScheduler` plan builder with quiet hours, ready for `flutter_local_notifications` (dose reminders) and OneSignal / Braze journeys (lifecycle)
- Analytics: PostHog-shaped `capture()` with super properties, funnel step tracking, deterministic A/B variant hash; AppsFlyer campaign as a super property
- Design: Google Stitch design system (Nunito Sans + Lora, sea teal + lilac), bundled real photography
- Testing: unit tests for the push plan, quiet hours, trial, win-back, A/B split and funnel; integration_test screenshot harness

## Industry
Consumer health and wellness, subscription apps.

## Metrics
Unpublished proof of concept, so there are no store ratings, downloads or conversion numbers yet. Scope: 20 screens, 15 funnel and retention events, 10 unit tests.

## Research notes
- Verified: push plan timing (day 1, 3, 5 trial-end at 10 AM, 7, daily 8 PM check-in, quiet-hours shift), trial length and days-left math, win-back state change, stable 50/50 variant split, funnel step tracking - all covered by unit tests.
- Mocked: purchases, push delivery and analytics run in memory; the iOS permission prompt and Settings deep link are simulated; the clock is fixed to Oct 2, 2026 for repeatable demos; user, reminders, history and stats are fixture data.
- Future expansion: real RevenueCat offerings and paywall experiments, PostHog feature flags and funnels, AppsFlyer attribution SDK, OneSignal or Braze lifecycle journeys and email (day 1, 3, 7, trial end), HealthKit sync, home screen widget, weekly progress email.
