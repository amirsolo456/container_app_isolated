import 'dart:async';
import 'dart:io';
import 'package:erp_app/feature/auth/menu/bloc/menu_bloc.dart';
import 'package:erp_app/feature/auth/menu/bloc/menu_event.dart';
import 'package:erp_app/feature/com/person/presentation/blocs/person_bloc/person_list_bloc.dart';
import 'package:erp_app/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_module/micro_app/login_module_resolver.dart';
import 'package:micro_app_commons/app_notifier.dart';

import 'package:erp_app/core/network/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:micro_app_commons/features/launcher/presentation/bloc/base_bloc/launcher_resolver.dart';
import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_resolver.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_resolver.dart';
import 'package:micro_app_core/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:resources_package/Resources/Theme/theme_manager.dart';
import 'package:services_package/com/person/person_service.dart';

import 'content_wrapper.dart';
import 'micro_base_app/bloc/base_bloc/main_resolver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  try {
    final erpResolver = ErpResolver();
    final launcherResolver = LauncherResolver();
    final loginModuleResolver = LoginModuleResolver();
    final notFoundResolver = NotFoundResolver();
    final popupResolver = PopupResolver();

    sl.registerSingleton<ErpResolver>(erpResolver);
    sl.registerSingleton<LauncherResolver>(launcherResolver);
    sl.registerSingleton<LoginModuleResolver>(loginModuleResolver);
    sl.registerSingleton<NotFoundResolver>(notFoundResolver);
    sl.registerSingleton<PopupResolver>(popupResolver);
    sl.registerSingleton<MainResolver>(MainResolver());
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<AppNotifier>()),
        BlocProvider(create: (_) => sl<MenuBloc>()..add(LoadMenuEvent())),
        BlocProvider(
          create: (_) => PersonListBloc(personService: sl<PersonService>()),
        ),
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
    final AppNotifier notifier = sl<AppNotifier>();
    final ThemeManager themeConfig = context.select(
      (AppNotifier n) => n.themeConfig,
    );

    return MaterialApp(
      home: ContentWrapper(notifier: notifier),
      showSemanticsDebugger: false,
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

void registerMicroApps() {
  // ۱. MicroAppNotifier
  sl.registerLazySingleton<
    MicroAppNotifier<ContainerCoreModel, ContainerAppsCoreEnum>
  >(
    () => MicroAppNotifier<ContainerCoreModel, ContainerAppsCoreEnum>(
      ContainerCoreModel(),
    ),
  );

  // ۲. Resolver
  sl.registerLazySingleton<ErpResolver>(() => ErpResolver());

  // مشابه برای Login
  sl.registerLazySingleton<LoginModuleResolver>(() => LoginModuleResolver());

  // و برای دیگر میکرو اپ‌ها
  sl.registerLazySingleton<LauncherResolver>(() => LauncherResolver());
  sl.registerLazySingleton<NotFoundResolver>(() => NotFoundResolver());
  sl.registerLazySingleton<PopupResolver>(() => PopupResolver());
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
