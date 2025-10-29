import 'package:flutter/material.dart';

class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({
    super.key,
    required this.initialKey,
    required this.onDelete,
    required this.onSave,
    required this.onImportJson,
  });

  final String? initialKey;
  final Future<void> Function() onDelete;
  final Future<void> Function(String value) onSave;
  final Future<void> Function(String json) onImportJson;

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late final TextEditingController _keyController;
  final TextEditingController _jsonController = TextEditingController();
  bool _isImportExpanded = false;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(text: widget.initialKey ?? '');
  }

  @override
  void dispose() {
    _keyController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ideogram API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'ideogram-secret-...',
            ),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          _buildImportSection(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await widget.onDelete();
            if (!mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            await widget.onSave(_keyController.text);
            if (!mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildImportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: () {
            setState(() => _isImportExpanded = !_isImportExpanded);
          },
          icon: Icon(_isImportExpanded ? Icons.expand_less : Icons.expand_more),
          label: Text(
            _isImportExpanded ? 'Hide JSON Import' : 'Import from JSON',
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _isImportExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _jsonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '{ "ideogramApiKey": "..." }',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () async {
                    await widget.onImportJson(_jsonController.text);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Import'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
