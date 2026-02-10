// ignore_for_file: implementation_imports, library_prefixes

import 'package:erp_app/core/network/injection_container.dart';
import 'package:flutter/cupertino.dart';

import 'package:micro_app_core/index.dart';
import 'package:services_package/storage/domain/usecases/storage_service.dart';

import '../../../main.dart';
import 'main_events.dart';

import 'main_inject.dart';

class MainResolver extends MicroApp<ContainerCoreModel, ContainerAppsCoreEnum> {
  final Map<ContainerAppsCoreEnum, MicroAppAction> callbacks;

  MainResolver()
    : callbacks = {
        ContainerAppsCoreEnum.containerLoadLogin: () {},
        ContainerAppsCoreEnum.containerLoadErp: () {},
        ContainerAppsCoreEnum.containerLoadApp: () {},
        ContainerAppsCoreEnum.containerLoadSplash: () {},
        ContainerAppsCoreEnum.containerWidthLogin: () {},
      },
      super(
        ContainerCoreModel(
          customFunctions: {
            ContainerAppsCoreEnum.containerLoadLogin: () {},
            ContainerAppsCoreEnum.containerLoadErp: () {},
            ContainerAppsCoreEnum.containerLoadApp: () {},
            ContainerAppsCoreEnum.containerLoadSplash: () {},
            ContainerAppsCoreEnum.containerWidthLogin: () {},
          },
        ),
      );

  @override
  String get microAppName => initData.name.toString();

  @override
  Map<String, WidgetBuilderArgs> get routes => <String, WidgetBuilderArgs>{
    microAppName: (BuildContext context, Object? args) =>
        const RootApp(netMode: 0),
  };

  @override
  void initEventListeners() {
    CustomEventBus.on<MainAppSignOutEvents>((event) async {
      await sl<StorageService>().removeToken();
    });
    // CustomEventBus.on<UserLoggedInEvent>((event) {
    //   Routing.pushNamed(Routes.purchases);
    // });
  }

  @override
  MainEvents microAppEvents() => MainEvents();

  @override
  Widget? microAppWidget() => null;

  @override
  void injectionsRegister() => Inject.initialize(map: callbacks);

  @override
  TransitionType? get transitionType => TransitionType.fade;

  void onErpDefaultTabMode() {}

  void onErpDashboardTabMode() {}

  void onErpGenericFormTabMode() {}

  void onErpGenericListTabMode() {}

  void onErpMenuTabMode() {}

  void onErpOpenedTabMode() {}

  void onErpNewTabMode() {}

  void onErpNotFound() {}

  void onErpProfileTabMode() {}

  ContainerCoreModel get initData => throw UnimplementedError();

  void setCoreData(ContainerCoreModel initDt) {}
}
