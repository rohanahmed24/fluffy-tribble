import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/ideogram_api_client.dart';
import '../state/generation_state.dart';
import '../widgets/generation_form.dart';
import '../widgets/premium_widgets.dart';
import '../theme/premium_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GenerationState>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumTheme.deepPurple,
              PremiumTheme.darkBackground,
              PremiumTheme.darkBackground,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildPremiumAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildHeroSection(context),
                      const SizedBox(height: 32),
                      _buildGenerationForm(context),
                      const SizedBox(height: 24),
                      if (state.error != null) _buildErrorMessage(context, state.error!),
                      const SizedBox(height: 32),
                      _buildImageGallery(context, state),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar(BuildContext context) {
    return ScaleFadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: PremiumTheme.glowShadow,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => PremiumTheme.shimmerGradient.createShader(bounds),
                      child: Text(
                        'Ideogram',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      'AI Studio',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PremiumTheme.softLavender,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                PremiumIconButton(
                  icon: Icons.vpn_key_rounded,
                  onPressed: () => _showApiKeyDialog(context),
                  tooltip: 'Manage API Key',
                ),
                const SizedBox(width: 12),
                PremiumIconButton(
                  icon: Icons.security_rounded,
                  onPressed: _launchPrivacyDocs,
                  tooltip: 'Security Practices',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return ScaleFadeIn(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumTheme.royalPurple.withOpacity(0.3),
                    PremiumTheme.vibrantPurple.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: PremiumTheme.vibrantPurple.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PremiumTheme.premiumGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTheme.premiumGold,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PREMIUM EDITION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: PremiumTheme.champagneGold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) => PremiumTheme.shimmerGradient.createShader(bounds),
              child: Text(
                'Transform Ideas\nInto Art',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Harness the power of AI to create stunning,\nprofessional-grade images in seconds',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationForm(BuildContext context) {
    return ScaleFadeIn(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          child: GenerationForm(onSubmit: _onSubmit),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String error) {
    return ScaleFadeIn(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF6B6B).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFFF6B6B),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, GenerationState state) {
    if (state.isLoading) {
      return ScaleFadeIn(
        child: Column(
          children: [
            const PremiumLoadingIndicator(size: 80),
            const SizedBox(height: 24),
            Text(
              'Creating your masterpiece...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: PremiumTheme.softLavender,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (state.images.isEmpty) {
      return PremiumEmptyState(
        title: 'Your Gallery Awaits',
        description: 'Start by creating your first AI-generated image.\nLet your imagination run wild!',
        icon: Icons.auto_awesome_outlined,
      );
    }

    return ScaleFadeIn(
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Creations',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: PremiumTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.images.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PremiumImageGrid(images: state.images),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          borderRadius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: PremiumTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'API Key',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Ideogram API Key',
                  hintText: 'ideogram-secret-...',
                  prefixIcon: Icon(Icons.key, size: 20),
                ),
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final jsonController = TextEditingController();
                  await showDialog<void>(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: GlassCard(
                        borderRadius: 28,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Import from JSON',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: jsonController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: '{ "ideogramApiKey": "..." }',
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 12),
                                PremiumGradientButton(
                                  onPressed: () {
                                    state.importKeyFromJson(jsonController.text);
                                    Navigator.of(context).pop();
                                  },
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  child: const Text(
                                    'Import',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('Import from JSON'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      state.deleteKey();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B6B),
                    ),
                    label: const Text('Delete'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      PremiumGradientButton(
                        onPressed: () {
                          state.updateApiKey(controller.text);
                          Navigator.of(context).pop();
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchPrivacyDocs() async {
    const url = 'https://docs.flutter.dev/deployment/android';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _PremiumImageGrid extends StatelessWidget {
  const _PremiumImageGrid({required this.images});

  final List<GeneratedImage> images;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return ScaleFadeIn(
          delay: Duration(milliseconds: 100 * (index % 4)),
          child: _PremiumImageCard(image: image),
        );
      },
    );
  }
}

class _PremiumImageCard extends StatefulWidget {
  const _PremiumImageCard({required this.image});

  final GeneratedImage image;

  @override
  State<_PremiumImageCard> createState() => _PremiumImageCardState();
}

class _PremiumImageCardState extends State<_PremiumImageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_elevationAnimation.value),
            child: GestureDetector(
              onTap: () => _showImageDetail(context),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isHovered
                        ? PremiumTheme.vibrantPurple.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                    width: 2,
                  ),
                  boxShadow: _isHovered
                      ? PremiumTheme.glowShadow
                      : PremiumTheme.elevatedShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.image.url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const ShimmerLoading();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: PremiumTheme.cardBackground,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.white38,
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      if (widget.image.prompt != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.image.prompt!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_isHovered)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    widget.image.url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (widget.image.prompt != null) ...[
                const SizedBox(height: 20),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    widget.image.prompt!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
