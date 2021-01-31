import 'package:flutter/widgets.dart';

import 'route_match.dart';
import 'route_path.dart';
import 'router_delegate.dart';
import 'routes.dart';

typedef AppBuilder = Widget Function(
    BuildContext context,
    RouterDelegate<RouteMatch> delegate,
    RouteInformationParser<RouteMatch> parser);

class FlitRootRouter extends StatefulWidget {
  FlitRootRouter(
      {Key? key, required FlitRoutes routes, required AppBuilder appBuilder})
      : _routes = routes,
        _appBuilder = appBuilder,
        super(key: key);

  final FlitRoutes _routes;
  final AppBuilder _appBuilder;

  @override
  _FlitRootRouterState createState() => _FlitRootRouterState();

  static _FlitRootRouterState of(BuildContext context) {
    final _FlitRootRouterScope? scope =
        context.dependOnInheritedWidgetOfExactType<_FlitRootRouterScope>();
    assert(() {
      if (scope == null) {
        // TODO: change error type.
        throw StateError('TODO: change error type to FlitRouterError.'
            'FlitRouter operation requested with a context that does not include a FlitRouter.\n'
            'The context used to retrieve the FlitRouter must be that of a widget that '
            'is a descendant of a FlitRouter widget.');
      }
      return true;
    }());
    return scope!.flitRootRouterState;
  }
}

class _FlitRootRouterState extends State<FlitRootRouter> {
  late final RouterDelegate<RouteMatch> delegate;
  late final RouteInformationParser<RouteMatch> parser;

  @override
  void initState() {
    super.initState();
    delegate = FlitRouterDelegate(widget._routes);
    parser = _FlitRouteInformationParser(widget._routes);
  }

  /// TODO: Is it helpful if navigateToUri() or navigateToString() is available?
  void navigateTo(RoutePathBase routePath) {
    widget._routes.handleNavigating(routePath);
  }

  @override
  Widget build(BuildContext context) {
    return _FlitRootRouterScope(
      flitRootRouterState: this,
      child: Builder(
        builder: (context) {
          return widget._appBuilder(context, delegate, parser);
        },
      ),
    );
  }
}

// FlitRouter for child (nested) router. Root router and child router can have common interface so that a user can look up with FlitRouter.of(context).
class FlitRouter extends StatefulWidget {
  FlitRouter(
      {Key? key, required this.routes, required this.backButtonDispatcher})
      : super(key: key);

  final FlitRoutes routes;
  final BackButtonDispatcher backButtonDispatcher;

  @override
  _FlitRouterState createState() => _FlitRouterState();

  static _FlitRouterState of(BuildContext context) {
    throw UnimplementedError('Unimplemented');
  }
}

class _FlitRouterState extends State<FlitRouter> {
  late final FlitRouterDelegate routerDelegate;
  late final RouteInformationParser routeInformationParser;

  void navigateTo(RoutePath routePath) {
    widget.routes.handleNavigating(routePath);
  }

  @override
  void initState() {
    super.initState();
    routerDelegate = FlitRouterDelegate(widget.routes);
  }

  @override
  Widget build(BuildContext context) {
    return _FlitRouterScope(
      flitRouterState: this,
      child: Builder(
        builder: (context) {
          return Router(
            routerDelegate: routerDelegate,
            backButtonDispatcher: widget.backButtonDispatcher,
          );
        },
      ),
    );
  }
}

class _FlitRouterScope extends InheritedWidget {
  _FlitRouterScope(
      {Key? key, required this.flitRouterState, required Widget child})
      : super(key: key, child: child);

  final _FlitRouterState flitRouterState;

  @override
  // Is it really this rule?
  bool updateShouldNotify(_FlitRouterScope old) =>
      flitRouterState != old.flitRouterState;
}

class _FlitRootRouterScope extends InheritedWidget {
  _FlitRootRouterScope(
      {Key? key, required this.flitRootRouterState, required Widget child})
      : super(key: key, child: child);

  final _FlitRootRouterState flitRootRouterState;

  @override
  // Is it really this rule?
  bool updateShouldNotify(_FlitRootRouterScope old) =>
      flitRootRouterState != old.flitRootRouterState;
}

class _FlitRouteInformationParser extends RouteInformationParser<RouteMatch> {
  final FlitRoutes _routes;
  _FlitRouteInformationParser(this._routes);

  Future<RouteMatch> parseRouteInformation(
      RouteInformation routeInformation) async {
    final location = routeInformation.location;
    print(location);
    if (location == null) {
      throw StateError('I will investigate when the location is set as null.'
          'Maybe set as \'/\' when it is null here.');
    }

    return _routes.doParse(RoutePath.fromRawLocation(
        location: location, state: routeInformation.state));
  }

  RouteInformation restoreRouteInformation(RouteMatch routeMatch) =>
      routeMatch.path.restoreRouteInformation();
}
