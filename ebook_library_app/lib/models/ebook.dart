class Ebook {
  final int id;
  final String title;
  final String author;
  final String? fileName;
  final String? fileUrl;

  Ebook({
    required this.id,
    required this.title,
    required this.author,
    this.fileName,
    this.fileUrl,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    // Handling Rails localhost Blob URLs differently depending on emulator vs local desktop.
    // We replace localhost with 127.0.0.1 which often works better, but since the user tested on Linux desktop, localhost is fine.
    String? rawUrl = json['file_url'];
    
    return Ebook(
      id: json['id'],
      title: json['title'],
      author: json['author'] ?? 'Unknown',
      fileName: json['file_name'],
      fileUrl: rawUrl,
    );
  }
}
