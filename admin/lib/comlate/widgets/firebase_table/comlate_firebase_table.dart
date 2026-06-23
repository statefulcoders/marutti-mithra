
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/comlate/widgets/pagination_switcher.dart';

import '../../data/configs/app_config.dart';
import 'comlate_firebase_table_action.dart';
import 'comlate_firebase_table_column.dart';
import 'comlate_firebase_table_controller.dart';

class ComlateFirebaseTable extends StatelessWidget {
  final CollectionReference dataSource;
  final Query? filteredQuery;
  final List<ComlateFirebaseTableColumn> columns;
  final String identifier;

  final bool enableDeletion;
  final bool enableEditing;
  final bool enableDetails;
  final bool enableAction;
  final bool enableExport;

  final bool showOptionAtBottom;

  final List<DataUpdateFieldInfo>? updateConfig;

  final Function(DocumentSnapshot<dynamic> data)? onView;
  final Function()? onAction;
  final Function(Map<String, dynamic> latestData, Map<String, dynamic> oldData)? onDataEdited;
  final Function(Map<String, dynamic> data)? onDataAdded;
  final Function(DocumentSnapshot<dynamic> data)? onSelected;
  final Function(List<DataUpdateFieldInfo>)? onSaveOrder;

  final String? sortBy;
  final Map<String, int> exportOrder;

  final String? customActionLabel;

  static Color get railGradientStart => Get.isDarkMode ? Colors.black26 : Colors.white;
  static Color get railGradientMid => Get.isDarkMode ? Colors.black26 : Colors.white;
  static Color get railGradientEnd => Get.isDarkMode ? Colors.black54 : Colors.white;

  late final List<ComlateFirebaseTableAction> actions = [
    if (enableDetails) ComlateFirebaseTableAction(icon: Icons.visibility, color: AppConfig.primaryColor, tooltip: 'View'),
    if (enableEditing && updateConfig != null && updateConfig!.isNotEmpty) ComlateFirebaseTableAction(icon: Icons.edit, color: AppConfig.primaryColor, tooltip: 'Edit'),
    if (enableDeletion) ComlateFirebaseTableAction(icon: Icons.delete, color: Colors.red, tooltip: 'Delete'),
  ];

  ComlateFirebaseTable({super.key, required this.identifier, this.showOptionAtBottom = false, this.onDataAdded, this.onDataEdited, this.exportOrder = const {}, this.enableExport = true, required this.columns, this.customActionLabel, this.onAction, this.sortBy, this.updateConfig, required this.dataSource, this.filteredQuery, this.enableDeletion = false, this.enableAction = true, this.enableEditing = false, this.enableDetails = false, this.onView, this.onSelected, this.onSaveOrder});

  @override
  Widget build(BuildContext context) {
    late final ComlateFirebaseTableController controller = Get.put(ComlateFirebaseTableController(dataSource: dataSource, filteredDataSource: filteredQuery, fields: updateConfig ?? [], sortBy: sortBy, exportOrder: exportOrder, onSaveOrder: onSaveOrder), tag: identifier);

    final pagination = Obx(() => PaginationSwitcher(
      actionButton: enableAction && updateConfig != null && updateConfig!.isNotEmpty ? _buildActionButton(controller) : null,
      actionButton2: enableExport ? _buildExportButton(controller) : null,
        onLimitChanged: controller.changeLimit,
        spacer: _createSpacer(context, controller.filterController),
        limit: controller.limit.value,
        currentStartIndex: controller.currentStartIndex,
        currentEndIndex: controller.currentEndIndex,
        total: controller.total.value,
        switchToPrevious: controller.getPreviousPage,
        switchToNext: controller.getNextPage,
        reset: controller.getInitialPage
    ));

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              if (!showOptionAtBottom) pagination,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _createDataTable(context, controller),
                ),
              ),
              if (showOptionAtBottom) pagination,
              // SizedBox(height: 18.h),
            ],
          );
        },
      ),
    );
  }

  Widget _createDataTable(BuildContext context, ComlateFirebaseTableController controller) {
    return Obx(() {
      return DataTable(
        dataRowMaxHeight: 56,
        headingRowHeight: 48,
        dividerThickness: 0.7,
        headingRowColor: WidgetStateProperty.resolveWith((states) => Get.isDarkMode ? AppConfig.primaryColor : Colors.grey.shade200),
        dataRowColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? Theme.of(context).colorScheme.primary.withAlpha(20) : Colors.transparent,
        ),
        columns: _createColumns(),
        rows: _createRows(controller.allData.value, controller),
        decoration: _createDecoration(),
        showCheckboxColumn: false,
      );
    }
    );
  }

  BoxDecoration _createDecoration() {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey, width: 0.1),
        // color: Colors.black.withAlpha(100),
        color: Colors.black,
        gradient: LinearGradient(
            colors: [
              railGradientStart,
              railGradientMid,
              railGradientEnd
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
        )
    );
  }

  List<DataColumn> _createColumns() {
    final columnStyle = TextStyle(
        fontWeight: FontWeight.w600
    );
    return [
      ...columns.map((column) {
        return DataColumn(
          label: Text(column.label, style: columnStyle),
          tooltip: column.tooltip,
        );
      }),
      if (actions.isNotEmpty) DataColumn(
          label: Text('Actions', style: columnStyle),
          tooltip: 'Actions'
      )
    ];
  }

  Widget widthLimiter({ required Widget child }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 200),
      child: child,
    );
  }

  List<DataRow> _createRows(List<ModifiedDocumentSnapshot> allData, ComlateFirebaseTableController controller) {
    final pagedData = allData;
    return [
      ...pagedData.map((row) {
        return DataRow(
            onSelectChanged: (value) {
              if (value != null && onSelected != null) {
                onSelected!.call(row.original);
              }
            },
            selected: false,
            cells: [
              ...columns.map((col) => _createCell(col, row.data())),
              if (actions.isNotEmpty) DataCell(_createActions(controller, row))
            ]
        );
      }),
    ];
  }

  DataCell _createCell(ComlateFirebaseTableColumn col, Map<String, dynamic> data) {
    final formattedData = _buildValue(col, data);
    return DataCell(widthLimiter(child: _buildDataView(formattedData, col.transformer != null)));
  }

  Widget _buildDataView(String data, [bool isFormatted = false]) {
    if (isFormatted && isImageUrl(data)) {
      return CachedNetworkImage(
        imageUrl: data,
        width: 55,
        height: 55,
      );
    }

    return Text(
      data,
      style: TextStyle(
          fontSize: 13.sp
      ),
    );
  }

  String _buildValue(ComlateFirebaseTableColumn col, Map<String, dynamic> data) {
    final String value = col.transformer == null ?  col.keys.map((k) => _parseValue(data[k])).join(col.connector) : col.transformer!.call(data);
    return value.trim().isEmpty || value == col.connector ? 'None' : value;
  }

  String _parseValue(dynamic value) {
     if (value is Timestamp) {
      value = value.toDate();
    }

    if (value is DateTime) {
      return DateFormat('dd/MM/yy, hh:mm a').format(value);
    }

    if (value is String) {
      final time = DateTime.tryParse(value);
      if (time != null) {
        return DateFormat('dd/MM/yyyy').format(time);
      }
      if (isValidUrl(value) && value.length > 30) {
        return '${value.substring(0, 30)}...';
      }
      return value;
    }

    return (value ?? 'None').toString();
  }

  bool isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  bool isImageUrl(String value) {
    if (!isValidUrl(value)) return false;

    final uri = Uri.tryParse(value);
    if (uri == null) return false;

    // Check common image extensions in path OR query
    const imageExts = {'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'};

    final path = uri.path.toLowerCase();
    final hasExt = imageExts.any((ext) => path.endsWith('.$ext'));

    return hasExt;
  }

  Widget _createActions(ComlateFirebaseTableController controller, ModifiedDocumentSnapshot data) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((e) => IconButton(
          style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero
          ),
          tooltip: e.tooltip,
          onPressed: () => applyActions(controller, e, data),
          icon: Icon(e.icon, color: e.color, size: 19.sp)
      )).toList(),
    );
  }

  Future<void> applyActions(ComlateFirebaseTableController controller, ComlateFirebaseTableAction action, ModifiedDocumentSnapshot<Object?> data) async {
    final oldData = <String, dynamic>{...(data.original.data() as Map), ...data.overrideData};

    await controller.takeAction(action, data, updateConfig);
    if (action.tooltip.toLowerCase() == 'edit') {
      final newData = controller.allData.value.where((element) => element.id == data.id).firstOrNull;
      onDataEdited?.call({...?(newData?.original.data() as Map?), ...?newData?.overrideData}, oldData);
    }
  }

  Widget _buildActionButton(ComlateFirebaseTableController controller) {
    return ElevatedButton(
      onPressed: onAction ?? () async {
        final data = await controller.addNewItem(updateConfig!);
        if (data != null) {
          onDataAdded?.call(data);
        }
      },
      child: Text(
       customActionLabel ?? 'Create New',
        style: TextStyle(
            fontSize: 12.sp
        ),
      ),
    );
  }

  Widget _buildExportButton(ComlateFirebaseTableController controller) {
    return ElevatedButton(
      onPressed: () => controller.export(updateConfig!),
      child: Text(
      'Export Data',
        style: TextStyle(
            fontSize: 12.sp
        ),
      ),
    );
  }

  Widget _createSpacer(BuildContext context, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(
        fontSize: 13.sp,
        color: textColor
    );

    return TextField(
      controller: controller,
      autofocus: false,
      keyboardType: TextInputType.number,
      style: textStyle,
      decoration: InputDecoration(
        hintText: 'Filter Data',
        counterText: '',
        hintStyle: textStyle.copyWith(color: hintColor),
        filled: false,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(6.w),
      ),
    );
  }
}