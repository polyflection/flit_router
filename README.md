# flit_router

A router built on to of Navigator 2.0, that provides concise, cohesive, type safe API, (hopefully) without losing functionality and flexibility of Navigator 2.0.

# Example

Example that implements this [basic router example](https://gist.github.com/johnpryan/430c1d3ad771c43bf249c07fa3aeef14#file-main-dart) with package:flit_router.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flit_router/flit_router.dart';

import 'routing.dart';

void main() {
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
                    BookPath(id: match.matchedParameters[':id']!)),
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
```

The [example](example/lib/basic2/main.dart).

# TODO

- Add child router solution that can cooperate with ancestor routers.
- Add hierarchal routing for more efficient route matching and aggregated validating.
- Add validator (A.K.A. route guard) and some UI hook on validating.
- Add trie pattern string builder.
- Add some declarative "Link" widget for semantic linking that wraps a widget which calls imperative `navigateTo` API.
- Add functionality for wrapping a navigator with a widget.
- Add documentation and test code and examples.
  - example: dynamic adaptive (responsive) routing.
  - example: app with sign-in and auth validation required area.
  - example: Youtube clone for complex routing case.
  - example: Page transition animation (in particular, hero animation).

# Known issue

- Back and Forward button on web does not work (setNewRoutePath is not called) for some reason. -> This bug was in Flutter framework side, which has already fixed at "Flutter 1.26.0-18.0.pre.128 • channel master".
