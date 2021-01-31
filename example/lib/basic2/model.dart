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
