import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/display/comlate_display_utils.dart';

class PaginationSwitcher extends StatelessWidget {
  final Widget? actionButton;
  final Widget? actionButton2;
  final Widget? spacer;

  final ValueChanged<int> onLimitChanged;
  final int limit;
  final int currentStartIndex;
  final int currentEndIndex;
  final int total;

  final void Function() switchToPrevious;
  final void Function() switchToNext;
  final void Function() reset;

  const PaginationSwitcher({super.key, this.actionButton, this.spacer, this.actionButton2, required this.onLimitChanged, required this.limit, required this.currentStartIndex, required this.currentEndIndex, required this.total, required this.switchToPrevious, required this.switchToNext, required this.reset});

  @override
  Widget build(BuildContext context) {
    final isPhone = ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.phone;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: isPhone ? Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (actionButton != null) ...[
            actionButton!,
            SizedBox(height: 12.h)
          ],
          if (actionButton2 != null) ...[
            actionButton2!,
            SizedBox(height: 12.h)
          ],
          if (spacer != null) ...[
            spacer!,
            SizedBox(height: 12.h)
          ],
          _buildLimitSelector(),
          _buildPageSwitcher()
        ],
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (actionButton != null) actionButton!,
          SizedBox(width: 4.w),
          if (actionButton2 != null) actionButton2!,
          if (spacer != null) Expanded(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: spacer!,
          ))
          else Spacer(),
          _buildLimitSelector(),
          _buildPageSwitcher()
        ],
      ),
    );
  }


  Widget _buildLimitSelector() {
    final textStyle = TextStyle(
        fontSize: 12.sp,
        color: Colors.grey
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Rows per page',
          style: textStyle,
        ),
        DropdownButton<int>(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          key: UniqueKey(),
          value: limit,
          items: [
            DropdownMenuItem(
              value: 10,
              child: Text('10'),
            ),
            DropdownMenuItem(
              value: 25,
              child: Text('25'),
            ),
            DropdownMenuItem(
              value: 50,
              child: Text('50'),
            ),
          ],
          onChanged: (value) => onLimitChanged(value ?? 10),
          style: textStyle,
          underline: SizedBox(),
        )
      ],
    );
  }

  Widget _buildPageSwitcher() {
    final textStyle = TextStyle(
        fontSize: 12.sp,
        color: Colors.grey
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$currentStartIndex – $currentEndIndex of $total',
          style: textStyle,
        ),
        SizedBox(width: 4.w),
        IconButton(onPressed: switchToPrevious, icon: Icon(Icons.arrow_back_ios_new_rounded, size: 15.sp, color: Colors.grey)),
        IconButton(onPressed: switchToNext, icon: Icon(Icons.arrow_forward_ios_rounded, size: 15.sp, color: Colors.grey)),
        IconButton(onPressed: reset, icon: Icon(Icons.refresh, size: 15.sp, color: Colors.grey))
      ],
    );
  }
}
