import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tun_editor/tun_editor.dart';

void main() {
  const MethodChannel channel = MethodChannel('tun_editor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TunEditor.platformVersion, '42');
  });
}
