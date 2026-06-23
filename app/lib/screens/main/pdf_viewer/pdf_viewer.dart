
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/configs/local/constants.dart';
import 'package:path_provider/path_provider.dart';

import '../../../widgets/app_root_container.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key});

  @override
  State<StatefulWidget> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final Completer<PDFViewController> _controller = Completer();
  int? currentPage = 0;
  int? pages;
  bool isReady = false;
  String errorMessage = '';
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    try {
      // Retrieve the PDF URL from Get.arguments
      final String? pdfUrl = Get.parameters[Constants.keyUrl];
      if (pdfUrl == null || pdfUrl.isEmpty) {
        throw Exception('PDF path missing');
      }

      final file = await downloadPdfFromUrl(pdfUrl, 'pdf.pdf');

      setState(() {
        _pdfFile = file;
        errorMessage = ''; // Clear any previous error
      });
    } catch (e) {
      setState(() {
        errorMessage = _getUserFriendlyErrorMessage(e);
      });
    }
  }

  Future<File> downloadPdfFromUrl(String url, String filename) async {
    try {
      // Initialize Dio
      final dio = Dio();
      // Get the application documents directory
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/$filename";

      // Download the PDF using Dio
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {

          }
        },
      );

      // Return the downloaded file
      return File(filePath);
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error.toString().contains('PDF path missing')) {
      return 'Unable to load pdf. Please try again or contact support.';
    } else if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Please check your internet connection and try again.';
      } else if (error.response?.statusCode == 404) {
        return 'pdf file not found. Please contact support.';
      } else {
        return 'Unable to download pdf. Please try again later.';
      }
    } else if (error.toString().contains('Permission denied') ||
        error.toString().contains('access denied')) {
      return 'Storage permission required. Please grant permission in settings.';
    } else if (error.toString().contains('PDFView')) {
      return 'Unable to display pdf. The file may be corrupted or unsupported.';
    }
    return 'Something went wrong. Please try again or contact support.';
  }

  @override
  Widget build(BuildContext context) {
    return AppRootContainer(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _pdfFile == null
              ? const Center(child: CircularProgressIndicator())
              : PDFView(
            filePath: _pdfFile!.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            backgroundColor: Colors.black,
            onRender: (_pages) {
              if (pages != _pages) {
                setState(() {
                  pages = _pages;
                  isReady = true;
                });
              }
            },
            onError: (error) {
              setState(() {
                errorMessage = _getUserFriendlyErrorMessage(error);
              });
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = _getUserFriendlyErrorMessage('PDFView page $page: $error');
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onPageChanged: (int? page, int? total) {
              if (currentPage != page) {
                setState(() {
                  currentPage = page;
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.navigation,
            color: Colors.grey[500],
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                errorMessage = '';
                _pdfFile = null;
              });
              loadPDF();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              backgroundColor: MaruttiColors.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Try Again',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}