import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/root_scaffold.dart';
import 'data/accounts_data.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/theme_notifier.dart';
import 'providers/currency_provider.dart';

import 'package:flutter/services.dart';
import 'widgets/screenshot_import_sheet.dart';
import 'widgets/responsive_layout.dart';

void main() {
  runApp(const PayLogsApp());
}

class PayLogsApp extends StatelessWidget {
  const PayLogsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountsData()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PayLogs',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light),
              useMaterial3: true,
              textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme: _customDarkScheme(),
              useMaterial3: true,
              textTheme: GoogleFonts.jetBrainsMonoTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                ),
              ),
              scaffoldBackgroundColor: Colors.black,
              canvasColor: Colors.black,
            ),
            themeMode: themeNotifier.themeMode,
            home: const ResponsiveLayout(
              child: _ShareIntentHandler(),
            ),
          );
        },
      ),
    );
  }
}

ColorScheme _customDarkScheme() {
  return ColorScheme.fromSeed(
    seedColor: Colors.deepOrange.shade700,
    brightness: Brightness.dark,
  ).copyWith(
    background: Colors.black,
    surface: Colors.grey[900],
    primary: Colors.deepOrange.shade400,
    secondary: Colors.amber.shade700,
    onBackground: Colors.white,
    onSurface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  );
}

class _ShareIntentHandler extends StatefulWidget {
  const _ShareIntentHandler({super.key});

  @override
  State<_ShareIntentHandler> createState() => _ShareIntentHandlerState();
}

class _ShareIntentHandlerState extends State<_ShareIntentHandler> {
  static const MethodChannel _channel = MethodChannel('paylogs/share_intent');
  bool _overlayShown = false;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onImageShared') {
      final String imagePath = call.arguments as String;
      debugPrint('Received shared image path: $imagePath');
      if (!_overlayShown) {
        _overlayShown = true;
        if (mounted) {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ScreenshotImportSheet(imagePath: imagePath),
          );
        }
        _overlayShown = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the normal app root
    return const RootScaffold();
  }
}
