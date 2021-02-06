import 'package:flutter/widgets.dart';

import 'route_match.dart';
import 'route_path.dart';
import 'router_delegate.dart';
import 'routes.dart';

typedef AppBuilder = Widget Function(
    BuildContext context,
    RouterDelegate<RouteMatch> delegate,
    RouteInformationParser<RouteMatch> parser);

abstract class FlitRouter implements StatefulWidget {
  factory FlitRouter.forRoot(
          {Key key,
          @required FlitRoutes routes,
          @required AppBuilder appBuilder}) =>
      _FlitRootRouter(key: key, routes: routes, appBuilder: appBuilder);

  factory FlitRouter({Key key, @required FlitRoutes routes}) =>
      _FlitChildRouter(key: key, routes: routes);

  static _FlitRouterState of(BuildContext context) {
    final _FlitRouterScope /* nullable */ scope =
        context.dependOnInheritedWidgetOfExactType<_FlitRouterScope>();
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
    return scope.flitRouterState;
  }

  @protected
  FlitRoutes get routes;
}

mixin _FlitRouterState<T extends FlitRouter> on State<T> {
  /// TODO: Is it helpful if navigateToUri() or navigateToString() is available?
  void navigateTo(RoutePathBase routePath) {
    widget.routes.handleNavigating(routePath);
  }
}

class _FlitRootRouter extends StatefulWidget implements FlitRouter {
  _FlitRootRouter({Key key, @required this.routes, @required this.appBuilder})
      : super(key: key);

  @override
  final FlitRoutes routes;
  final AppBuilder appBuilder;

  @override
  _FlitRootRouterState createState() => _FlitRootRouterState();
}

class _FlitRootRouterState extends State<_FlitRootRouter>
    with _FlitRouterState<_FlitRootRouter> {
  /* late final */ RouterDelegate<RouteMatch> delegate;
  /* late final */ RouteInformationParser<RouteMatch> parser;

  @override
  void initState() {
    super.initState();
    delegate = FlitRouterDelegate(widget.routes);
    parser = _FlitRouteInformationParser(widget.routes);
  }

  @override
  Widget build(BuildContext context) {
    return _FlitRouterScope(
      flitRouterState: this,
      child: Builder(
        builder: (context) {
          return widget.appBuilder(context, delegate, parser);
        },
      ),
    );
  }
}

// FlitRouter for child (nested) router. Root router and child router can have common interface so that a user can look up with FlitRouter.of(context).
class _FlitChildRouter extends StatefulWidget implements FlitRouter {
  _FlitChildRouter({Key key, @required this.routes}) : super(key: key);
  final FlitRoutes routes;

  @override
  _FlitChildRouterState createState() => _FlitChildRouterState();
}

class _FlitChildRouterState extends State<_FlitChildRouter>
    with _FlitRouterState<_FlitChildRouter> {
  /* late final */ RouterDelegate<RouteMatch> delegate;

  @override
  void initState() {
    super.initState();
    delegate = FlitRouterDelegate(widget.routes);
  }

  @override
  Widget build(BuildContext context) {
    return _FlitRouterScope(
      flitRouterState: this,
      child: Builder(
        builder: (context) {
          // TODO: backButtonDispatcher.
          return Router(routerDelegate: delegate);
        },
      ),
    );
  }
}

class _FlitRouterScope extends InheritedWidget {
  _FlitRouterScope(
      {Key /* nullable */ key,
      @required this.flitRouterState,
      @required Widget child})
      : super(key: key, child: child);

  final _FlitRouterState flitRouterState;

  @override
  // Is it really this rule?
  bool updateShouldNotify(_FlitRouterScope old) =>
      flitRouterState != old.flitRouterState;
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
