import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/root_scaffold.dart';
import 'data/accounts_data.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'widgets/screenshot_import_sheet.dart';

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PayLogs',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const _ShareIntentHandler(),
      ),
    );
  }
}

class _ShareIntentHandler extends StatefulWidget {
  const _ShareIntentHandler({Key? key}) : super(key: key);

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
