# DailyDose Design System

Daily health routine app (supplements, reminders, workouts). Bright, calm, spacious, rounded.

## Color - use ONLY these colors, no default violet/indigo, no flat neutral grey
- Background: #F4FCFB (tinted near-white)
- Surface: #FFFFFF cards and sheets; Surface alt: #EAF6F4 grouped rows
- Accent (bright sea teal): #14B8A6 - large fills, icons, active states, hero numerals
- Accent fill: #0E8376 - every button or chip with a WHITE label; pressed #0B6E63
- Accent tint: #E3F7F4 - selected states, badges, chips
- Support (soft lilac): #DDA8F0 - charts, illustrations, gradient end only, never a primary button
- Text primary #0C1F1D, secondary #4A615E, tertiary #7C918E
- Border #D7E8E5; Success #16A34A; Warning #D97706; Danger #DC2626

## Typography
- UI + body: Nunito Sans. Display / hero titles: Lora (serif).
- Display 32/700 -0.02em; Title 20/600; Body 16/400; Label 14/600; Caption 13/500 secondary color.

## Frame + safe areas
- 393x852 mobile. Keep top ~59px (status bar) and bottom ~34px (home indicator) clear of tappable content.

## Shape, spacing, elevation, icons
- Radius: card 20, control 14, input 12, pill 999. 8pt spacing, 20px screen edge padding.
- Soft shadows only: 0 1px 2px rgba(12,31,29,.04) + 0 8px 24px rgba(12,31,29,.06).
- One icon set: rounded outline 24px, 1.75 stroke (Lucide style). Never mix filled icons.

## Controls (one spec, reused everywhere)
- Primary button: full-width pill, #0E8376 fill, white Nunito Sans 16/700 label; pressed #0B6E63; disabled 40% opacity.
- Secondary button: pill, 1.5px #0E8376 outline, #0E8376 label.
- Input: 12px radius, #D7E8E5 border; focus = 2px #14B8A6 ring; error = #DC2626 border + caption.
- Card: white, 20px radius, soft shadow.
- Chip: pill, #E3F7F4 fill, #0E8376 label; selected = #0E8376 fill, white label.
- Checklist row: circle check on left (done = #14B8A6 filled with white check), title, time caption on right.

## Gradient + focal rules
- Soft gradient #14B8A6 -> #DDA8F0 (low contrast) only on hero, onboarding illustration, streak card and paywall hero. Tab bar is flat.
- Every screen has ONE bold focal element (streak ring, big time, hero photo, trial card). Everything else quiet.

## Shared components
- Bottom tab bar (only on Today, Routines, Progress, Profile screens): exactly 4 tabs in this order: Today (sun icon), Routines (list-checks icon), Progress (chart-line icon), Profile (user icon). Active tab: #0E8376 icon + label. Inactive: #7C918E. Flat white bar, 1px #D7E8E5 top border, labels 12/600. Never rename, reorder, add or remove tabs.
- Onboarding, auth, paywall, sheets, detail and trial screens show NO tab bar.
- Onboarding progress: 3 small dots top center, active dot is a #14B8A6 pill.

## Imagery
- Real photography: warm natural morning light, kitchens, outdoor walks, diverse adults 25-45, subtle teal and lilac accents. Empty states also use real photos. NO 3D renders, claymorphism, isometric or CGI objects anywhere.
