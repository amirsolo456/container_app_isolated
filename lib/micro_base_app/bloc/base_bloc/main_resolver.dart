// ignore_for_file: implementation_imports, library_prefixes

import 'package:flutter/cupertino.dart';
import 'package:micro_app_core/services/custom_event_bus/custom_event_bus.dart';
import 'package:micro_app_core/services/routing/routing_transitions.dart';
import 'package:micro_app_core/src/micro_app.dart' as microApp;
import '../../../main.dart';
import 'main_events.dart';
import 'package:micro_app_core/src/micro_core_utils.dart';

import 'main_inject.dart';

class SignInResolver implements microApp.MicroApp {
  @override
  String get microAppName => "/SignIn";

  @override
  Map<String, WidgetBuilderArgs> get routes => <String, WidgetBuilderArgs>{
    microAppName: (BuildContext context, Object? args) => const RootApp(netMode: 0,),
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
  void injectionsRegister() => Inject.initialize();

  @override
  TransitionType? get transitionType => TransitionType.fade;
}
