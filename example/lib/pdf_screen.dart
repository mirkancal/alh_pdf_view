import 'dart:typed_data';

import 'package:alh_pdf_view/lib.dart';
import 'package:alh_pdf_view_example/pdf_page_info.dart';
import 'package:alh_pdf_view_example/pdf_view_bottom_bar.dart';
import 'package:flutter/material.dart';

class PDFScreen extends StatefulWidget {
  final String? path;
  final Uint8List? bytes;

  const PDFScreen({
    this.path,
    this.bytes,
    super.key,
  });

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> {
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  bool isActive = true;
  double defaultScale = 1.0;
  double top = 200.0;
  bool enableSwipe = true;

  AlhPdfViewController? pdfViewController;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Document Portrait"),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  final searchText = await _showSearchDialog(context);
                  if (searchText != null && searchText.isNotEmpty) {
                    pdfViewController?.highlightSearchText(text: searchText);
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              Column(
                children: [
                  Expanded(
                    child: AlhPdfView(
                      enableDefaultScrollHandle: true,
                      filePath: widget.path,
                      bytes: widget.bytes,
                      enableSwipe: true,
                      nightMode: false,
                      password: 'password',
                      fitEachPage: false,
                      showScrollbar: true,
                      fitPolicy: orientation == Orientation.portrait
                          ? FitPolicy.both
                          : FitPolicy.width,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: false,
                      defaultZoomFactor: this.defaultScale,
                      pageSnap: true,
                      onRender: (pages) {
                        setState(() {
                          this.pages = pages + 1;
                          this.isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          this.errorMessage = error.toString();
                        });
                        print(error.toString());
                      },
                      onPageError: (page, error) {
                        setState(() {
                          this.errorMessage = '$page: ${error.toString()}';
                        });
                        print('$page: ${error.toString()}');
                      },
                      onViewCreated: (controller) {
                        this.pdfViewController = controller;
                      },
                      onPageChanged: (int page, int total) {
                        setState(() {
                          this.currentPage = page;
                        });
                      },
                    ),
                  ),
                  if (orientation == Orientation.portrait)
                    PdfViewBottomBar(
                      pdfViewController: this.pdfViewController,
                      currentPage: this.currentPage,
                      totalPages: this.pages,
                    ),
                ],
              ),
              if (this.errorMessage.isEmpty)
                if (!this.isReady)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  PdfPageInfo(
                    currentPage: this.currentPage,
                    totalPages: this.pages,
                  )
              else
                Center(child: Text(this.errorMessage))
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showSearchDialog(BuildContext context) async {
    TextEditingController searchTextController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search'),
          content: TextField(
            controller: searchTextController,
            decoration: InputDecoration(hintText: 'Enter search text'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () {
                Navigator.of(context).pop(searchTextController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
