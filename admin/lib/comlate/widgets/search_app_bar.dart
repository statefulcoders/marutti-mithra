import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final bool isEditable;
  final VoidCallback? onSearchClicked;
  final void Function(String term)? getSuggestions;
  final void Function(String term)? onSearchTriggered;
  final void Function()? onCleared;
  final String? hintText;
  final Color? backgroundColor;

  const SearchAppBar({super.key, required this.controller, required this.isEditable, this.onSearchClicked, this.hintText, this.getSuggestions, this.onSearchTriggered, this.onCleared, this.backgroundColor});

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  Timer? _debounce;
  bool showCloseButton = false;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    if (widget.getSuggestions != null) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        widget.getSuggestions!(searchTerm);
      });
    }
    setState(() {
      searchTerm = widget.controller.text.trim();
      showCloseButton = searchTerm.isNotEmpty;
    });
  }

  void clearSearch() {
    widget.controller.clear();
    setState(() {
      searchTerm = '';
      showCloseButton = false;
    });
    widget.onCleared?.call();
  }

  void triggerSearch([ String? term ]) {
    if (widget.onSearchTriggered != null && searchTerm.isNotEmpty) widget.onSearchTriggered!(searchTerm);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      forceMaterialTransparency: widget.backgroundColor == null,
      leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp)
      ),
      titleSpacing: 0,
      centerTitle: true,
      title: _createTextFieldCard(),
      actions: [
        SizedBox(width: 18.w)
      ],
    );
  }

  Widget _createTextFieldCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100)
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: widget.isEditable ? null : widget.onSearchClicked,
          child: Row(
            children: [
              if (!showCloseButton) IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.search,
                  size: 22.sp,
                  color: Colors.grey,
                ),
              ) else SizedBox(width: 16.w),
              Expanded(
                child: _createTextField()
              ),
              if (showCloseButton) IconButton(
                onPressed: clearSearch,
                icon: Icon(
                  Icons.close,
                  size: 22.sp,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _createTextField() {
    final textStyle = TextStyle(
      fontSize: 16.sp,
    );

    return AbsorbPointer(
      absorbing: !widget.isEditable,
      child: TextField(
        controller: widget.controller,
        style: textStyle.copyWith(
          color: Colors.black
        ),
        onSubmitted: triggerSearch,
        keyboardType: TextInputType.webSearch,
        autofocus: widget.isEditable,
        readOnly: !widget.isEditable,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintStyle: textStyle.copyWith(
            color: Colors.grey
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: widget.hintText
        )
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onSearchTextChanged);
    super.dispose();
  }
}
