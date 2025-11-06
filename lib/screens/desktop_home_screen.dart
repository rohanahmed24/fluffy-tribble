import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/generation_state.dart';
import '../theme/desktop_theme.dart';
import '../widgets/glassmorphism.dart';
import '../widgets/provider_settings_dialog.dart';
import '../utils/responsive_helper.dart';

/// Gorgeous desktop home screen optimized for Windows, macOS, and Linux
/// Features: Sidebar navigation, glassmorphism effects, premium animations
class DesktopHomeScreen extends StatefulWidget {
  const DesktopHomeScreen({super.key});

  @override
  State<DesktopHomeScreen> createState() => _DesktopHomeScreenState();
}

class _DesktopHomeScreenState extends State<DesktopHomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  int _selectedNavIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Gorgeous Sidebar
          _buildSidebar(context),

          // Main Content Area
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  /// Build gorgeous sidebar with glassmorphism
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesktopTheme.darkSurface,
            DesktopTheme.darkSurface.withOpacity(0.8),
          ],
        ),
        border: Border(
          right: BorderSide(
            color: DesktopTheme.darkBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App Logo & Title
          _buildAppHeader(),

          const SizedBox(height: 32),

          // Navigation Items
          _buildNavItem(0, Icons.auto_awesome, 'Generate', () {
            setState(() => _selectedNavIndex = 0);
          }),
          _buildNavItem(1, Icons.grid_view_rounded, 'Gallery', () {
            setState(() => _selectedNavIndex = 1);
          }),
          _buildNavItem(2, Icons.settings_outlined, 'Settings', () {
            setState(() => _selectedNavIndex = 2);
          }),

          const Spacer(),

          // Current Provider Card
          _buildProviderCard(context),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// App header with gradient text
  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          // App icon with gradient
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: DesktopTheme.purpleGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DesktopTheme.primaryPurple.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          // App title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => DesktopTheme.purpleGradient
                    .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: const Text(
                  'AI Studio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Pro',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesktopTheme.darkTextSecondary,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Navigation item with hover effect
  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final isSelected = _selectedNavIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? DesktopTheme.purpleGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: DesktopTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : DesktopTheme.darkTextSecondary,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : DesktopTheme.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Current provider card with glassmorphism
  Widget _buildProviderCard(BuildContext context) {
    return Consumer<GenerationState>(
      builder: (context, state, _) {
        final provider = state.currentProviderInfo;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Glassmorphism(
            blur: 20,
            opacity: 0.05,
            borderRadius: 16,
            child: InkWell(
              onTap: () => _showProviderSettings(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: DesktopTheme.meshGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.api,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider?.name ?? 'No Provider',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: DesktopTheme.darkText,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: DesktopTheme.darkTextSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Active Provider',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesktopTheme.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Main content area with gorgeous animations
  Widget _buildMainContent(BuildContext context) {
    Widget content;

    switch (_selectedNavIndex) {
      case 0:
        content = _buildGenerateView(context);
        break;
      case 1:
        content = _buildGalleryView(context);
        break;
      case 2:
        content = _buildSettingsView(context);
        break;
      default:
        content = _buildGenerateView(context);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: content,
    );
  }

  /// Generate view with beautiful gradient hero section
  Widget _buildGenerateView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section with mesh gradient
          _buildHeroSection(context),

          const SizedBox(height: 48),

          // Generation form
          _buildGenerationForm(context),

          const SizedBox(height: 48),

          // Recent generations
          _buildRecentGenerations(context),
        ],
      ),
    );
  }

  /// Gorgeous hero section
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: DesktopTheme.meshGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: DesktopTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Text(
                '✨ POWERED BY AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create Stunning\nImages in Seconds',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transform your ideas into beautiful visuals with AI',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generation form with glassmorphism
  Widget _buildGenerationForm(BuildContext context) {
    return Consumer<GenerationState>(
      builder: (context, state, _) {
        return Glassmorphism(
          blur: 20,
          opacity: 0.03,
          borderRadius: 24,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Describe your vision',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                // Prompt input
                TextField(
                  controller: _promptController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'A serene mountain landscape at sunset with vibrant colors...',
                    hintStyle: TextStyle(fontSize: 15),
                  ),
                ),

                const SizedBox(height: 24),

                // Generate button with gradient
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => _generateImage(context, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: DesktopTheme.purpleGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: state.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.auto_awesome, size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Generate Image',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
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

  /// Recent generations gallery
  Widget _buildRecentGenerations(BuildContext context) {
    return Consumer<GenerationState>(
      builder: (context, state, _) {
        if (state.images.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Creations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1,
              ),
              itemCount: state.images.length.clamp(0, 6),
              itemBuilder: (context, index) {
                final image = state.images[index];
                return HoverCard(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      image.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Gallery view - full image grid
  Widget _buildGalleryView(BuildContext context) {
    return Consumer<GenerationState>(
      builder: (context, state, _) {
        if (state.images.isEmpty) {
          return _buildEmptyState(
            icon: Icons.photo_library_outlined,
            title: 'No images yet',
            subtitle: 'Generate your first image to see it here',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(48),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1,
          ),
          itemCount: state.images.length,
          itemBuilder: (context, index) {
            final image = state.images[index];
            return HoverCard(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  image.url,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Settings view
  Widget _buildSettingsView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),

          // Provider settings card
          HoverCard(
            onTap: () => _showProviderSettings(context),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: DesktopTheme.purpleGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.api, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Providers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Configure API keys and select providers',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: DesktopTheme.meshGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: DesktopTheme.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateImage(BuildContext context, GenerationState state) async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    await state.generateImage(prompt: _promptController.text.trim());
  }

  void _showProviderSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProviderSettingsDialog(),
    );
  }
}
