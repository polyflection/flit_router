import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'route_match.dart';
import 'routes.dart';

class FlitRouterDelegate extends RouterDelegate<RouteMatch>
    with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  final FlitRoutes _routes;

  FlitRouterDelegate(this._routes)
      : navigatorKey = GlobalKey<NavigatorState>() {
    _routes.addListener(notifyListeners);
  }

  @override
  Future<void> setNewRoutePath(RouteMatch routeMatch) async {
    if (routeMatch != _routes.currentRouteAndMatch!.item2) {
      throw StateError('Went wrong.');
    }
    await _routes.currentRouteAndMatch!.item1
        .onNewRouteFromPlatform(routeMatch);
  }

  RouteMatch get currentConfiguration {
    // TODO: needs better design.
    return RouteMatch(
        path: _routes.currentRouteController.routePath,
        exact: false,
        matchedParameters: {},
        matchedPortionOfPath: '',
        pathPattern: '');
  }

  @override
  Future<bool> popRoute() {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator == null) return SynchronousFuture<bool>(false);
    return _routes.currentRouteController.popRoute(navigator);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: optional validator and wrapper widget outer of Navigator?
    return Navigator(
      key: navigatorKey,
      transitionDelegate: _routes.currentRouteController.transitionDelegate,
      pages: _routes.currentPages,
      onPopPage: (route, result) {
        final isPopped =
            _routes.currentRouteController.onPopPage(route, result);
        if (isPopped) {
          _routes.currentRouteControllerStack!.removeLast();
          notifyListeners();
        }
        return isPopped;
      },
    );
  }
}
