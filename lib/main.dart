import 'dart:async';
import 'dart:io';
import 'package:erp_app/feature/auth/menu/bloc/menu_bloc.dart';
import 'package:erp_app/feature/auth/menu/bloc/menu_event.dart';
import 'package:erp_app/feature/com/person/presentation/blocs/person_bloc/person_list_bloc.dart';
import 'package:erp_app/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_module/micro_app/login_module_resolver.dart';
import 'package:micro_app_commons/app_notifier.dart';

import 'package:flutter/material.dart';
import 'package:micro_app_commons/features/launcher/presentation/bloc/base_bloc/launcher_resolver.dart';
import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_resolver.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_resolver.dart';
import 'package:micro_app_core/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:resources_package/Resources/Theme/theme_manager.dart' as res;
import 'package:services_package/com/person/person_service.dart';
import 'package:services_package/storage/domain/usecases/storage_service.dart';

import 'content_wrapper.dart';
import 'micro_base_app/bloc/base_bloc/main_resolver.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  try {
    await Future.wait(<Future<void>>[
      InjectionContainer.init(),
      res.AppTheme.init(),
    ]);
    sl.registerSingleton<ErpResolver>(ErpResolver());
    sl.registerSingleton<ErpFormGeneratorResolver>(ErpFormGeneratorResolver());
    sl.registerSingleton<LauncherResolver>(LauncherResolver());
    sl.registerSingleton<LoginModuleResolver>(LoginModuleResolver());
    sl.registerSingleton<NotFoundResolver>(NotFoundResolver());
    sl.registerSingleton<PopupResolver>(PopupResolver());
    sl.registerSingleton<MainResolver>(MainResolver());
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDaFoQ1BufZNuUKKYrVfnoAPjVytggLeJY',
        appId: '1:511210742680:android:a754014ad3e3daefab81ed',
        messagingSenderId: '511210742680',
        projectId: 'aryanerp-e996e',
        databaseURL: 'https://aryanerp-e996e-default-rtdb.firebaseio.com',
        storageBucket: 'aryanerp-e996e.firebasestorage.app',
        androidClientId:
            '511210742680-xxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com',
      ),
    );

    String? token = await FirebaseMessaging.instance.getToken();
    if(token != null){
      await sl<StorageService>().saveDeviceToken(token);
    }


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
    final res.AppTheme themeConfig = context.select(
      (AppNotifier n) => n.themeConfig,
    );

    return MaterialApp(
      home: ContentWrapper(notifier: notifier),
      showSemanticsDebugger: false,
      title: 'Khatoon Container',
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      // Localization
      supportedLocales: const [Locale('fa'), Locale('en')],
      locale: themeConfig.localMode,
      localizationsDelegates: const [
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

      themeMode: res.AppTheme().themeMode,
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
  return res.AppTheme.build(
    seedColor,
    isDark ? Brightness.dark : Brightness.light,
  );
}
