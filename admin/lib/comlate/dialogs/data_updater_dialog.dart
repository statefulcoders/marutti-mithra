import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/overlays/app_snackbar.dart';
import 'package:marutti_mitra_admin/comlate/utils/settings/intent_utils.dart';

import '../widgets/comlate_text_field.dart';

class DataUpdateFieldInfo {
  final String key;
  final String expectedType;
  final String? hint;
  final int? max;
  final int? min;
  final List<String>? options;
  final bool required;
  final bool editable;

  // --- New fields for Object/Map configuration ---
  final List<String>? keyOptions;
  final String? nestedValueType;
  final List<String>? nestedValueOptions;

  const DataUpdateFieldInfo({
    required this.key,
    required this.expectedType,
    this.hint,
    this.max,
    this.min,
    this.options,
    this.required = false,
    this.editable = true, // CHANGED: Defaults to true so you don't have to set it for every field
    this.keyOptions,
    this.nestedValueType,
    this.nestedValueOptions,
  });
}

class DataUpdaterDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<DataUpdateFieldInfo> fieldInfo;
  final bool editable;
  final String? customLabel;
  final Function(List<DataUpdateFieldInfo>)? onSaveOrder;

  static Future<dynamic> show({
    required Map<String, dynamic> data,
    bool editable = true,
    String? customLabel,
    required List<DataUpdateFieldInfo> fieldInfo,
    Function(List<DataUpdateFieldInfo>)? onSaveOrder,
  }) async {
    return await Get.dialog(DataUpdaterDialog(
      data: data,
      editable: editable,
      customLabel: customLabel,
      fieldInfo: fieldInfo,
      onSaveOrder: onSaveOrder,
    ));
  }

  const DataUpdaterDialog({
    super.key,
    required this.data,
    required this.editable,
    this.customLabel,
    required this.fieldInfo,
    this.onSaveOrder,
  });

  @override
  State<DataUpdaterDialog> createState() => _DataUpdaterDialogState();
}

class _DataUpdaterDialogState extends State<DataUpdaterDialog> {
  final Map<String, dynamic> updatedData = {};
  final Map<String, TextEditingController> _controllers = {};

  late List<DataUpdateFieldInfo> _currentFields;
  bool _isReordering = false;

  @override
  void initState() {
    _currentFields = List.from(widget.fieldInfo);
    _analyseFields();
    super.initState();
  }

  void _analyseFields() {
    for (final field in _currentFields) {
      final value = widget.data[field.key];
      if (['text', 'list', 'integer', 'double'].contains(field.expectedType)) {
        String initialValue = '';
        if (field.expectedType == 'list') {
          initialValue = (value is List ? value.join(', ') : (value ?? '').toString());
          updatedData[field.key] = value ?? [];
        } else {
          initialValue = (value ?? '').toString();
          updatedData[field.key] = value;
        }
        _addController(field.key, initialValue);
      } else if (field.expectedType == 'object') {
        updatedData[field.key] = value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
      } else {
        updatedData[field.key] = value;
      }
    }
  }

  void _addController(String key, dynamic value) {
    _controllers[key] = TextEditingController(text: value ?? '');
    _controllers[key]!.addListener(() {
      final field = _currentFields.firstWhereOrNull((element) => element.key == key);
      if (field?.expectedType == 'list') {
        updatedData[key] = _controllers[key]!.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } else {
        updatedData[key] = _controllers[key]!.text;
      }
    });
  }

  bool _validateFields() {
    for (final field in _currentFields) {
      // Logic: If the dialog is not editable OR the specific field is not editable, skip validation
      // because the user cannot change it anyway.
      final isFieldEnabled = widget.editable && field.editable;
      if (!isFieldEnabled) continue;

      final value = updatedData[field.key];
      final label = _normalizeKey(field.key);

      if (field.required) {
        if (value == null) {
          AppSnackBar.error('$label is required.');
          return false;
        }
        if (value is String && value.trim().isEmpty) {
          AppSnackBar.error('$label is required.');
          return false;
        }
        if (value is Iterable && value.isEmpty) {
          AppSnackBar.error('$label cannot be empty.');
          return false;
        }
        if (value is Map && value.isEmpty) {
          AppSnackBar.error('$label cannot be empty.');
          return false;
        }
      }

      if (value is String && value.isNotEmpty) {
        if (field.expectedType == 'integer') {
          if (int.tryParse(value) == null) {
            AppSnackBar.error('$label must be a valid integer.');
            return false;
          }
        } else if (field.expectedType == 'double') {
          if (double.tryParse(value) == null) {
            AppSnackBar.error('$label must be a valid number.');
            return false;
          }
        }
      }
    }
    return true;
  }

  // --- UI Field Generators ---

  List<Widget> _createTextField(DataUpdateFieldInfo field, String inputType) {
    // Logic: Dialog must be editable AND Field must be editable
    final bool isEnabled = widget.editable && field.editable;

    return [
      Text(_normalizeKey(field.key), style: TextStyle(fontSize: 14.sp)),
      SizedBox(height: 4.h),
      ComlateTextField(
        controller: _controllers[field.key],
        inputFormatters: [
          if (inputType == 'integer') FilteringTextInputFormatter.digitsOnly,
          if (inputType == 'double') FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        maxLength: field.max,
        hint: field.hint ?? _normalizeKey(field.key),
        keyboardType: inputType == 'text' || inputType == 'list' ? TextInputType.text : TextInputType.number,
        enabled: isEnabled,
      ),
      SizedBox(height: 12.h)
    ];
  }

  List<Widget> _createObjectField(DataUpdateFieldInfo field) {
    final bool isEnabled = widget.editable && field.editable;

    return [
      Text(_normalizeKey(field.key), style: TextStyle(fontSize: 14.sp)),
      SizedBox(height: 4.h),
      Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[50],
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          border: Border.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        padding: EdgeInsets.all(12.w),
        child: _ObjectEditor(
          initialData: updatedData[field.key] ?? {},
          enabled: isEnabled,
          keyOptions: field.keyOptions,
          valueType: field.nestedValueType ?? 'text',
          valueOptions: field.nestedValueOptions,
          onChanged: (val) {
            updatedData[field.key] = val;
          },
        ),
      ),
      SizedBox(height: 12.h),
    ];
  }

  List<Widget> _createFile(DataUpdateFieldInfo field) {
    final bool isEnabled = widget.editable && field.editable;
    return [
      Text(_normalizeKey(field.key), style: TextStyle(fontSize: 14.sp)),
      SizedBox(height: 4.h),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          border: Border.all(color: Get.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
          color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[50],
        ),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        child: Row(
          children: [
            Icon(Icons.file_copy, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(updatedData[field.key] == null ? 'Select File' : 'File Selected', overflow: TextOverflow.ellipsis)),
            if (updatedData[field.key] != null)
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () => (updatedData[field.key] is String && (updatedData[field.key] as String).startsWith('https://'))
                    ? IntentUtils.launchInBrowser(updatedData[field.key])
                    : AppSnackBar.error('Cannot preview local file.'),
              ),
            if (isEnabled)
              TextButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: field.options);
                  if (result != null) setState(() => updatedData[field.key] = result.files.first.path);
                },
                child: const Text('Select'),
              )
          ],
        ),
      ),
      SizedBox(height: 12.h)
    ];
  }

  List<Widget> _createDropdown(DataUpdateFieldInfo field) {
    final bool isEnabled = widget.editable && field.editable;
    return [
      Text(_normalizeKey(field.key), style: TextStyle(fontSize: 14.sp)),
      SizedBox(height: 4.h),
      DropdownButtonFormField<String>(
        value: field.options?.contains(updatedData[field.key]) == true ? updatedData[field.key] : null,
        onChanged: isEnabled ? (val) => updatedData[field.key] = val : null,
        items: field.options?.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        decoration: InputDecoration(
          filled: true,
          fillColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.radius.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          enabled: isEnabled, // Controls visual state
        ),
      ),
      SizedBox(height: 12.h),
    ];
  }

  List<Widget> _createDatePicker(DataUpdateFieldInfo field) {
    final bool isEnabled = widget.editable && field.editable;
    final value = updatedData[field.key];
    final selectedDate = value is DateTime ? value : value is String ? DateTime.tryParse(value) : value is Timestamp ? value.toDate() : null;
    return [
      Text(_normalizeKey(field.key)),
      SizedBox(height: 4.h),
      ListTile(
        tileColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.radius.r), side: BorderSide(color: Colors.grey[400]!)),
        title: Text(selectedDate == null ? 'Select Date' : DateFormat('dd/MM/yyyy').format(selectedDate)),
        enabled: isEnabled,
        onTap: isEnabled ? () async {
          final picked = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime(2100));
          if (picked != null) setState(() => updatedData[field.key] = picked);
        } : null,
      ),
      SizedBox(height: 12.h),
    ];
  }

  List<Widget> _createToggle(DataUpdateFieldInfo field) {
    final bool isEnabled = widget.editable && field.editable;
    return [
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(_normalizeKey(field.key)),
        value: updatedData[field.key] == true,
        onChanged: isEnabled ? (val) => setState(() => updatedData[field.key] = val) : null,
      ),
      SizedBox(height: 12.h),
    ];
  }

  String _normalizeKey(String key) {
    final spaced = key.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
    return spaced.replaceAll('_', ' ').split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final bool canReorder = widget.onSaveOrder != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Get.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
      title: Row(
        children: [
          Expanded(
            child: Text(
              _isReordering ? 'Change Field Order' : (widget.customLabel ?? (widget.editable ? 'Update Data' : 'Details')),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
          if (canReorder)
            _isReordering ? TextButton(onPressed: () {
              if (_isReordering) {
                widget.onSaveOrder!(_currentFields);
              }
              setState(() => _isReordering = !_isReordering);
            }, child: Text('Save Order')) : IconButton(
              icon: Icon(
                Icons.reorder,
                color: _isReordering ? Colors.green : Colors.blue,
              ),
              onPressed: () {
                if (_isReordering) {
                  widget.onSaveOrder!(_currentFields);
                }
                setState(() => _isReordering = !_isReordering);
              },
            ),
        ],
      ),
      content: SizedBox(
        width: min(450.w, Get.width * 0.9),
        child: _isReordering ? _buildReorderList() : _buildFormView(),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        if (widget.editable && !_isReordering)
          ElevatedButton(
            onPressed: () {
              if (_validateFields()) Get.back(result: updatedData);
            },
            child: const Text('Update'),
          ),
      ],
    );
  }

  Widget _buildFormView() {
    final List<Widget> inputFields = _currentFields.expand((e) {
      switch (e.expectedType) {
        case 'text':
        case 'double':
        case 'list':
        case 'integer':
          return _createTextField(e, e.expectedType);
        case 'object':
          return _createObjectField(e);
        case 'dropdown':
          return _createDropdown(e);
        case 'date':
          return _createDatePicker(e);
        case 'file':
          return _createFile(e);
        case 'toggle':
          return _createToggle(e);
        default:
          return <Widget>[];
      }
    }).toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: inputFields,
      ),
    );
  }

  Widget _buildReorderList() {
    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.6),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        itemCount: _currentFields.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) newIndex -= 1;
            final item = _currentFields.removeAt(oldIndex);
            _currentFields.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final field = _currentFields[index];
          return Padding(
            key: ValueKey(field.key),
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: ListTile(
              leading: const Icon(Icons.circle),
              title: Text(_normalizeKey(field.key)),
              subtitle: Text('Type: ${field.expectedType}', style: TextStyle(fontSize: 11.sp)),
              tileColor: Get.isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.03),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }
}

// --- Helper Widget for Object Type ---

class _ObjectEditor extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final bool enabled;
  final List<String>? keyOptions;
  final String valueType; // 'text', 'integer', 'double'
  final List<String>? valueOptions;

  const _ObjectEditor({
    required this.initialData,
    required this.onChanged,
    this.enabled = true,
    this.keyOptions,
    this.valueType = 'text',
    this.valueOptions,
  });

  @override
  State<_ObjectEditor> createState() => _ObjectEditorState();
}

class _ObjectEditorState extends State<_ObjectEditor> {
  late List<_ObjectEntryPair> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.initialData.entries.map((e) {
      final pair = _ObjectEntryPair(
        key: TextEditingController(text: e.key),
        value: TextEditingController(text: e.value.toString()),
      );
      _attachListener(pair);
      return pair;
    }).toList();
  }

  void _attachListener(_ObjectEntryPair pair) {
    void listener() {
      final Map<String, dynamic> newData = {};
      for (var p in _controllers) {
        if (p.key.text.trim().isNotEmpty) {
          dynamic val = p.value.text.trim();
          if (widget.valueType == 'integer') val = int.tryParse(val) ?? val;
          if (widget.valueType == 'double') val = double.tryParse(val) ?? val;
          newData[p.key.text.trim()] = val;
        }
      }
      widget.onChanged(newData);
    }

    pair.key.addListener(listener);
    pair.value.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyDropdown = widget.keyOptions != null && widget.keyOptions!.isNotEmpty;
    final bool isValueDropdown = widget.valueOptions != null && widget.valueOptions!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_controllers.isEmpty)
          Padding(
            padding: EdgeInsets.all(8.h),
            child: Text('No items', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
          ),
        ..._controllers.asMap().entries.map((e) {
          final index = e.key;
          final entry = e.value;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: isKeyDropdown
                      ? _buildDropdown(entry.key, widget.keyOptions!, 'Key')
                      : ComlateTextField(
                    controller: entry.key,
                    hint: 'Key',
                    enabled: widget.enabled,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 3,
                  child: isValueDropdown
                      ? _buildDropdown(entry.value, widget.valueOptions!, 'Value')
                      : ComlateTextField(
                    controller: entry.value,
                    hint: 'Value',
                    enabled: widget.enabled,
                    inputFormatters: [
                      if (widget.valueType == 'integer') FilteringTextInputFormatter.digitsOnly,
                      if (widget.valueType == 'double') FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    keyboardType: (widget.valueType == 'integer' || widget.valueType == 'double')
                        ? TextInputType.number
                        : TextInputType.text,
                  ),
                ),
                if (widget.enabled)
                  Container(
                    margin: EdgeInsets.only(left: 8.w),
                    child: IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 24.sp),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          final removed = _controllers.removeAt(index);
                          removed.dispose();
                        });
                        if (_controllers.isNotEmpty) {
                          _controllers.first.key.notifyListeners();
                        } else {
                          widget.onChanged({});
                        }
                      },
                    ),
                  ),
              ],
            ),
          );
        }),
        if (widget.enabled)
          TextButton.icon(
            onPressed: () {
              setState(() {
                final pair = _ObjectEntryPair(
                  key: TextEditingController(),
                  value: TextEditingController(),
                );
                _attachListener(pair);
                _controllers.add(pair);
              });
            },
            icon: Icon(Icons.add, size: 18.sp),
            label: const Text('Add Item'),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft
            ),
          ),
      ],
    );
  }

  Widget _buildDropdown(TextEditingController controller, List<String> options, String hint) {
    return DropdownButtonFormField<String>(
      value: options.contains(controller.text) ? controller.text : null,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Get.isDarkMode ? Colors.grey[700] : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        hintText: hint,
        enabled: widget.enabled,
      ),
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 13.sp), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: widget.enabled ? (val) {
        if (val != null) {
          controller.text = val; // Trigger listener attached to controller
        }
      } : null,
    );
  }

  @override
  void dispose() {
    for (var pair in _controllers) {
      pair.dispose();
    }
    super.dispose();
  }
}

class _ObjectEntryPair {
  final TextEditingController key;
  final TextEditingController value;

  _ObjectEntryPair({required this.key, required this.value});

  void dispose() {
    key.dispose();
    value.dispose();
  }
}