import 'package:dailydose/models/models.dart';
import 'package:dailydose/services/analytics.dart';
import 'package:dailydose/services/purchases_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 2, 8);

  test('yearly package starts a 7 day trial, monthly activates directly', () {
    final a = PurchasesService(clock: () => now);
    final info = a.purchase(PurchasesService.yearly);
    expect(info.status, EntitlementStatus.trial);
    expect(info.trialEnd, DateTime(2026, 10, 9, 8));
    expect(info.daysLeft(now), 7);

    final b = PurchasesService(clock: () => now);
    expect(b.purchase(PurchasesService.monthly).status, EntitlementStatus.active);
  });

  test('win-back offer keeps the subscriber active with the promo flag', () {
    final p = PurchasesService(clock: () => now)..seedTrial(DateTime(2026, 9, 27));
    expect(p.customerInfo.daysLeft(now), 2);
    final info = p.applyWinBack();
    expect(info.status, EntitlementStatus.active);
    expect(info.promoApplied, isTrue);
  });

  test('offering follows the experiment variant', () {
    final p = PurchasesService();
    expect(p.currentOffering('a').id, 'default_a_timeline');
    expect(p.currentOffering('b').id, 'b_social_proof');
    expect(p.currentOffering('zzz').variant, 'a');
  });

  test('paywall variant is stable per user and splits users across both arms', () {
    expect(paywallVariant('usr_1'), paywallVariant('usr_1'));
    final arms = {for (var i = 0; i < 200; i++) paywallVariant('usr_$i')};
    expect(arms, {'a', 'b'});
  });

  test('funnel step reports the furthest activation step reached', () {
    final a = Analytics(clock: () => now);
    expect(a.funnelStep(), -1);
    a
      ..capture(Ev.appOpened)
      ..capture(Ev.goalSelected)
      ..capture(Ev.firstReminderSet);
    expect(kFunnel[a.funnelStep()], Ev.firstReminderSet);
  });
}
