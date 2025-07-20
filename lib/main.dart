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

// Import for desktop SQLite support
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite for desktop platforms
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.linux || 
                  defaultTargetPlatform == TargetPlatform.windows || 
                  defaultTargetPlatform == TargetPlatform.macOS)) {
    try {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
      print('SQLite FFI initialized successfully for desktop platform');
    } catch (e) {
      print('Error initializing SQLite FFI: $e');
      // Fallback to regular sqflite if FFI fails
      print('Falling back to regular sqflite');
    }
  }
  
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
              colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(249, 87, 56, 1), brightness: Brightness.light).copyWith(
                background: const Color(0xFFF3E9DC),
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.jetBrainsMonoTextTheme(),
              scaffoldBackgroundColor: const Color(0xFFF3E9DC),
              canvasColor: const Color(0xFFF3E9DC),
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
              scaffoldBackgroundColor: const Color.fromRGBO(30, 31, 30, 1),
              canvasColor: const Color.fromRGBO(30, 31, 30, 1),
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
    seedColor: const Color.fromRGBO(249, 87, 56, 1),
    brightness: Brightness.dark,
  ).copyWith(
    background: const Color.fromRGBO(30, 31, 30, 1),
    surface: Colors.grey[900],
    primary: const Color.fromRGBO(249, 87, 56, 1),
    secondary: const Color.fromRGBO(249, 87, 56, 1),
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
