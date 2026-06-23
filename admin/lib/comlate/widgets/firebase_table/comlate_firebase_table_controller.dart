import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../dialogs/confirmation_dialog.dart';
import '../../dialogs/data_updater_dialog.dart';
import 'comlate_firebase_table_action.dart';

void showProgressDialog(String message) {
  Get.dialog(
    Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(width: 20),
            Flexible(child: Text(message)),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

class ComlateFirebaseTableController extends GetxController {
  final allData = Rx<List<ModifiedDocumentSnapshot>>([]);
  final CollectionReference dataSource;
  final Query? filteredDataSource;

  final limit = 10.obs;
  final total = 0.obs;
  final isFirstPage = true.obs;
  final isLastPage = false.obs;

  final List<String>? filterFields;

  int get currentStartIndex => max(0, (historyStack.length - 1) * limit.value) + 1;
  int get currentEndIndex => max(currentStartIndex, currentStartIndex + allData.value.length - 1);

  final String? sortBy;
  final filterController = TextEditingController();
  final searchTerm = ''.obs;

  final historyStack = <DocumentSnapshot>[];

  final List<DataUpdateFieldInfo> fields;

  Timer? timer;

  final Map<String, int> exportOrder;

  final Function(List<DataUpdateFieldInfo>)? onSaveOrder;

  ComlateFirebaseTableController({required this.dataSource, this.filteredDataSource, this.exportOrder = const {}, required this.fields, required this.sortBy, this.filterFields, this.onSaveOrder});

  @override
  void onInit() {
    getInitialPage();

    filterController.addListener(_onFilterTextChanged);
    super.onInit();
  }


  void _onFilterTextChanged() {
    final newTerm = filterController.text.toLowerCase().trim();
    if (newTerm != searchTerm.value) {
      searchTerm.value = newTerm;
      timer?.cancel();
      timer = Timer(Duration(milliseconds: 500), getInitialPage);
    }
  }

  Future<List<ModifiedDocumentSnapshot>> _search({
    required String search,
    required Query baseQuery,
    required int limitCount,
    bool? fetchNext
  }) async {
    final List<DocumentSnapshot> results = [];

    DocumentSnapshot? startAfter = fetchNext == true ? allData.value.lastOrNull?.original : null;
    if (fetchNext == false) {
      if (historyStack.length > 1) {
        historyStack.removeLast();
      } else {
        return allData.value;
      }
    }

    while (results.length < limitCount) {
      Query query = baseQuery;

      if ((fetchNext ?? true) && startAfter != null) {
        query = query.startAfterDocument(startAfter);
      } else if (fetchNext == false) {
        query = query.startAtDocument(historyStack.last);
      }

      final snapshot = await query.limit(search.trim().isEmpty ? limitCount : 500).get();
      final documents = snapshot.docs;

      print('Searching: items (${results.length} < $limitCount = ${results.length < limitCount}): ${documents.length}');

      if (documents.isEmpty) {
        break;
      }

      for (final document in documents) {
        final data = document.data() as Map<String, dynamic>;

        final matches = fields.where((element) => ['text', 'number', 'dropdown'].contains(element.expectedType)).any((element) {
          print('Against: items (${data[element.key]} : ${search.trim()}');
          return search.trim().toLowerCase().split(' ').any((a) => data[element.key]?.toString().toLowerCase().contains(a.trim()) ?? false);
        });

        if (matches) {
          results.add(document);
        }

        if (results.length >= limitCount) {
          break;
        }
      }

      if (results.length < limitCount) {
        if ((fetchNext ?? true) && documents.isNotEmpty) {
          startAfter = documents.last;
        } else if (fetchNext == false) {
          if (historyStack.length > 1) {
            historyStack.removeLast();
          } else {
            break;
          }
        }
      }
    }

    return ModifiedDocumentSnapshot.wrapAll(results);
  }

  Future<void> getInitialPage() async {
    Query query = filteredDataSource ?? dataSource;
    if (sortBy != null) {
      query = query.orderBy(sortBy!, descending: true);
    }

    allData.value = await _search(search: searchTerm.value, baseQuery: query, limitCount: limit.value);

    isFirstPage.value = true;
    isLastPage.value = allData.value.length < limit.value;

    historyStack.clear();
    if (allData.value.isNotEmpty) {
      historyStack.add(allData.value.first.original);
    }

    if (searchTerm.value.trim().isEmpty) {
      final response = await query.count().get();
      total.value = int.tryParse(response.count?.toString() ?? '0') ?? 0;
    }

    print('Initial: items: ${allData.value.length}');
    print('Initial: items: ${allData.value.firstOrNull}');
  }

  Future<void> getNextPage() async {
    if (isLastPage.value) return;

    Query query = filteredDataSource ?? dataSource;
    if (sortBy != null) {
      query = query.orderBy(sortBy!, descending: true);
    }

    final results = await _search(search: searchTerm.value, baseQuery: query, limitCount: limit.value, fetchNext: true);

    if (results.isNotEmpty) {
      allData.value = results;
      historyStack.add(allData.value.first.original);
    }

    isFirstPage.value = false;
    isLastPage.value = allData.value.length < limit.value;

    print('Next: items: ${allData.value.length}');
  }


  Future<void> getPreviousPage() async {
    if (isFirstPage.value || historyStack.length == 1) return;

    Query query = filteredDataSource ?? dataSource;
    if (sortBy != null) {
      query = query.orderBy(sortBy!, descending: true);
    }

    final results = await _search(search: searchTerm.value, baseQuery: query, limitCount: limit.value, fetchNext: false);

    if (results.isNotEmpty) {
      allData.value = results;

      print('Previous: items: ${allData.value.length}');
    }

    isFirstPage.value = historyStack.length == 1;
    isLastPage.value = false;
  }

  void changeLimit(int? value) {
    limit.value = value ?? 10;
    getInitialPage();
  }

  Future<void> takeAction(ComlateFirebaseTableAction e, ModifiedDocumentSnapshot<Object?> data, List<DataUpdateFieldInfo>? updateConfig) async {
    switch(e.tooltip.toLowerCase()) {
      case 'delete': await delete(data, updateConfig ?? []);
      case 'view': await view(data, false, updateConfig);
      case 'edit': await view(data, true, updateConfig);
    }
  }

  Future<void> delete(ModifiedDocumentSnapshot data, List<DataUpdateFieldInfo> config) async {
    try {
      final confirm = await ConfirmationDialog.confirm(
          'Are you sure to delete?',
          title: 'Deletion',
          color: Colors.red,
          icon: Icons.delete_outline
      );

      if (confirm) {
        // 1. Delete Files from Storage
        final fieldsData = data.data();
        for (final field in config) {
          if (field.expectedType == 'file') {
            if (fieldsData[field.key] != null &&
                fieldsData[field.key] is String &&
                (fieldsData[field.key] as String).startsWith('https://')) {
              try {
                final ref = FirebaseStorage.instance.refFromURL(fieldsData[field.key]);
                await ref.delete();
              } catch (e) {
                print('Failed to delete file from storage: $e');
              }
            }
          }
        }

        // 2. Delete Document from Firestore
        await data.reference.delete();

        // 3. Update Local State (Preserve Page State)
        // Remove item locally and update total count immediately
        allData.value.removeWhere((element) => element.id == data.id);
        total.value = max(0, total.value - 1);

        // 4. Handle Pagination Logic
        if (allData.value.isEmpty) {
          // If the current page is now empty...
          if (historyStack.length > 1) {
            // ...and we have a previous page, go back to it.
            await getPreviousPage();
          } else {
            // ...if it was the first page, just refresh (shows empty state).
            await getInitialPage();
          }
        } else {
          // 5. Refill the Gap (Optional: Maintain page size)
          // If we are not at the logical end of data, fetch 1 item to fill the empty slot.
          Query query = filteredDataSource ?? dataSource;
          if (sortBy != null) {
            query = query.orderBy(sortBy!, descending: true);
          }

          int needed = limit.value - allData.value.length;

          // Only fetch if we need items and assume there might be more data
          if (needed > 0) {
            // Re-use _search with fetchNext: true.
            // _search uses allData.last as the cursor, which is now the item *before* the deleted one (or the new last item),
            // so this correctly fetches the item immediately following the current list.
            final newItems = await _search(
                search: searchTerm.value,
                baseQuery: query,
                limitCount: needed,
                fetchNext: true
            );

            if (newItems.isNotEmpty) {
              allData.value.addAll(newItems);
            }

            // If we tried to refill but got nothing (or fewer than needed), we are definitely at the last page.
            if (newItems.length < needed) {
              isLastPage.value = true;
            }
          }
        }

        // Trigger UI update
        allData.refresh();
      }
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err.toString(),
          title: 'Deletion Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
    }
  }

  List<String> _getContentType(DataUpdateFieldInfo field) {
    for (final option in field.options ?? []) {
      final ext = option.toLowerCase();
      switch (ext) {
        case 'png':
          return ['.$ext', 'image/png'];
        case 'jpg':
        case 'jpeg':
      return ['.$ext', 'image/jpeg'];
        case 'webp':
      return ['.$ext', 'image/webp'];
        case 'pdf':
      return ['.$ext', 'application/pdf'];
        case 'mp4':
      return ['.$ext', 'video/mp4'];
        case 'mp3':
        return ['.$ext', 'audio/mpeg'];
      }
    }

    return ['', 'application/octet-stream'];
  }

  Future<void> view(ModifiedDocumentSnapshot data, bool editable, [List<DataUpdateFieldInfo>? config]) async {
    config ??= (data.data()).entries.map<DataUpdateFieldInfo>((e) {
      return DataUpdateFieldInfo(
        key: e.key,
        expectedType: 'text',
      );
    }).toList();
    try {
      final updatedData = await DataUpdaterDialog.show(
          data: data.data(),
          editable: editable,
          fieldInfo: config,
        onSaveOrder: onSaveOrder
      );

      if (updatedData is Map<String, dynamic>) {
        for (final field in config) {
          if (field.expectedType == 'file') {
            if (updatedData[field.key] != null && updatedData[field.key] is String && !(updatedData[field.key] as String).startsWith('https://')) {
              final path = updatedData[field.key];
              if (path != null && path is String && !path.startsWith('https://')) {
                try {
                  showProgressDialog('Uploading file...');
                  final response = await html.HttpRequest.request(path, responseType: 'arraybuffer');
                  final data = response.response as ByteBuffer;
                  final metadata = _getContentType(field);
                  final ref = FirebaseStorage.instance.ref().child('uploads/${path.split('/').last}${metadata.firstOrNull ?? ''}');
                  final uploadTask = await ref.putData(Uint8List.view(data), SettableMetadata(contentType: metadata.lastOrNull));
                  final downloadUrl = await uploadTask.ref.getDownloadURL();
                  updatedData[field.key] = downloadUrl;
                } catch (e) {
                  print('Upload failed for path: $path, error: $e');
                } finally {
                  Get.back(); // Close the progress dialog
                }
              }
            }
          }
        }
        await data.reference.update(updatedData);
        int index = allData.value.indexWhere((element) => element.id == data.id);
        if (index != -1) {
          allData.value[index] = ModifiedDocumentSnapshot(original: data.original, overrideData: updatedData);
          allData.refresh();
        }
      }
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err.toString(),
          title: 'Update Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
    }
  }

  @override
  void dispose() {
    filterController.removeListener(_onFilterTextChanged);
    filterController.dispose();
    timer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>?> addNewItem(List<DataUpdateFieldInfo> config) async {
    try {
      final updatedData = await DataUpdaterDialog.show(
        data: {},
        fieldInfo: config,
        editable: true,
        customLabel: "Create New Field",
      );
      if (updatedData is Map<String, dynamic> && updatedData.isNotEmpty) {
        for (final field in config) {
          if (field.expectedType == 'file') {
            if (updatedData[field.key] != null && updatedData[field.key] is String && !(updatedData[field.key] as String).startsWith('https://')) {
              final path = updatedData[field.key];
              if (path != null && path is String && !path.startsWith('https://')) {
                try {
                  showProgressDialog('Uploading file...');
                  final response = await html.HttpRequest.request(path, responseType: 'arraybuffer');
                  final data = response.response as ByteBuffer;
                  final metadata = _getContentType(field);
                  final ref = FirebaseStorage.instance.ref().child('uploads/${path.split('/').last}${metadata.firstOrNull ?? ''}');
                  final uploadTask = await ref.putData(Uint8List.view(data), SettableMetadata(contentType: metadata.lastOrNull));
                  final downloadUrl = await uploadTask.ref.getDownloadURL();
                  updatedData[field.key] = downloadUrl;
                } catch (e) {
                  print('Upload failed for path: $path, error: $e');
                } finally {
                  Get.back(); // Close the progress dialog
                }
              }
            }
          }
        }
        await dataSource.doc().set(updatedData);
        total.value++;
        await getInitialPage();
        return updatedData;
      }
    } catch (err) {
      await ConfirmationDialog.confirm(
          err is FirebaseException ? err.message ?? err.toString() : err.toString(),
          title: 'Creation Failed',
          color: Colors.red,
          icon: Icons.error_outline_outlined
      );
    }
    return null;
  }

  String _normalizeKey(String key) {
    final spaced = key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
    final snakeCase = spaced.replaceAll('_', ' ');
    return snakeCase.split(' ').map((word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' ');
  }

  Future<void> export(List<DataUpdateFieldInfo> config) async {
    if (allData.value.isEmpty) {
      Get.snackbar(
        'No Data',
        'There is no data to export',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: EdgeInsets.all(5),
      );
      return;
    }

    showProgressDialog('Exporting...');
    bool success = false;
    try {
      final excel = Excel.createExcel();
      String defaultSheet = excel.sheets.keys.first;
      excel.rename(defaultSheet, 'Firebase-Data');
      var sheet = excel.sheets['Firebase-Data'];

      // Extract all unique keys from existing data
      final Set<String> allKeys = {};
      for (final doc in allData.value) {
        final map = doc.data();
        allKeys.addAll(map.keys);
      }
      final headers = allKeys.toList();
      headers.sort((a, b) => (exportOrder[a] ?? headers.length).compareTo(exportOrder[b] ?? headers.length));

      // Add headers using normalized labels
      for (int i = 0; i < headers.length; i++) {
        sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value =
            TextCellValue(_normalizeKey(headers[i]));
      }

      // Fetch all documents in batches of 500
      Query query = filteredDataSource ?? dataSource;
      if (sortBy != null) {
        query = query.orderBy(sortBy!, descending: true);
      }

      DocumentSnapshot? lastDoc;
      int row = 1;
      bool done = false;

      while (!done) {
        Query currentQuery = lastDoc != null ? query.startAfterDocument(lastDoc).limit(500) : query.limit(500);
        QuerySnapshot snapshot = await currentQuery.get();
        if (snapshot.docs.isEmpty) break;

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          for (int i = 0; i < headers.length; i++) {
            final key = headers[i];
            String value;
            if (data[key] is DateTime) {
              value = DateFormat('dd/MM/yyyy, hh:mm a').format(data[key]);
            } else if (data[key] is Timestamp) {
              value = DateFormat('dd/MM/yyyy, hh:mm a').format(data[key].toDate());
            } else {
              value = data[key]?.toString() ?? '';
            }
            sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row)).value = TextCellValue(value);
          }
          row++;
        }

        if (snapshot.docs.length < 500) {
          done = true;
        } else {
          lastDoc = snapshot.docs.last;
        }
      }

      for (int i = 0; i < headers.length; i++) {
        sheet?.setColumnWidth(i, 20);
      }

      final fileBytes = excel.save(fileName: 'Export_${DateTime.now()}.xlsx');
      if (fileBytes == null) throw Exception('Failed to generate Excel file');

      success = true;
    } catch (e) {
      debugPrint('Export error: $e');
      success = false;
    } finally {
      Get.back();
      if (success) {
        Get.snackbar(
          'Success',
          'Exported successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: EdgeInsets.all(5),
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to export data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: EdgeInsets.all(5),
        );
      }
    }
  }

}


class ModifiedDocumentSnapshot<T> {
  final DocumentSnapshot<T> original;
  final Map<String, dynamic> overrideData;

  ModifiedDocumentSnapshot({
    required this.original,
    required this.overrideData,
  });

  factory ModifiedDocumentSnapshot.fromOriginal(DocumentSnapshot<T> original) {
    return ModifiedDocumentSnapshot(
      original: original,
      overrideData: {},
    );
  }

  static List<ModifiedDocumentSnapshot<T>> wrapAll<T>(List<DocumentSnapshot<T>> snapshots) {
    return snapshots.map((doc) => ModifiedDocumentSnapshot<T>.fromOriginal(doc)).toList();
  }

  Map<String, dynamic> data() {
    final originalData = original.data() as Map<String, dynamic>? ?? {};
    return {
      ...originalData,
      ...overrideData,
    };
  }

  dynamic operator [](String field) => data()[field];

  String get id => original.id;

  SnapshotMetadata get metadata => original.metadata;

  DocumentReference<T> get reference => original.reference;

  bool get exists => original.exists;
}