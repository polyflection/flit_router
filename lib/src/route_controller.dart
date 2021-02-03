import 'package:flit_router/flit_router.dart';
import 'package:flutter/widgets.dart';
import 'route_path.dart';

// TODO: Implement an adaptor for Navigator to expose subset of NavigatorState API.
typedef PopRouteWithNavigator = Future<bool> Function(NavigatorState navigator);

/// RouteController controls routing and navigating operation for each [Route].
abstract class RouteControllerBase<T extends RoutePathBase> {
  Page get page;
  T get routePath;
  T get currentConfiguration => routePath;

  PopRouteWithNavigator get popRoute =>
      (NavigatorState navigator) => navigator.maybePop();

  PopPageCallback get onPopPage {
    return (Route<dynamic> route, dynamic result) {
      if (!route.didPop(result)) {
        return false;
      }
      return true;
    };
  }

  TransitionDelegate<dynamic> get transitionDelegate =>
      DefaultTransitionDelegate();
}

class RouteController extends RouteControllerBase<RoutePathBase> {
  RouteController({
    @required this.page,
    @required this.routePath,
    PopRouteWithNavigator /* nullable */ popRoute,
    PopPageCallback /* nullable */ onPopPage,
  })  : _popRoute = popRoute,
        _onPopPage = onPopPage;

  @override
  final Page page;
  @override
  final RoutePathBase routePath;
  final PopRouteWithNavigator /* nullable */ _popRoute;
  final PopPageCallback /* nullable */ _onPopPage;

  @override
  PopRouteWithNavigator get popRoute => _popRoute ?? super.popRoute;
  @override
  PopPageCallback get onPopPage => _onPopPage ?? super.onPopPage;
}
