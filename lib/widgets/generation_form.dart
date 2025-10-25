import 'package:flutter/material.dart';

import '../api/ideogram_api_client.dart';

class GenerationForm extends StatefulWidget {
  const GenerationForm({required this.onSubmit, super.key});

  final void Function(
    BuildContext context,
    String prompt,
    ImageStyle style,
    double aspectRatio,
  )
  onSubmit;

  @override
  State<GenerationForm> createState() => _GenerationFormState();
}

class _GenerationFormState extends State<GenerationForm> {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _aspectRatioController = TextEditingController(text: '1.0');
  ImageStyle _selectedStyle = ImageStyle.photorealistic;

  @override
  void dispose() {
    _promptController.dispose();
    _aspectRatioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _promptController,
            decoration: const InputDecoration(
              labelText: 'Prompt',
              hintText: 'Describe your concept clearly...',
            ),
            maxLines: 3,
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ImageStyle>(
            value: _selectedStyle,
            items: ImageStyle.values
                .map(
                  (style) => DropdownMenuItem<ImageStyle>(
                    value: style,
                    child: Text(style.displayName),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStyle = value);
              }
            },
            decoration: const InputDecoration(labelText: 'Style'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _aspectRatioController,
            decoration: const InputDecoration(
              labelText: 'Aspect Ratio',
              helperText: 'Use values like 1.0, 1.5, 2.0',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final parsed = double.tryParse(value);
              if (parsed == null || parsed <= 0) {
                return 'Enter a positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final aspectRatio = double.parse(
                    _aspectRatioController.text.trim(),
                  );
                  widget.onSubmit(
                    context,
                    _promptController.text,
                    _selectedStyle,
                    aspectRatio,
                  );
                }
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate'),
            ),
          ),
        ],
      ),
    );
  }
}
