// ignore_for_file: implementation_imports, library_prefixes

import 'package:flutter/cupertino.dart';

import 'package:micro_app_core/index.dart';


import '../../../main.dart';
import 'main_events.dart';

import 'main_inject.dart';

class MainResolver
    extends  MicroApp<ContainerCoreModel, ContainerAppsCoreEnum> {
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
    CustomEventBus.on<MainAppSignOutEvents>((event) {
      // we can use events to navigate as well.
      // Routing.pushNamed<UserLoggedOutEvent>(Routes.SignIn);
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

  //
  // @override
  // void registerDependencies() {
  //   // ۱. ثبت وابستگی‌های عمومی میکرواپ ERP در سرویس لوکیتور
  //   sl.registerFactory(
  //     () => AppNotifier(map: () => AppsConstants$DynamicPageBuilder().getMap),
  //   );
  //
  //   // ۲. ثبت فانکشن‌های دریافتی از کانتینر، در دسترس برای کل میکرواپ
  //   _callbacks.forEach((key, callback) {
  //     sl.registerFactoryParam<Function, void, void>(
  //       (_, __) => callback,
  //       instanceName: key.toString(),
  //     );
  //   });
  //
  //   // ۳. ثبت فکتوری برای استور Redux (نسخه بهبودیافته متد getStore شما)
  //   // sl.registerFactoryParam<Store, BaseRequest Function(), BaseResponse Function(Map)>(
  //   // (requestFactory, fromJsonD) => _createStore(requestFactory, fromJsonD),
  //   // );
  // }

  void setCoreData(ContainerCoreModel initDt) {}
}
