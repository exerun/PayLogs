import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/root_scaffold.dart';
import 'data/accounts_data.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/transaction.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  ThemeProvider(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final lightThemeData = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'JetBrainsMono',
  scaffoldBackgroundColor: Colors.white,
  cardColor: const Color(0xFFF4F4F4),
  dividerColor: const Color(0xFFE0E0E0),
  iconTheme: const IconThemeData(color: Colors.black),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0.5,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      fontFamily: 'JetBrainsMono',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.black,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(fontFamily: 'JetBrainsMono', color: Colors.black),
    bodyMedium: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF444444)),
    bodySmall: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF444444)),
    titleLarge: const TextStyle(fontFamily: 'JetBrainsMono', color: Colors.black),
    titleMedium: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF444444)),
    titleSmall: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF444444)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF4F4F4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6C7CFF), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF444444)),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFF4F4F4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 8),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFFF4F4F4),
    modalBackgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    buttonColor: const Color(0xFF6C7CFF),
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF6C7CFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF6C7CFF),
      side: const BorderSide(color: Color(0xFF6C7CFF), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF6C7CFF),
      textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6C7CFF),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    elevation: 0,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFFF4F4F4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
    contentTextStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF444444)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFFF4F4F4),
    contentTextStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFF444444)),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE0E0E0),
    thickness: 1,
    space: 24,
  ),
);

final darkThemeData = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'JetBrainsMono',
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  dividerColor: const Color(0xFF444444),
  iconTheme: const IconThemeData(color: Colors.white),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0.5,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontFamily: 'JetBrainsMono',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: const TextStyle(fontFamily: 'JetBrainsMono', color: Colors.white),
    bodyMedium: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFFBBBBBB)),
    bodySmall: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFFBBBBBB)),
    titleLarge: const TextStyle(fontFamily: 'JetBrainsMono', color: Colors.white),
    titleMedium: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFFBBBBBB)),
    titleSmall: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFFBBBBBB)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E1E1E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF444444)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF444444)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6C7CFF), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    hintStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFFBBBBBB)),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 8),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    modalBackgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    buttonColor: const Color(0xFF6C7CFF),
    textTheme: ButtonTextTheme.primary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xFF6C7CFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF6C7CFF),
      side: const BorderSide(color: Color(0xFF6C7CFF), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF6C7CFF),
      textStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6C7CFF),
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    elevation: 0,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
    contentTextStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFFBBBBBB)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: const Color(0xFF1E1E1E),
    contentTextStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: Color(0xFFBBBBBB)),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF444444),
    thickness: 1,
    space: 24,
  ),
);

ThemeData _buildTheme(ColorScheme colorScheme, bool isDark) {
  return ThemeData(
    colorScheme: colorScheme,
    fontFamily: 'JetBrainsMono',
    scaffoldBackgroundColor: colorScheme.background,
    cardColor: colorScheme.surface,
    dividerColor: isDark ? Color(0xFF444444) : Color(0xFFE0E0E0),
    iconTheme: IconThemeData(color: isDark ? Color(0xFFBBBBBB) : Color(0xFF444444)),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.background,
      elevation: 0.5,
      shadowColor: isDark ? Color(0xFF222222) : Color(0x11000000),
      titleTextStyle: TextStyle(
        fontFamily: 'JetBrainsMono',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: colorScheme.onBackground,
      ),
      iconTheme: IconThemeData(color: isDark ? Color(0xFFBBBBBB) : Color(0xFF444444)),
      toolbarTextStyle: TextStyle(
        fontFamily: 'JetBrainsMono',
        color: colorScheme.onBackground,
      ),
      foregroundColor: colorScheme.onBackground,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      displayMedium: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      displaySmall: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      headlineLarge: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      headlineMedium: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      headlineSmall: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      titleLarge: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      titleMedium: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground.withOpacity(0.8)),
      titleSmall: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground.withOpacity(0.7)),
      bodyLarge: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground),
      bodyMedium: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground.withOpacity(0.8)),
      bodySmall: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onBackground.withOpacity(0.6)),
      labelLarge: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.primary),
      labelMedium: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.primary.withOpacity(0.8)),
      labelSmall: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.primary.withOpacity(0.6)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Color(0xFF444444) : Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Color(0xFF444444) : Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onSurface.withOpacity(0.5)),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      modalBackgroundColor: isDark ? Color(0xFF222222) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      buttonColor: colorScheme.primary,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, fontSize: 20, color: colorScheme.onSurface),
      contentTextStyle: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onSurface),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.surface,
      contentTextStyle: TextStyle(fontFamily: 'JetBrainsMono', color: colorScheme.onSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? Color(0xFF444444) : Color(0xFFE0E0E0),
      thickness: 1,
      space: 24,
    ),
    // Add more widget theming as needed
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set minimum window size for desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // Note: This would require window_manager package for actual implementation
    // For now, we'll handle responsive constraints in the UI layout
  }
  
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(AccountAdapter());

  final prefs = await SharedPreferences.getInstance();
  final storedTheme = prefs.getString('themeMode') ?? 'light';
  final themeMode = storedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

  runApp(MyApp(themeMode: themeMode));
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(themeMode),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AccountsData()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => BudgetProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PayLogs',
              theme: lightThemeData,
              darkTheme: darkThemeData,
              themeMode: themeProvider.themeMode,
        home: const RootScaffold(),
            ),
          );
        },
      ),
    );
  }
}


