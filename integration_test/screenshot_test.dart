import 'package:dailydose/demo/autopilot.dart';
import 'package:dailydose/main.dart';
import 'package:dailydose/nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Runs the real app on a simulator and walks the same scripted flow as the
/// demo recording, capturing one PNG per screen into screenshots/.
/// Fixed pumps (not pumpAndSettle) so animated progress never blocks a frame.
/// `--dart-define=SHOT_PREFIX=android-` keeps per-platform captures apart.
const kPrefix = String.fromEnvironment('SHOT_PREFIX');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture every screen of the activation flow', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DailyDoseApp()));
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(seconds: 2));

    final container = ProviderScope.containerOf(navKey.currentContext!);
    for (final step in demoSteps()) {
      step.action(container);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
      await tester.pump(const Duration(milliseconds: 200));
      await binding.takeScreenshot('$kPrefix${step.name}');
    }
  });
}
