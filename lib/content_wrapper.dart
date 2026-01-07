// ignore_for_file: implementation_imports

import 'package:erp_app/micro_app/erp_events.dart';
import 'package:erp_app/micro_app/erp_resolver.dart';
import 'package:flutter/cupertino.dart';
import 'package:login_module/micro_app/login_module_events.dart';
import 'package:login_module/micro_app/login_module_resolver.dart';
import 'package:micro_app_commons/app_notifier.dart';
import 'package:micro_app_commons/features/launcher/presentation/bloc/base_bloc/launcher_resolver.dart';
import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_events.dart';

import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_resolver.dart';
import 'package:micro_app_commons/features/popup/domain/entities/enum.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_events.dart';

import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_resolver.dart';
import 'package:micro_app_commons/features/popup/presentation/popup_page.dart';
import 'package:micro_app_core/services/custom_event_bus/custom_event_bus.dart';
import 'package:micro_app_core/services/routing/routes.dart';
import 'package:micro_app_core/services/routing/routing.dart';
import 'package:micro_app_core/src/micro_app.dart';
import 'package:micro_app_core/src/micro_core_utils.dart';
import 'package:micro_app_core/src/base_app.dart' as base_app;

class ContentWrapper extends StatefulWidget with base_app.BaseApp {
  final AppNotifier notifier;

  ContentWrapper({super.key, required this.notifier}) {
    initialiseRouting();
  }

  @override
  State<ContentWrapper> createState() => _ContentWrapperState();

  @override
  Map<String, WidgetBuilderArgs> get baseRoutes =>
      <String, WidgetBuilderArgs>{};

  @override
  List<MicroApp> get microApps => <MicroApp>[
    ErpResolver(),
    LoginModuleResolver(),
    LauncherResolver(),
    NotFoundResolver(),
    PopupResolver(),
  ];
}

class _ContentWrapperState extends State<ContentWrapper> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: super.widget.generateRoute,
      initialRoute: Routes.launcherPage.value,
    );
  }

  @override
  void initState() {
    super.initState();

    CustomEventBus.on<ShowPopupEvent>((event) {
      PopupPage(
        type: PopupType.success,
        title: 'ارسال پیام',
        description: 'پیام شما با موفقیت ارسال شد.',
      );
    });

    CustomEventBus.on<LoginModuleUserLoggedOutEvent>((event) {
      navigatorKey.currentState?.pushNamed(Routes.loginApp.value);
    });

    CustomEventBus.on<LoginModuleUserLoggedInEvent>((event) async {
      await Routing.pushNamed(Routes.launcherPage);
    });

    CustomEventBus.on<PageNotFoundEvent>((event) async {
      await Routing.pushNamed(Routes.loginApp);
    });

    CustomEventBus.on<ErpShownEvent>((event) async{
      await Routing.pushNamed(Routes.erpApp);
    });
  }
}
