import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/search_screen.dart';
import 'services/click_tracking_service.dart';
import 'services/hotkey_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(500, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
  });

  await ClickTrackingService.init();
  await HotKeyService.registerHotkey();

  runApp(const PeepHoleApp());
}

class PeepHoleApp extends StatefulWidget {
  const PeepHoleApp({Key? key}) : super(key: key);

  @override
  State<PeepHoleApp> createState() => _PeepHoleAppState();
}

class _PeepHoleAppState extends State<PeepHoleApp> with WindowListener {
  late GlobalKey<NavigatorState> navigatorKey;

  @override
  void initState() {
    super.initState();
    navigatorKey = GlobalKey<NavigatorState>();
    windowManager.addListener(this);
    HotKeyService.hotkeyStream.listen((_) => _showSearchWindow());
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _showSearchWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeepHole',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: const SearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
