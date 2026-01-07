import 'dart:async';
import 'dart:io';
import 'package:erp_app/page_cache_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_app_commons/app_notifier.dart';

import 'package:erp_app/core/network/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:resources_package/Resources/Theme/theme_manager.dart';

import 'content_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final appNotifier = AppNotifier();
  sl.registerLazySingleton<AppNotifier>(() => appNotifier);

  try {
    await Future.wait(<Future<void>>[
      InjectionContainer.init(),
      ThemeManager.init(),
    ]);
  } catch (e, stackTrace) {
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(RootApp(netMode: 0));
}

class RootApp extends StatelessWidget {
  final int netMode;

  const RootApp({super.key, required this.netMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageCacheProvider()),
        ChangeNotifierProvider(create: (_) => sl<AppNotifier>()),
      ],
      child: AppView(networkMode: netMode),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class AppView extends StatefulWidget {
  final int networkMode;

  const AppView({super.key, required this.networkMode});

  @override
  State<AppView> createState() => _AppViewScreenState();
}

class _AppViewScreenState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    final AppNotifier notifier = Provider.of<AppNotifier>(context);
    final ThemeManager themeConfig = context.select(
      (AppNotifier n) => n.themeConfig,
    );

    return MaterialApp(
      home: ContentWrapper(notifier: notifier),

      title: 'Khatoon Container',
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      // Localization
      supportedLocales: const <Locale>[Locale('fa'), Locale('en')],
      locale: themeConfig.localMode,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
            if (locale == null) return supportedLocales.first;
            return supportedLocales.firstWhere(
              (Locale supported) =>
                  supported.languageCode == locale.languageCode,
              orElse: () => supportedLocales.first,
            );
          },

      themeMode: ThemeManager.themeMode,
      theme: _buildTheme(themeConfig.primaryColor, Brightness.light),
      darkTheme: _buildTheme(themeConfig.primaryColor, Brightness.dark),
    );
  }
}

ThemeData _buildTheme(Color seedColor, Brightness brightness) {
  final bool isDark = brightness == Brightness.dark;
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ),
    useMaterial3: true,
    fontFamily: 'Vazirani',
    scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.white,
  );
}
