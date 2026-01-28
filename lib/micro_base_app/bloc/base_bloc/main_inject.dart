import 'package:container_app/micro_base_app/bloc/base_bloc/main_resolver.dart';
import 'package:erp_app/index.dart';
import 'package:micro_app_commons/app_notifier.dart';
import 'package:micro_app_core/index.dart';
import 'package:micro_app_core/utils/models/core_dto.dart';

class Inject {
  static void initialize({
    required Map<ContainerAppsCoreEnum, MicroAppAction> map,
  }) {
    final manager = MicroAppManager.instance;
    sl.registerSingleton<
      MicroAppNotifier<ContainerCoreModel, ContainerAppsCoreEnum>
    >(
      MicroAppNotifier<ContainerCoreModel, ContainerAppsCoreEnum>(
        ContainerCoreModel(),
      ),
    );

    final loginNotifier =
        sl<MicroAppNotifier<ContainerCoreModel, ContainerAppsCoreEnum>>();

    sl.registerSingleton(loginNotifier);
    manager.registerApp<ContainerCoreModel, ContainerAppsCoreEnum>(
      sl<MainResolver>(),
    );
  }
}
