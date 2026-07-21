import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ebook_provider.dart';
import '../widgets/ebook_card.dart';
import '../models/ebook.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: 'Search by title, author, filename...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            context.read<EbookProvider>().search(val);
          },
        ),
        backgroundColor: const Color(0xFF5D4037),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<EbookProvider>(
        builder: (context, provider, child) {
          if (provider.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.searchResults.isEmpty && _searchController.text.isNotEmpty) {
            return const Center(child: Text("No books found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -10,
                    left: -12,
                    right: -12,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5A2B),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 3),
                          )
                        ]
                      ),
                    ),
                  ),
                  EbookCard(
                    ebook: provider.searchResults[index],
                    onDelete: () => _confirmDelete(context, provider, provider.searchResults[index]),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, EbookProvider provider, Ebook book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from Library'),
        content: Text('Delete "${book.title}"? This cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await provider.deleteEbook(book.id);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete. Please try again.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
