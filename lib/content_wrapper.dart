import 'package:erp_app/index.dart';
import 'package:flutter/material.dart';
import 'package:login_module/micro_app/login_module_events.dart';
import 'package:login_module/micro_app/login_module_resolver.dart';
import 'package:micro_app_commons/app_notifier.dart';
import 'package:micro_app_commons/features/launcher/presentation/bloc/base_bloc/launcher_resolver.dart';
import 'package:micro_app_commons/features/not_found/presentation/bloc/base_bloc/not_found_resolver.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_events.dart';
import 'package:micro_app_commons/features/popup/presentation/bloc/base_bloc/popup_resolver.dart';
import 'package:micro_app_core/index.dart';
import 'package:micro_app_core/services/routing/routes.dart';
import 'package:services_package/storage/domain/usecases/storage_service.dart';
import 'package:toastification/toastification.dart';
import 'package:ui_components_package/index.dart';

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
  @override
  void initState() {
    super.initState();

    CustomEventBus.on<LoginModuleUserLoggedOutEvent>((event) async {
      await sl<StorageService>().removeToken();
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
      final resources = await sl<StorageService>().loadLoginSessionModel();
      await navigatorKey.currentState?.pushNamed(
        Routes.erpApp.value,
        arguments: resources,
      );
    });

    // CustomEventBus.on<ShowPopupEvent>((event) async {
    //   loginBlocOnError(context, 'error', event.message);
    // });

    checkToken();
  }

  Future<bool> checkToken() async {
    var token;
    try {
      final storageService = sl<StorageService>();
      token = await storageService.loadToken();
      if (token == null || token == '') {
        final devToken =await storageService.loadDeviceToken();
        navigatorKey.currentState?.pushNamed(
          Routes.loginApp.value,
          arguments: <String, dynamic>{
            'DeviceToken': devToken,
          },
        );
      }
    } catch (e) {}
    if (token == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: widget.generateRoute,
      initialRoute: Routes.launcherPage.value,
    );
  }
}

void loginBlocOnError(
  BuildContext context,
  String? title,
  String? description,
) {
  ModernToast().showToast(
    context,
    Text(title ?? 'خطا'),
    Text(description ?? 'مشکلی رخ داده'),
    ToastificationType.warning,
  );
}
