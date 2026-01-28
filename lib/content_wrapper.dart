import 'dart:async';
import 'package:erp_app/index.dart';
import 'package:flutter/material.dart';
import 'package:erp_app/micro_app/erp_events.dart';
import 'package:erp_app/micro_app/erp_resolver.dart';
import 'package:login_module/micro_app/login_module_events.dart';
import 'package:login_module/micro_app/login_module_resolver.dart';
import 'package:micro_app_commons/app_notifier.dart';
import 'package:micro_app_commons/features/launcher/presentation/bloc/base_bloc/launcher_resolver.dart';
import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_events.dart';
import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_resolver.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_resolver.dart';
import 'package:micro_app_commons/features/popup/presentation/popup_page.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_events.dart';
import 'package:micro_app_core/services/custom_event_bus/custom_event_bus.dart';
import 'package:micro_app_core/services/routing/routes.dart';
import 'package:micro_app_core/services/routing/routing.dart';

import 'package:micro_app_core/index.dart';

typedef WidgetBuilderArgs = Widget Function(BuildContext context, Object? args);

class ContentWrapper extends StatefulWidget with BaseApp {
  final AppNotifier notifier;
  final ErpResolver _erpResolver =sl<ErpResolver>();
  final LoginModuleResolver _loginResolver =sl<LoginModuleResolver>();
  final LauncherResolver _launcherResolver = sl<LauncherResolver>();
  final NotFoundResolver _notFoundResolver =sl<NotFoundResolver>();
  final PopupResolver _popupResolver =sl<PopupResolver>();

  ContentWrapper({super.key, required this.notifier}) {
    initialiseRouting();
  }

  @override
  State<ContentWrapper> createState() => _ContentWrapperState();

  @override
  Map<String, WidgetBuilderArgs> get baseRoutes =>
      <String, WidgetBuilderArgs>{};

  // return the same list (same instances) always
  @override
  List<MicroApp> get microApps => <MicroApp>[
    _erpResolver,
    _loginResolver,
    _launcherResolver,
    _notFoundResolver,
    _popupResolver,
  ];
}

class _ContentWrapperState extends State<ContentWrapper> {
  // use the navigatorKey provided by BaseApp (from.micro_core_utils)
  // make sure this key is unique in whole app (don't create other navigators with same key)
  // final GlobalKey<NavigatorState> _localNavigatorKey =
  //     GlobalKey<NavigatorState>(debugLabel: 'contentWrapperNavigator');

  // keep subscriptions to cancel on dispose
  late final StreamSubscription<ShowPopupEvent> _popupSub;
  late final StreamSubscription<ErpCloseEvent> _erpCloseSub;
  late final StreamSubscription<LoginModuleUserLoggedOutEvent> _logoutSub;
  late final StreamSubscription<LoginModuleUserLoggedInEvent> _loginInSub;
  late final StreamSubscription<PageNotFoundEvent> _pageNotFoundSub;
  late final StreamSubscription<ErpShownEvent> _erpShownSub;

  @override
  void initState() {
    super.initState();

    // initialiseRouting must run after first frame (widget tree mounted)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // BaseApp.initialiseRouting uses widget.microApps and baseRoutes
        widget.initialiseRouting();
      } catch (e, st) {
        debugPrint('initialiseRouting error: $e\n$st');
      }
    });

    final bus = CustomEventBus();

    // show popup using local navigator context (safe)
    _popupSub = bus.stream<ShowPopupEvent>().listen((event) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        showDialog(
          context: ctx,
          builder: (_) => PopupPage(
            type: event.type,
            title: event.message ?? '',
            description: event.message ?? '',
          ),
        );
      }
    });

    // ERP close -> pop on same navigator
    _erpCloseSub = bus.stream<ErpCloseEvent>().listen((_) async {
      await navigatorKey.currentState?.maybePop();
    });

    // LoginModule logout -> navigate to login App (use global routing if desired)
    _logoutSub = bus.stream<LoginModuleUserLoggedOutEvent>().listen((_) async {
      // using BaseApp's navigatorKey: ensure it's the correct one
      await navigatorKey.currentState?.pushNamed(Routes.loginApp.value);
    });

    // on login in -> go to launcher page
    _loginInSub = bus.stream<LoginModuleUserLoggedInEvent>().listen((_) async {
      await Routing.pushNamed(Routes.launcherPage);
    });

    _pageNotFoundSub = bus.stream<PageNotFoundEvent>().listen((_) async {
      await Routing.pushNamed(Routes.loginApp);
    });

    // ERP shown -> open ERP route (use global routing so it resolves properly)
    _erpShownSub = bus.stream<ErpShownEvent>().listen((_) async {
      // prefer navigatorKey (BaseApp) to keep routes centralized
      await navigatorKey.currentState?.pushNamed(Routes.erpApp.value);
    });
  }

  @override
  void dispose() {
    _popupSub.cancel();
    _erpCloseSub.cancel();
    _logoutSub.cancel();
    _loginInSub.cancel();
    _pageNotFoundSub.cancel();
    _erpShownSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // use the BaseApp's generateRoute so it uses the microApps registered above
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: widget.generateRoute,
      initialRoute: Routes.launcherPage.value,
    );
  }
}
