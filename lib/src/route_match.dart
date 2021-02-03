import 'package:flutter/widgets.dart';
import 'route_path.dart';

class RouteMatch {
  RouteMatch({
    @required this.path,
    @required this.pathPattern,
    @required this.matchedParameters,
    @required this.matchedPortionOfPath,
    @required this.exact,
  });

  final RoutePathBase path;

  /// Path pattern used for the match. For example, 'books/:id'.
  /// A nested route can use this pattern to build nested route path pattern.
  final String pathPattern;

  /// The matched portion of the URL.
  /// A nested route can use this pattern to build nested route path pattern.
  final String matchedPortionOfPath;

  /// For example, 'books/:id' to {:id: aValue}.
  final Map<String, String> matchedParameters;
  final bool exact;

  bool hasParent(BuildContext context) {
    throw UnimplementedError();
  }

  RouteMatch /* nullable */ parent(BuildContext context) {
    throw UnimplementedError();
  }

  List<RouteMatch> ancestors(BuildContext context) {
    throw UnimplementedError();
  }
}
