import 'package:flutter/material.dart';

class CustomKeyValueInput extends StatefulWidget {
  final TextEditingController keyController;
  final TextEditingController valueController;
  final int index;
  final VoidCallback? onRemove;
  final bool canRemove;
  final FocusNode? keyFocusNode;
  final bool requestFocus;
  final String? keyHint;
  final String? valueHint;

  const CustomKeyValueInput({
    super.key,
    required this.keyController,
    required this.valueController,
    required this.index,
    this.onRemove,
    this.canRemove = true,
    this.keyFocusNode,
    this.requestFocus = false,
    this.keyHint,
    this.valueHint,
  });

  @override
  State<CustomKeyValueInput> createState() => _CustomKeyValueInputState();
}

class _CustomKeyValueInputState extends State<CustomKeyValueInput> {
  late FocusNode _keyFocusNode;
  bool _shouldDisposeFocusNode = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _keyFocusNode = widget.keyFocusNode ?? FocusNode();
    _shouldDisposeFocusNode = widget.keyFocusNode == null;
    
    if (widget.requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_disposed && _keyFocusNode.canRequestFocus) {
          try {
            _keyFocusNode.requestFocus();
          } catch (e) {
            debugPrint('Focus request failed in CustomKeyValueInput: $e');
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(CustomKeyValueInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the focus node changed, update our reference
    if (oldWidget.keyFocusNode != widget.keyFocusNode) {
      if (_shouldDisposeFocusNode && !_disposed) {
        try {
          _keyFocusNode.dispose();
        } catch (e) {
          debugPrint('Error disposing old focus node: $e');
        }
      }
      _keyFocusNode = widget.keyFocusNode ?? FocusNode();
      _shouldDisposeFocusNode = widget.keyFocusNode == null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_shouldDisposeFocusNode) {
      try {
        _keyFocusNode.dispose();
      } catch (e) {
        debugPrint('Error disposing focus node: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cache hint text values to avoid rebuilding issues
    final String keyHintText = widget.keyHint ?? 'Key';
    final String valueHintText = widget.valueHint ?? 'Value';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Custom Input ${widget.index + 1}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 164, 164, 219),
                ),
              ),
              const Spacer(),
              if (widget.canRemove)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.grey[600],
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: widget.keyController,
                    focusNode: _keyFocusNode,
                    decoration: InputDecoration(
                      hintText: keyHintText,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: widget.valueController,
                    decoration: InputDecoration(
                      hintText: valueHintText,
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
