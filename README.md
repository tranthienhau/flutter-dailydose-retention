# DailyDose - activation, paywall and push retention (Flutter)

A daily health routine app (supplements, reminders, workouts) built around the three things that decide whether a paid install turns into a paying habit: **reaching the first reminder fast**, a **trial-to-paid paywall that can be A/B tested** (RevenueCat-shaped), and **push notifications + a daily check-in** that bring people back on day 1, 3, 5 and 7.

Flutter + Riverpod, iOS and Android from one codebase, built from a Google Stitch design (20 screens).

## Demo

| iOS | Android |
|---|---|
| ![iOS demo](screenshots/demo.gif) | ![Android demo](screenshots/demo-android.gif) |

Same codebase running on both platforms.

## What it shows

- **Value before sign-up.** Goal pick -> first reminder (Vitamin D3, 8:00 AM) -> push primer -> sign-up. The account screen only saves a routine that already exists. `first_reminder_set` is the activation event.
- **Push permission asked at the right moment.** A soft primer right after the first reminder, so the one-shot iOS system prompt is only shown to people who already want it. Saying "Not now" leads to a recovery banner on Today the next morning ("You missed Magnesium last night").
- **Paywall A/B test.** Variant A explains the trial timeline (today, day 5 reminder, day 7 billing). Variant B leads with social proof, the user's own plan and a free-trial toggle. Users are split 50/50 by a stable hash of their id, and every `paywall_viewed` / `trial_started` event carries the variant and offering id.
- **Trial-to-paid.** Day 5 trial-ending screen recaps what the user built (41 doses, 6 day streak) before asking. Cancelling opens a win-back screen with a promotional offer (50% off the first year), switch to monthly, or pause.
- **Lifecycle push sequence.** `PushScheduler` builds the plan: dose reminders with Done / Snooze actions, day 1 / 3 / 7 messages, the trial-ending nudge 2 days before billing, and an 8 PM daily check-in. Quiet hours (10 PM - 7 AM) move anything that would land overnight.
- **Daily check-in loop.** Mood, energy, finish today's routine, then a streak celebration with tomorrow's plan and the check-in reminder toggle.
- **Funnel analytics.** PostHog-style `capture()` with super properties (`campaign`, `media_source` from AppsFlyer) so drop-off can be split by ad campaign.

## Screenshots

| Welcome | Goal pick | First reminder | Push primer | Sign up |
|---|---|---|---|---|
| ![Welcome](screenshots/01-welcome.png) | ![Goal pick](screenshots/02-goal-pick.png) | ![First reminder](screenshots/03-first-reminder.png) | ![Push primer](screenshots/04-push-primer.png) | ![Sign up](screenshots/05-sign-up.png) |

| Paywall A (timeline) | Paywall B (social proof) | Today | Add reminder | Supplement detail |
|---|---|---|---|---|
| ![Paywall A](screenshots/06-paywall-a.png) | ![Paywall B](screenshots/07-paywall-b.png) | ![Today](screenshots/08-today.png) | ![Add reminder](screenshots/09-add-reminder.png) | ![Supplement detail](screenshots/10-supplement-detail.png) |

| Routines | Progress | Profile + notification prefs | Push sequence | Trial ending |
|---|---|---|---|---|
| ![Routines](screenshots/11-routines.png) | ![Progress](screenshots/12-progress.png) | ![Profile](screenshots/13-profile.png) | ![Push sequence](screenshots/14-push-sequence.png) | ![Trial ending](screenshots/15-trial-ending.png) |

| Win-back offer | Daily check-in | Check-in complete | Push recovery | Empty state |
|---|---|---|---|---|
| ![Win-back](screenshots/16-win-back.png) | ![Daily check-in](screenshots/17-daily-check-in.png) | ![Check-in complete](screenshots/18-check-in-complete.png) | ![Push recovery](screenshots/19-push-recovery.png) | ![Empty](screenshots/20-today-empty.png) |

Android captures of every screen are in `screenshots/android-*.png`.

## App flow

```mermaid
flowchart TD
    A[Paid ad install<br/>AppsFlyer campaign] --> B[Welcome]
    B --> C[Goal pick]
    C --> D[Set first reminder<br/>first_reminder_set]
    D --> E{Push primer}
    E -- Turn on --> F[iOS permission prompt]
    E -- Not now --> G[Permission denied]
    F --> H[Sign up]
    G --> H
    H --> I{Paywall variant}
    I -- A --> J[Trial timeline paywall]
    I -- B --> K[Social proof paywall]
    J --> L[7 day trial starts]
    K --> L
    L --> M[Today checklist]
    G -. next morning .-> N[Recovery banner on Today]
    N --> M
    M --> O[Day 1 / 3 / 7 pushes]
    M --> P[8 PM daily check-in]
    P --> Q[Streak + tomorrow plan]
    L --> R[Day 5 trial ending]
    R -- Keep --> S[Paid]
    R -- Cancel --> T[Win-back offer]
    T -- Claim 50% off --> S
    T -- Continue --> U[Cancelled]
```

## Architecture

```mermaid
flowchart LR
    subgraph UI[Screens - lib/screens]
        OB[Onboarding<br/>welcome, goal, first reminder,<br/>push primer, sign up]
        PW[Monetization<br/>paywall A/B, trial ending, win-back]
        CORE[Core tabs<br/>Today, Routines, Progress, Profile]
        ENG[Engagement<br/>push sequence, check-in]
    end

    subgraph STATE[Riverpod - lib/state/providers.dart]
        EXP[paywallVariantProvider]
        CI[customerInfoProvider]
        REM[remindersProvider + doneProvider]
        PERM[pushPermissionProvider + notificationPrefsProvider]
        PLAN[pushPlanProvider]
        CHK[checkInDraftProvider + streakProvider]
    end

    subgraph SVC[Services - lib/services]
        RC[PurchasesService<br/>RevenueCat-shaped:<br/>offerings, purchase, promo offer]
        PS[PushScheduler<br/>pure plan builder,<br/>quiet hours]
        AN[Analytics<br/>PostHog-shaped capture,<br/>funnel, variant hash]
    end

    subgraph EXT[Production backends]
        RCX[(RevenueCat)]
        PHX[(PostHog)]
        AFX[(AppsFlyer)]
        OSX[(OneSignal / Braze)]
    end

    OB --> REM
    OB --> PERM
    PW --> EXP
    PW --> CI
    CORE --> REM
    CORE --> PERM
    ENG --> PLAN
    ENG --> CHK
    CI --> RC
    PLAN --> PS
    REM --> PLAN
    PERM --> PLAN
    EXP --> AN
    CI --> AN
    CHK --> AN
    RC -. swap for purchases_flutter .-> RCX
    AN -. swap for posthog_flutter .-> PHX
    AFX -. campaign super props .-> AN
    PS -. same plan as server journey .-> OSX
```

Rendered PNG versions of every diagram are in `docs/diagrams/`.

Services are plain Dart with the same call shapes as the real SDKs, so moving to production is a swap, not a rewrite: `PurchasesService` -> `purchases_flutter`, `Analytics.capture` -> `posthog_flutter`, `PushScheduler` output -> `flutter_local_notifications` for dose reminders and a OneSignal / Braze journey for the lifecycle messages.

## Sequence diagrams

### Activation: first reminder -> push permission -> trial

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant App as DailyDose app
    participant AN as Analytics (PostHog)
    participant OS as iOS
    participant RC as Purchases (RevenueCat)

    U->>App: Open after ad install
    App->>AN: app_opened {campaign, media_source, variant}
    U->>App: Pick goals (Supplements)
    App->>AN: goal_selected
    U->>App: Save Vitamin D3 at 8:00 AM
    App->>AN: first_reminder_set {seconds_since_open}
    App->>U: Push primer ("Never miss your 8:00 AM dose")
    App->>AN: push_primer_shown
    U->>App: Turn on reminders
    App->>OS: requestPermission()
    OS-->>App: granted / denied
    App->>AN: push_permission_result {granted}
    U->>App: Sign in with Apple
    App->>AN: signed_up
    App->>RC: getOfferings() for variant a or b
    RC-->>App: offering + packages (yearly 7 day trial, monthly)
    App->>AN: paywall_viewed {variant, offering}
    U->>App: Try free for 7 days
    App->>RC: purchasePackage(yearly)
    RC-->>App: CustomerInfo (entitlement: trial)
    App->>AN: trial_started {product_id, variant}
```

### Lifecycle push + daily check-in

```mermaid
sequenceDiagram
    autonumber
    participant PS as PushScheduler
    participant N as Notifications (local / OneSignal)
    actor U as User
    participant App as DailyDose app
    participant AN as Analytics

    PS->>PS: plan(install, reminders, prefs, permission, trialStart)
    Note over PS: Dose reminders daily, day 1 / 3 / 7,<br/>trial-end on day 5 at 10 AM,<br/>check-in daily at 8 PM, quiet hours 10 PM - 7 AM
    PS->>N: schedule(plan)
    N->>U: Day 1 - Vitamin D3 at 8:00 AM [Done] [Snooze 15 min]
    U->>N: Done
    N->>App: action "Done"
    App->>AN: dose_logged {reminder_id: d3}
    N->>U: 8:00 PM Evening check-in
    U->>App: Open check-in (mood, energy, finish routine)
    App->>AN: checkin_completed {mood, energy, routine_done, streak}
    App->>U: 7 day streak + tomorrow plan
    N->>U: Day 5 - Your free trial ends in 2 days
    U->>App: Open trial ending
    App->>AN: trial_ending_viewed
```

### Cancel -> win-back

```mermaid
sequenceDiagram
    autonumber
    actor U as User
    participant App as DailyDose app
    participant RC as Purchases (RevenueCat)
    participant AN as Analytics

    U->>App: Profile > Manage subscription > Cancel
    App->>AN: winback_offer_shown {offer: winback_annual_50}
    App->>U: Recap (41 doses, 6 day streak) + 50% off / monthly / pause
    alt Claim 50% off
        U->>App: Claim 50% off
        App->>RC: purchase promotional offer
        RC-->>App: CustomerInfo (active, promo)
        App->>AN: winback_accepted
    else Continue to cancel
        U->>App: Continue to cancel
        App->>AN: subscription_cancelled
    end
```

## Funnel events

| Step | Event | Key properties |
|---|---|---|
| 1 | `app_opened` | `campaign`, `media_source`, `variant` |
| 2 | `goal_selected` | `goals` |
| 3 | `first_reminder_set` (activation) | `supplement`, `time`, `seconds_since_open` |
| 4 | `push_permission_result` | `granted`, `asked_after` |
| 5 | `signed_up` | `method` |
| 6 | `paywall_viewed` | `variant`, `offering`, `placement` |
| 7 | `trial_started` | `product_id`, `variant`, `trial_days` |
| - | `dose_logged`, `checkin_completed` | retention signals |
| - | `trial_ending_viewed`, `winback_offer_shown`, `winback_accepted`, `subscription_cancelled` | trial-to-paid |

## Project structure

```
lib/
  main.dart                 app entry, DEMO autopilot switch
  nav.dart                  single navigator (taps, push deep links, autopilot)
  theme/app_theme.dart      design tokens from the Stitch design (Nunito Sans + Lora)
  models/models.dart        Reminder, Package, Offering, CustomerInfo, PushMessage, CheckIn
  data/mock_data.dart       fixed demo clock, user, reminders, workouts, history
  services/
    purchases_service.dart  RevenueCat-shaped offerings, trial, promo offer
    push_scheduler.dart     lifecycle push plan + quiet hours (unit tested)
    analytics.dart          PostHog-shaped capture, funnel, A/B variant hash
  state/providers.dart      Riverpod providers
  screens/                  onboarding, paywall, today, routines/progress, profile, engagement
  demo/autopilot.dart       scripted walkthrough shared by demo + screenshot test
test/                       push scheduler + purchases / experiment unit tests
integration_test/           screenshot harness
design/                     Stitch design system, per-screen HTML + PNG, logo
```

## Run

```sh
flutter pub get
flutter test          # 10 unit tests: push plan, quiet hours, trial, win-back, A/B split, funnel
flutter run           # iOS simulator or Android emulator
```

No backend, camera or hardware needed. The demo clock is fixed to Oct 2, 2026 so every run looks the same.
