import 'package:flutter/material.dart';
import '../models/ebook.dart';
import '../screens/reader_screen.dart';

class EbookCard extends StatelessWidget {
  final Ebook ebook;
  final VoidCallback onDelete;

  const EbookCard({super.key, required this.ebook, required this.onDelete});

  Color _getCoverColor(String title) {
    final colors = [
      const Color(0xFF1E3D59), // Deep Blue
      const Color(0xFFFF6E40), // Deep Orange
      const Color(0xFF2E4053), // Charcoal
      const Color(0xFF8E44AD), // Purple
      const Color(0xFF27AE60), // Emerald Green
      const Color(0xFFC0392B), // Crimson Red
      const Color(0xFFD35400), // Pumpkin
      const Color(0xFF16A085), // Sea Teal
      const Color(0xFF8B0000), // Dark Red
    ];
    int hash = 0;
    for (var i = 0; i < title.length; i++) {
      hash = title.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  String? _getFullCoverUrl() {
    if (ebook.coverUrl != null && ebook.coverUrl!.isNotEmpty && ebook.coverUrl != 'null') {
      if (ebook.coverUrl!.startsWith('/')) {
        return '${"http://localhost:3000"}${ebook.coverUrl}';
      }
      return ebook.coverUrl!;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderScreen(ebook: ebook),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: _getCoverColor(ebook.title),
              image: _getFullCoverUrl() != null 
                  ? DecorationImage(
                      image: NetworkImage(_getFullCoverUrl()!),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(4, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  offset: const Offset(1, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 3,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 1.5,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
                if (_getFullCoverUrl() == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        ebook.title,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          fontSize: 13,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1))
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ebook.author.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
