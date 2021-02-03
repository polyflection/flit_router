import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flit_router/flit_router.dart';
import 'package:url_strategy/url_strategy.dart';

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
          final booksListRouteController = (routePath) {
            return RouteController(
              page: MaterialPage(
                key: ValueKey('BooksListPage'),
                child: BooksListScreen(
                  books: books,
                ),
              ),
              routePath: routePath,
            );
          };

          return [
            FlitRoute(
              '/books',
              to: (match) => [booksListRouteController(match.path)],
            ),
            FlitRoute(
              '/books/:id',
              to: (match) {
                return [
                  booksListRouteController(
                    RoutePath.fromRawLocation(location: '/books'),
                  ),
                  RouteController(
                    page:
                        BookDetailsPage(bookId: match.matchedParameters[':id']),
                    routePath: match.path,
                  )
                ];
              },
            ),
            FlitRoute(
              '/',
              to: (match) {
                return [booksListRouteController(match.path)];
              },
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

class BookDetailsPage extends Page {
  final String bookId;

  BookDetailsPage({@required this.bookId}) : super(key: ValueKey(bookId));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(
            book: books.firstWhere((element) => element.id == bookId));
      },
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;

  BooksListScreen({@required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flit Router Demo'),
      ),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () {
                FlitRootRouter.of(context).navigateTo(
                    RoutePath(uri: Uri(pathSegments: ['books', book.id])));
              },
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book /* nullable */ book;

  BookDetailsScreen({@required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}

bool show404 = false;

final List<Book> books = [
  Book('a', 'Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book('b', 'Foundation', 'Isaac Asimov'),
  Book('c', 'Fahrenheit 451', 'Ray Bradbury'),
];

class Book {
  final String id;
  final String title;
  final String author;

  Book(this.id, this.title, this.author);
}
