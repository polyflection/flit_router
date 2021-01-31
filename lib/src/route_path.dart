import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:quiver/core.dart';

@immutable
abstract class RoutePathBase implements widgets.RouteInformation {
  Uri get uri;
  late final queryParameters = uri.queryParameters;
  Object? get state;
  String get location => uri.toString();
  widgets.RouteInformation restoreRouteInformation() =>
      widgets.RouteInformation(location: location, state: state);

  bool operator ==(other) =>
      other is RoutePathBase &&
      location == other.location &&
      state.toString() == other.state.toString();
  int get hashCode => hash2(location.hashCode, state.hashCode);
}

/// Generic route data that can instantiate.
/// Usage example: aRouter.navigateTo(aRoutePath);
class RoutePath extends RoutePathBase {
  RoutePath({required this.uri, this.state});
  RoutePath.fromRawLocation({required String location, this.state})
      : uri = Uri.parse(location);

  final Uri uri;
  final Object? state;
}

mixin NullRouteState {
  final Object? state = null;
}
