import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:proxy_ip_locator/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  Future<void> runIPTest(WidgetTester tester, String testName, {
    int initialDelay = 10,
    int postIPWait = 20,
    bool tapAgain = false,
  }) async {
    await tester.runAsync(() async {
      print("[$testName] Test started. Initial delay: $initialDelay sec");
      await Future.delayed(Duration(seconds: initialDelay));

      app.main();
      await tester.pump();
      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      final buttonFinder = find.byKey(const Key("show_ip_button"));
      expect(buttonFinder, findsOneWidget, reason: "Show IP button not found");

      print("[$testName] Tapping 'Show IP' button...");
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      print("[$testName] Waiting for IP to appear...");

      final timeout = Duration(seconds: 30);
      final pollInterval = Duration(seconds: 1);
      final start = DateTime.now();

      bool ipFound = false;
      String? ipText;
      final ipRegex = RegExp(r'(\d{1,3}\.){3}\d{1,3}');

      while (DateTime.now().difference(start) < timeout && !ipFound) {
        await tester.pump();
        await tester.pump(pollInterval);

        final textWidgets = find.byType(Text).evaluate();
        for (final element in textWidgets) {
          final widget = element.widget as Text;
          final data = widget.data ?? '';
          print("[$testName][DEBUG] Text widget: \"$data\"");
          if (ipRegex.hasMatch(data)) {
            ipFound = true;
            ipText = data;
            break;
          }
        }
      }

      if (!ipFound) {
        print("[$testName][ERROR] IP not found, taking screenshot...");
        await binding.takeScreenshot('${testName}_ip_not_found');
      }

      expect(ipFound, isTrue, reason: "[$testName] IP address did not appear");

      print("[$testName] IP shown: $ipText");
      print("[$testName] Waiting $postIPWait seconds after IP is shown...");
      await Future.delayed(Duration(seconds: postIPWait));

      if (tapAgain) {
        print("[$testName] Retapping button to check repeatability...");
        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
      }

      await Future.delayed(Duration(seconds: 5));
      print("[$testName] Completed ✅");
    });
  }

  // Define 6 unique test cases
  testWidgets("Test_IP_Visibility_Basic", (tester) =>
    runIPTest(tester, "Test_IP_Visibility_Basic"));

  testWidgets("Test_IP_Visibility_With_Long_Initial_Delay", (tester) =>
    runIPTest(tester, "Test_IP_Visibility_With_Long_Initial_Delay", initialDelay: 15));

  testWidgets("Test_IP_Visibility_Quick_Post_IP_Wait", (tester) =>
    runIPTest(tester, "Test_IP_Visibility_Quick_Post_IP_Wait", postIPWait: 5));

}
