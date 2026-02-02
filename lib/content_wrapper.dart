import 'package:erp_app/index.dart';
import 'package:flutter/material.dart';
import 'package:login_module/micro_app/login_module_events.dart';
import 'package:login_module/micro_app/login_module_resolver.dart';
import 'package:micro_app_commons/app_notifier.dart';
import 'package:micro_app_commons/features/launcher/presentation/bloc/base_bloc/launcher_resolver.dart';
import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_resolver.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_resolver.dart';
import 'package:micro_app_core/index.dart';
import 'package:micro_app_core/services/routing/routes.dart';
import 'package:services_package/storage/domain/usecases/storage_service.dart';

typedef WidgetBuilderArgs = Widget Function(BuildContext context, Object? args);

class ContentWrapper extends StatefulWidget with BaseApp {
  final AppNotifier notifier;
  final ErpResolver _erpResolver = sl<ErpResolver>();
  final LoginModuleResolver _loginResolver = sl<LoginModuleResolver>();
  final LauncherResolver _launcherResolver = sl<LauncherResolver>();
  final NotFoundResolver _notFoundResolver = sl<NotFoundResolver>();
  final PopupResolver _popupResolver = sl<PopupResolver>();

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
  // late final StreamSubscription<ShowPopupEvent> _popupSub;
  // late final StreamSubscription<ErpCloseEvent> _erpCloseSub;
  // late final StreamSubscription<LoginModuleUserLoggedOutEvent> _logoutSub;
  // late final StreamSubscription<LoginModuleUserLoggedInEvent> _loginInSub;
  // late final StreamSubscription<PageNotFoundEvent> _pageNotFoundSub;
  // late final StreamSubscription<ErpShownEvent> _erpShownSub;

  @override
  void initState() {
    super.initState();

    CustomEventBus.on<LoginModuleUserLoggedOutEvent>((event) async {
      await navigatorKey.currentState?.pushReplacementNamed(
        Routes.loginApp.value,
      );
    });

    CustomEventBus.on<LoginModuleUserLoggedInEvent>((event) async {
      await sl<StorageService>().saveLoginSessionModel(event.moduleResult);
      await navigatorKey.currentState?.pushNamed(
        Routes.launcherPage.value,
        arguments: event.moduleResult,
      );
    });

    CustomEventBus.on<ErpShownEvent>((event) async {
      // prefer navigatorKey (BaseApp) to keep routes centralized
      await navigatorKey.currentState?.pushNamed(Routes.erpApp.value);
    });
  }

  // @override
  // void dispose() {
  //   _popupSub.cancel();
  //   _erpCloseSub.cancel();
  //   _logoutSub.cancel();
  //   _loginInSub.cancel();
  //   _pageNotFoundSub.cancel();
  //   _erpShownSub.cancel();
  //   super.dispose();
  // }

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
