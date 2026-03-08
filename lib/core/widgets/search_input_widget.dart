import 'package:flutter/material.dart';

class SearchInputWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final Function()? onClear;
  final String? initialValue;

  const SearchInputWidget({
    super.key,
    this.hintText = 'Ara...',
    required this.onSearch,
    this.onClear,
    this.initialValue,
  });

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onSearch('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: const Color(0xFFF57C00), 
        ),
      ),
      child: TapRegion(
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: TextField(
          controller: _controller,
          onChanged: widget.onSearch,
          cursorColor: const Color(0xFFF57C00),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                    onPressed: _handleClear,
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[100], // Arka plan: Hafif gri
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            
            // Tıklamadan önce 
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            
            // Tıklandığında
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF57C00), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
