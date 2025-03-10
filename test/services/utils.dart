import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> invokeMethodCall(
  MethodCall methodCall, {
  required String channelName,
}) =>
    ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
      channelName,
      const StandardMethodCodec().encodeMethodCall(methodCall),
      (data) {},
    );

/// Helper function to change orientation of device in widget test.
void changeOrientation(
  WidgetTester tester, {
  required bool landscape,
  Size? size,
}) {
  late Size testSize;
  if (size != null) {
    testSize = size;
  } else {
    testSize = landscape ? const Size(1600, 400) : const Size(400, 1600);
  }
  tester.binding.window.physicalSizeTestValue = testSize;
  tester.binding.window.devicePixelRatioTestValue = 1;
}

/// Resets all changed sizes or pixel Usually called at the end of test and after using [changeOrientation].
void clearTestValues(WidgetTester tester) {
  tester.binding.window.clearPhysicalSizeTestValue();
  tester.binding.window.clearDevicePixelRatioTestValue();
}
