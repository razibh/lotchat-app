import 'package:flutter/material.dart';
import 'dart:io';
import 'attachment_picker.dart';
import 'emoji_picker.dart';

class MessageInput extends StatefulWidget {

  const MessageInput({
    Key? key,
    required this.onSend,
    this.onAttachment,
    this.onTyping,
    this.enabled = true,
  }) : super(key: key);
  final Function(String) onSend;
  final Function(File)? onAttachment;
  final Function(String)? onTyping;
  final bool enabled;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = _controller.text.trim().isNotEmpty;
    });
    widget.onTyping?.call(_controller.text);
  }

  void _handleSend() {
    if (_isComposing) {
      widget.onSend(_controller.text.trim());
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <>[
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: widget.enabled ? _showAttachmentPicker : null,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_emotions),
            onPressed: widget.enabled
                ? () {
                    setState(() {
                      _showEmoji = !_showEmoji;
                      if (_showEmoji) _focusNode.unfocus();
                    });
                  }
                : null,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isComposing ? Icons.send : Icons.mic,
              color: _isComposing ? Colors.blue : Colors.grey,
            ),
            onPressed: widget.enabled
                ? () {
                    if (_isComposing) {
                      _handleSend();
                    } else {
                      // Start voice recording
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentPicker(
        onPickImage: () {
          Navigator.pop(context);
          // Pick image
        },
        onPickVideo: () {
          Navigator.pop(context);
          // Pick video
        },
        onPickFile: () {
          Navigator.pop(context);
          // Pick file
        },
        onSendLocation: () {
          Navigator.pop(context);
          // Send location
        },
        onSendContact: () {
          Navigator.pop(context);
          // Send contact
        },
      ),
    );
  }
}