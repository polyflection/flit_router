import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flit_router/flit_router.dart';
import 'package:url_strategy/url_strategy.dart';

import 'routing.dart';

void main() {
  setPathUrlStrategy();
  runApp(BooksApp());
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  @override
  Widget build(BuildContext context) {
    return FlitRootRouter(
      key: ValueKey('root'),
      routes: FlitRoutes(
        builder: () {
          return [
            FlitRoute(
              BooksPath.pattern,
              to: (_) => [BooksRouteController()],
            ),
            FlitRoute(
              BookPath.pattern,
              to: (match) => [
                BooksRouteController(),
                BookRouteController(
                    BookPath(id: match.matchedParameters[':id'])),
              ],
            ),
            FlitRoute(
              '/',
              to: (_) => [BooksRouteController()],
            ),
          ];
        },
      ),
      appBuilder: (context, delegate, parser) {
        return MaterialApp.router(
          title: 'Books App',
          routerDelegate: delegate,
          routeInformationParser: parser,
        );
      },
    );
  }
}
