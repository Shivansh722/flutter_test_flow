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

  @override
  void initState() {
    super.initState();
    _keyFocusNode = widget.keyFocusNode ?? FocusNode();
    if (widget.requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _keyFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.keyFocusNode == null) {
      _keyFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      hintText: widget.keyController.text.isEmpty ? (widget.keyHint ?? 'Key') : null,
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
                      hintText: widget.valueController.text.isEmpty ? (widget.valueHint ?? 'Value') : null,
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
