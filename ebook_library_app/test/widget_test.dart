import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ebook_library_app/main.dart';
import 'package:ebook_library_app/providers/ebook_provider.dart';
import 'package:ebook_library_app/models/ebook.dart';
import 'package:ebook_library_app/screens/library_screen.dart';
import 'package:ebook_library_app/widgets/ebook_card.dart';

// A simple mock provider so we don't hit the real rails API during tests
class MockEbookProvider extends ChangeNotifier implements EbookProvider {
  @override
  List<Ebook> ebooks = [];
  
  @override
  bool isLoading = false;
  
  @override
  String error = '';
  
  @override
  List<Ebook> searchResults = [];
  
  @override
  bool isSearching = false;

  @override
  Future<void> loadEbooks() async {}

  @override
  Future<bool> uploadEbook(String title, String author, String filePath) async { return true; }

  @override
  Future<bool> deleteEbook(int id) async { return true; }

  @override
  void search(String query) {}
}

void main() {
  Widget createTestWidget(Widget child, {MockEbookProvider? mockProvider}) {
    return MaterialApp(
      home: ChangeNotifierProvider<EbookProvider>.value(
        value: mockProvider ?? MockEbookProvider(),
        child: child,
      ),
    );
  }

  group('EBook Library Widget Tests', () {

    testWidgets('Empty State Rendering', (WidgetTester tester) async {
      final mockProvider = MockEbookProvider();
      mockProvider.ebooks = [];
      
      await tester.pumpWidget(createTestWidget(const LibraryScreen(), mockProvider: mockProvider));
      await tester.pumpAndSettle();
      
      expect(find.text('Your shelf is empty'), findsOneWidget);
      expect(find.text('Tap the + button to add books'), findsOneWidget);
    });

    testWidgets('Ebook Card Rendering', (WidgetTester tester) async {
      final testBook = Ebook(id: 1, title: 'Flutter Testing Guide', author: 'Dash');
      
      await tester.pumpWidget(createTestWidget(
        Scaffold(body: EbookCard(ebook: testBook, onDelete: () {})), 
      ));
      
      expect(find.text('Flutter Testing Guide'), findsOneWidget);
      expect(find.text('DASH'), findsOneWidget); 
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('Delete Confirmation behavior', (WidgetTester tester) async {
      final testBook = Ebook(id: 1, title: 'Book to Delete', author: 'Author');
      final mockProvider = MockEbookProvider();
      mockProvider.ebooks = [testBook];

      await tester.pumpWidget(createTestWidget(const LibraryScreen(), mockProvider: mockProvider));
      await tester.pumpAndSettle();

      expect(find.text('Book to Delete'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete Book'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Book to Delete"?'), findsOneWidget);
      expect(find.text('Wait, no'), findsOneWidget);
      
      await tester.tap(find.text('Wait, no'));
      await tester.pumpAndSettle();
      
      expect(find.text('Delete Book'), findsNothing);
    });
  });
}
