import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:trie_router/trie_router.dart';
import 'package:tuple/tuple.dart';

import 'route_controller.dart';
import 'route_match.dart';
import 'route_path.dart';

typedef _TrieRouteHandler = _TrieRouterHandleResult Function(
    Map<String, String> parameters);

class _TrieRouterHandleResult {
  _TrieRouterHandleResult(this.route, this.matchedParameters);
  final FlitRoute route;
  final Map<String, String> matchedParameters;
}

/// Container that contains List of [FlitRoute].
/// ```dart
/// FlitRoutes(
///   builder: (ancestorsMatch) {
///     FlitRoute('books', to: (match) {
///       match.ancestors;
///       // Here is a place that can communicate with some models in async.
///       return [/*route controllers*/];
///     }),
///   }
/// );
/// ```
class FlitRoutes with ChangeNotifier {
  factory FlitRoutes({required List<FlitRoute> Function() builder}) {
    final trieRouter = TrieRouter<_TrieRouteHandler>();
    final routes = builder();
    for (final route in builder()) {
      final pathSegments = Uri(path: route.pathPattern).pathSegments;
      trieRouter.addPathComponents(pathSegments,
          (parameters) => _TrieRouterHandleResult(route, parameters));
    }

    return FlitRoutes._(routes, trieRouter);
  }

  FlitRoutes._(this.routes, this._trieRouter);

  final List<FlitRoute> routes;
  final TrieRouter<_TrieRouteHandler> _trieRouter;

  List<Page> get currentPages =>
      currentRouteControllerStack!.map((c) => c.page).toList();

  Tuple2<FlitRoute, RouteMatch>? currentRouteAndMatch;
  List<RouteControllerBase>? currentRouteControllerStack;

  RouteControllerBase get currentRouteController =>
      currentRouteControllerStack!.last;

  Future<RouteMatch> doParse(RoutePath routePath) async {
    currentRouteAndMatch = doMatch(routePath);
    // TODO: add validating here if validateOnParse option is true.
    // TODO: handle no match case.
    await handleCurrentToCreateControllers();
    return SynchronousFuture(currentRouteAndMatch!.item2);
  }

  Future<void> handleNavigating(RoutePathBase routePath) async {
    // Check if it has already matched at RouteInformationParser.parse.
    if (currentRouteAndMatch == null ||
        currentRouteAndMatch!.item2.path != routePath) {
      currentRouteAndMatch = doMatch(routePath);
      print(currentRouteAndMatch!.item1.pathPattern);
    }
    await handleCurrentToCreateControllers();
    notifyListeners();
  }

  // always called by RouterDelegate after OnNewRouteFromPlatformHandler.
  Future<void> handleCurrentToCreateControllers() async {
    final result = currentRouteAndMatch!.item1.to(currentRouteAndMatch!.item2);
    if (result is Future) {
      return (result as Future).then((r) {
        currentRouteControllerStack = r;
      });
    } else {
      currentRouteControllerStack = result;
      return SynchronousFuture(null);
    }
  }

  // TODO: no match case.
  // TODO: Should be private method.
  Tuple2<FlitRoute, RouteMatch> doMatch(RoutePathBase routePath) {
    final element = _trieRouter.get(routePath.uri.toString());
    var result;
    if (element == null) {
      debugPrint('route does not match');
      // When '/', route does not match. This is temporary work around.
      final route = routes.firstWhere((element) => element.pathPattern == '/');
      result = _TrieRouterHandleResult(route, {});
    } else {
      final parameters = element.parameters;
      parameters.remove(null);
      result = element.value!(parameters.cast<String, String>());
    }

    final routeMatch = RouteMatch(
        pathPattern: result.route.pathPattern,
        path: routePath,
        matchedParameters: result.matchedParameters,
        matchedPortionOfPath: 'TODO',
        exact: false /*TODO*/);

    return Tuple2(result.route, routeMatch);
  }
}

class FlitRoute {
  FlitRoute(this.pathPattern,
      {required this.to,
      OnNewRouteFromPlatformHandler? onNewRouteFromPlatform,
      OnNewRouteFromPlatformHandler? onInitialRouteFromPlatform})
      : onNewRouteFromPlatform =
            onNewRouteFromPlatform ?? _defaultOnNewRouteFromPlatformHandler,
        onInitialRouteFromPlatform =
            onInitialRouteFromPlatform ?? _defaultOnNewRouteFromPlatformHandler;

  final String pathPattern;
  final To to;

  // For setNewRoutePath()
  final OnNewRouteFromPlatformHandler onNewRouteFromPlatform;
  // For setInitialRoutePath()
  final OnNewRouteFromPlatformHandler onInitialRouteFromPlatform;

  static OnNewRouteFromPlatformHandler
      get _defaultOnNewRouteFromPlatformHandler =>
          (_) => SynchronousFuture<void>(null);
}

// TODO: should the return type FutureOr? Because if it is not a future, then it can be warpped in a SynchronousFuture.
typedef To = FutureOr<List<RouteControllerBase>> Function(RouteMatch match);

typedef OnNewRouteFromPlatformHandler = Future<void> Function(
    RouteMatch routeMatch);
