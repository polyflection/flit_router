# flit_router

A concise, cohesive, type-safe, web-aware router built on top of Flutter Navigator 2.0, (hopefully) without losing the functionality and flexibility.

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
