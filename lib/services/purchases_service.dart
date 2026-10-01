import '../models/models.dart';

/// In-memory stand-in for the RevenueCat SDK (`purchases_flutter`).
///
/// Mirrors the calls a real integration makes: fetch offerings, pick the
/// current offering for the user's experiment variant, purchase a package
/// (starting the intro trial when the package has one), restore, and apply a
/// promotional offer in the cancel flow. Swapping in the real SDK keeps the
/// same method shapes: `Purchases.getOfferings()`, `Purchases.purchasePackage()`,
/// `Purchases.restorePurchases()`, `Purchases.getCustomerInfo()`.
class PurchasesService {
  PurchasesService({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  CustomerInfo _info = const CustomerInfo();

  static const yearly = Package(
    id: '\$rc_annual',
    productId: 'dd_plus_yearly_3999',
    title: 'Yearly',
    price: 39.99,
    period: 'year',
    trialDays: 7,
    badge: 'Save 58%',
    perMonth: 3.33,
  );

  static const monthly = Package(
    id: '\$rc_monthly',
    productId: 'dd_plus_monthly_799',
    title: 'Monthly',
    price: 7.99,
    period: 'month',
  );

  /// Promotional offer shown in the cancel flow (App Store promotional offer).
  static const winBackYearly = Package(
    id: 'winback_annual_50',
    productId: 'dd_plus_yearly_3999',
    title: 'Yearly, first year 50% off',
    price: 19.99,
    period: 'year',
    badge: '50% off',
  );

  /// `a` = control paywall (trial timeline), `b` = social proof + personalised plan.
  static const offerings = {
    'a': Offering(id: 'default_a_timeline', variant: 'a', packages: [yearly, monthly]),
    'b': Offering(id: 'b_social_proof', variant: 'b', packages: [yearly, monthly]),
  };

  Offering currentOffering(String variant) => offerings[variant] ?? offerings['a']!;

  CustomerInfo get customerInfo => _info;

  /// Starts the intro trial for packages that have one, else activates.
  CustomerInfo purchase(Package p) {
    _info = _info.copyWith(
      status: p.trialDays > 0 ? EntitlementStatus.trial : EntitlementStatus.active,
      productId: p.productId,
      trialStart: p.trialDays > 0 ? _clock() : null,
    );
    return _info;
  }

  CustomerInfo applyWinBack() {
    _info = _info.copyWith(status: EntitlementStatus.active, promoApplied: true);
    return _info;
  }

  CustomerInfo cancel() {
    _info = _info.copyWith(status: EntitlementStatus.cancelled);
    return _info;
  }

  CustomerInfo restore() => _info;

  /// Demo hook: put the user mid-trial (installed a few days ago).
  void seedTrial(DateTime start, {String productId = 'dd_plus_yearly_3999'}) {
    _info = CustomerInfo(status: EntitlementStatus.trial, productId: productId, trialStart: start);
  }
}
