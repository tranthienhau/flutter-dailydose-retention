import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo/autopilot.dart';
import 'nav.dart';
import 'screens/onboarding_screens.dart';
import 'services/analytics.dart';
import 'state/providers.dart';
import 'theme/app_theme.dart';

/// `--dart-define=DEMO=true` walks the app hands-free (used for demo recordings).
const kDemo = bool.fromEnvironment('DEMO');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const ProviderScope(child: DailyDoseApp()));
}

class DailyDoseApp extends ConsumerStatefulWidget {
  const DailyDoseApp({super.key});

  @override
  ConsumerState<DailyDoseApp> createState() => _DailyDoseAppState();
}

class _DailyDoseAppState extends ConsumerState<DailyDoseApp> {
  @override
  void initState() {
    super.initState();
    ref.read(analyticsProvider).capture(Ev.appOpened, {'variant': ref.read(paywallVariantProvider)});
    if (kDemo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Autopilot().run());
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'DailyDose',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        navigatorKey: navKey,
        home: const WelcomeScreen(),
      );
}
