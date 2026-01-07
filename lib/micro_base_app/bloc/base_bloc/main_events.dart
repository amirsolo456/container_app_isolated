import 'package:micro_app_core/services/routing/route_events.dart';

/// * Micro App Events
/// Register the micro app events here
/// so we provide them in [RouteEvents] to be fired from accross the micro apps.
/// The [initRouteListeners] method above will listen to the events listened here.
///

class MainAppLoadEvents extends RouteEvent {}
class MainAppSignOutEvents extends RouteEvent {}



///
/// Exports the events in a class so we dont need to import
/// them from other micro apps. SignInEvents will be used by [RouteEvents]
///
class MainEvents extends RouteEvent {
  RouteEvent mainAppLoadEvents = MainAppLoadEvents();
  RouteEvent mainAppSignOutEvents = MainAppSignOutEvents();

}