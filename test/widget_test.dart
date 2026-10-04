import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_cloud_frontend/main.dart';

void main() {
  testWidgets('shows the movie collection shell', (tester) async {
    await tester.pumpWidget(const MovieCloudApp());

    expect(find.text('Movie Cloud'), findsOneWidget);
    expect(find.text('Your collection'), findsOneWidget);
    expect(find.text('A good story starts here'), findsOneWidget);
  });

  testWidgets('empty collection fits a short viewport', (tester) async {
    tester.view.physicalSize = const Size(900, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MovieCloudApp());

    expect(tester.takeException(), isNull);
  });
}
