import 'package:flit_router/flit_router.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class BooksPath extends RoutePathBase with NullRouteState {
  final Uri uri = Uri(pathSegments: pathSegments);
  static const List<String> pathSegments = ['books'];
  static String get pattern => pathSegments.first;
}

class BookPath extends RoutePathBase with NullRouteState {
  BookPath({required this.id});
  final String id;
  late final Uri uri = Uri(pathSegments: [...BooksPath.pathSegments, id]);
  // TODO: a RoutePatternBuilder would be helpful.
  static String get pattern => BooksPath.pattern + '/' + ':id';
}

class BooksRouteController extends RouteControllerBase<BooksPath> {
  final BooksPath routePath = BooksPath();
  @override
  Page get page =>
      MaterialPage(key: ValueKey('BooksListPage'), child: BooksListScreen());
}

class BookRouteController extends RouteControllerBase<BookPath> {
  BookRouteController(this.routePath);
  final BookPath routePath;
  @override
  Page get page {
    return MaterialPage(
      child: BookDetailsScreen(
        bookId: routePath.id,
      ),
    );
  }
}

class BooksListScreen extends StatelessWidget {
  BooksListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If it is a production app, books data should get asynchronously.
    final _books = books;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flit Router Demo'),
      ),
      body: ListView(
        children: [
          for (var book in _books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                FlitRootRouter.of(context).navigateTo(BookPath(id: book.id));
              },
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final String bookId;

  BookDetailsScreen({required this.bookId});

  @override
  Widget build(BuildContext context) {
    // If it is a production app, a book data should get asynchronously.
    final book = books.firstWhere((book) => book.id == bookId);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back'),
            ),
            ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Settings screen'),
      ),
    );
  }
}
