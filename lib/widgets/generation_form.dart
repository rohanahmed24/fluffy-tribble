import 'package:flutter/material.dart';

import '../api/ideogram_api_client.dart';
import '../theme/premium_theme.dart';
import 'premium_widgets.dart';

class GenerationForm extends StatefulWidget {
  const GenerationForm({
    required this.onSubmit,
    super.key,
  });

  final void Function(
    BuildContext context,
    String prompt,
    ImageStyle style,
    double aspectRatio,
  ) onSubmit;

  @override
  State<GenerationForm> createState() => _GenerationFormState();
}

class _GenerationFormState extends State<GenerationForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _promptController = TextEditingController();
  final _aspectRatioController = TextEditingController(text: '1.0');
  ImageStyle _selectedStyle = ImageStyle.photorealistic;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _aspectRatioController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            'Describe Your Vision',
            Icons.edit_note_rounded,
          ),
          const SizedBox(height: 16),
          _buildPromptField(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      'Style',
                      Icons.palette_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildStyleDropdown(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      'Ratio',
                      Icons.aspect_ratio_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildAspectRatioField(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PremiumTheme.vibrantPurple.withOpacity(0.3),
                PremiumTheme.royalPurple.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: PremiumTheme.softLavender,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9),
              ),
        ),
      ],
    );
  }

  Widget _buildPromptField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PremiumTheme.royalPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _promptController,
        decoration: InputDecoration(
          labelText: 'What do you want to create?',
          hintText: 'A futuristic city at sunset with flying cars...',
          prefixIcon: const Icon(Icons.psychology_rounded, size: 22),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear_rounded, size: 20),
            onPressed: () => _promptController.clear(),
            tooltip: 'Clear',
          ),
          counterText: '',
        ),
        maxLines: 4,
        maxLength: 500,
        style: Theme.of(context).textTheme.bodyLarge,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Please describe your vision' : null,
      ),
    );
  }

  Widget _buildStyleDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PremiumTheme.royalPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<ImageStyle>(
        value: _selectedStyle,
        items: ImageStyle.values.map((style) {
          return DropdownMenuItem<ImageStyle>(
            value: style,
            child: Row(
              children: [
                _getStyleIcon(style),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    style.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedStyle = value);
          }
        },
        decoration: const InputDecoration(
          labelText: 'Choose style',
          prefixIcon: Icon(Icons.auto_fix_high_rounded, size: 22),
        ),
        dropdownColor: PremiumTheme.cardBackground,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
    );
  }

  Widget _getStyleIcon(ImageStyle style) {
    IconData icon;
    Color color;

    switch (style) {
      case ImageStyle.photorealistic:
        icon = Icons.camera_alt_rounded;
        color = PremiumTheme.softLavender;
        break;
      case ImageStyle.anime:
        icon = Icons.animation_rounded;
        color = const Color(0xFFFF6B9D);
        break;
      case ImageStyle.digital:
        icon = Icons.computer_rounded;
        color = const Color(0xFF4ECDC4);
        break;
      case ImageStyle.fantasy:
        icon = Icons.auto_awesome_rounded;
        color = const Color(0xFFFFD93D);
        break;
      case ImageStyle.vintage:
        icon = Icons.photo_filter_rounded;
        color = const Color(0xFFD4A373);
        break;
      case ImageStyle.threeDimensional:
        icon = Icons.view_in_ar_rounded;
        color = const Color(0xFF6C63FF);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildAspectRatioField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PremiumTheme.royalPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _aspectRatioController,
        decoration: const InputDecoration(
          labelText: 'Aspect',
          hintText: '1.0',
          prefixIcon: Icon(Icons.crop_square_rounded, size: 22),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.bodyLarge,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          final parsed = double.tryParse(value);
          if (parsed == null || parsed <= 0) {
            return 'Positive number';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: PremiumGradientButton(
          onPressed: _handleSubmit,
          gradient: PremiumTheme.shimmerGradient,
          padding: const EdgeInsets.symmetric(vertical: 20),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 20,
            ),
          ),
          child: Text(
            'Generate Image',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final aspectRatio = double.parse(_aspectRatioController.text.trim());
      widget.onSubmit(
        context,
        _promptController.text.trim(),
        _selectedStyle,
        aspectRatio,
      );
    }
  }
}
