import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/ideogram_api_client.dart';
import '../state/generation_state.dart';
import '../widgets/generation_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GenerationState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideogram Studio'),
        actions: [
          if (state.images.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _showClearImagesDialog(context),
              tooltip: 'Clear All Images',
            ),
          IconButton(
            icon: const Icon(Icons.vpn_key),
            onPressed: () => _showApiKeyDialog(context),
            tooltip: 'Manage API Key',
          ),
          IconButton(
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: _launchPrivacyDocs,
            tooltip: 'Security Practices',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: GenerationForm(onSubmit: _onSubmit),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ImageGrid(images: state.images),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit(BuildContext context, String prompt, ImageStyle style,
      double aspectRatio) {
    final state = context.read<GenerationState>();
    state.generateImage(
      prompt: prompt,
      style: style,
      aspectRatio: aspectRatio,
    );
  }

  Future<void> _showApiKeyDialog(BuildContext context) async {
    final state = context.read<GenerationState>();
    final controller = TextEditingController(text: state.apiKey ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ideogram API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'ideogram-secret-...'
              ),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                final jsonController = TextEditingController();
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Import from JSON'),
                    content: TextField(
                      controller: jsonController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: '{ "ideogramApiKey": "..." }',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          state.importKeyFromJson(jsonController.text);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Import'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Import from JSON'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              state.deleteKey();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              state.updateApiKey(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearImagesDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Images?'),
        content: const Text(
          'This will remove all generated images from the gallery. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<GenerationState>().clearImages();
    }
  }

  Future<void> _launchPrivacyDocs() async {
    const url = 'https://docs.flutter.dev/deployment/android';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({required this.images});

  final List<GeneratedImage> images;

  void _showImageDialog(BuildContext context, GeneratedImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Image.network(image.url),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            if (image.prompt != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      image.prompt!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: image.prompt!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Prompt copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Prompt'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _shareImage(context, image),
                          icon: const Icon(Icons.share),
                          label: const Text('Share URL'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareImage(BuildContext context, GeneratedImage image) async {
    // Share the image URL
    await Clipboard.setData(ClipboardData(text: image.url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image URL copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Center(
        child: Text('Generate images to see them here.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return InkWell(
          onTap: () => _showImageDialog(context, image),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(image.url, fit: BoxFit.cover),
                if (image.prompt != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black45,
                      child: Text(
                        image.prompt!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
