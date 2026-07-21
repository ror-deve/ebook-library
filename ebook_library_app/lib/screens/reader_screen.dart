import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ebook.dart';
import '../services/api_service.dart';

class ReaderScreen extends StatefulWidget {
  final Ebook ebook;

  const ReaderScreen({super.key, required this.ebook});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _isLoading = true;
  bool _hasError = false;

  String _getFileUrl() {
    final fileUrl = widget.ebook.fileUrl;
    if (fileUrl != null && fileUrl.isNotEmpty && fileUrl != 'null') {
      if (fileUrl.startsWith('/')) {
        return '${ApiService.baseUrl.replaceAll('/api', '')}$fileUrl';
      }
      return fileUrl;
    }
    return '';
  }

  void _download(BuildContext context) async {
    final downloadUrl = '${ApiService.baseUrl}/ebooks/${widget.ebook.id}/download';
    final Uri url = Uri.parse(downloadUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch downloader')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileUrl = _getFileUrl();

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(widget.ebook.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: fileUrl.isNotEmpty && !_hasError
            ? [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _download(context),
                  tooltip: 'Download PDF',
                ),
              ]
            : [],
      ),
      body: fileUrl.isNotEmpty && !_hasError
          ? Stack(
              children: [
                SfPdfViewer.network(
                  fileUrl,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                    setState(() {
                      _hasError = true;
                      _isLoading = false;
                    });
                  },
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 20),
                    Text(
                      _hasError ? 'Could not load PDF' : 'No PDF attached',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasError
                          ? 'The PDF file failed to load.\nTry downloading it instead.'
                          : '"${widget.ebook.title}" was uploaded without a PDF.\nDelete it and re-upload with a file.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 32),
                    if (_hasError)
                      ElevatedButton.icon(
                        onPressed: () => _download(context),
                        icon: const Icon(Icons.download),
                        label: const Text('Download Instead'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A3424),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Library'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
