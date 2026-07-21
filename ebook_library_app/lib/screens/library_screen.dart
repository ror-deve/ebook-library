import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ebook_provider.dart';
import '../widgets/ebook_card.dart';
import 'upload_screen.dart';
import 'search_screen.dart';
import '../models/ebook.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE8DE), // Sand/Paper color for background
      appBar: AppBar(
        title: const Text('My Library', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF4A3424), // Dark wood appbar
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer<EbookProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A3424)));
          }
          if (provider.error.isNotEmpty) {
            return Center(child: Text(provider.error));
          }
          if (provider.ebooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text("Your shelf is empty", style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  const Text("Tap the + button to add books", style: TextStyle(color: Colors.grey)),
                ],
              )
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.only(top: 20.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.68, // Adjusted ratio to look like a physical book
              crossAxisSpacing: 0, // 0 spacing so shelves touch perfectly end-to-end
              mainAxisSpacing: 0,
            ),
            itemCount: provider.ebooks.length,
            itemBuilder: (context, index) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                   // The Wallpaper backing
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                       color: const Color(0xFFEFE8DE),
                    ),
                  ),
                  // Book shelf contiguous row rendering
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF654321), // Dark Wood
                        border: const Border(
                          top: BorderSide(color: Color(0xFF8B5A2B), width: 3), // Highlight edge
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                    ),
                  ),
                  // The Book Card itself (padded so it doesn't touch the borders)
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 16.0, top: 4),
                    child: EbookCard(
                      ebook: provider.ebooks[index],
                      onDelete: () => _confirmDelete(context, provider, provider.ebooks[index]),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadScreen()),
          );
        },
        backgroundColor: const Color(0xFF4A3424),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _confirmDelete(BuildContext context, EbookProvider provider, Ebook book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Wait, no', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteEbook(book.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
