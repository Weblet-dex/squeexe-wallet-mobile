import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> restoreOldWallet(WidgetTester tester) async {
  final Finder walletItem = find.byKey(const Key('logged-out-wallet'));
  final Finder passwordField = find.byKey(const Key('enter-password-field'));
  const String password = 'pppaaasssDDD555444@@@';
  await tester.tap(walletItem);
  await tester.pumpAndSettle();
  await tester.tap(passwordField);
  await tester.enterText(passwordField, password);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
