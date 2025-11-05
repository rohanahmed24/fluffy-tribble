import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/premium_theme.dart';

/// Glass morphism card with blur effect
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: PremiumTheme.premiumShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Premium gradient button with animation
class PremiumGradientButton extends StatefulWidget {
  const PremiumGradientButton({
    required this.onPressed,
    required this.child,
    this.icon,
    this.gradient = PremiumTheme.primaryGradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    super.key,
  });

  final VoidCallback onPressed;
  final Widget child;
  final Widget? icon;
  final Gradient gradient;
  final EdgeInsetsGeometry padding;

  @override
  State<PremiumGradientButton> createState() => _PremiumGradientButtonState();
}

class _PremiumGradientButtonState extends State<PremiumGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _depthAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _depthAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_rotationAnimation.value)
              ..translate(0.0, _depthAnimation.value, 0.0)
              ..scale(_scaleAnimation.value),
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: PremiumTheme.vibrantPurple.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: -2,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        ...PremiumTheme.glowShadow,
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: PremiumTheme.vibrantPurple.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, 12),
                        ),
                      ],
              ),
              child: Padding(
                padding: widget.padding,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 12),
                    ],
                    widget.child,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated premium shimmer effect
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius = 24,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumTheme.cardBackground,
                PremiumTheme.cardBackground.withOpacity(0.8),
                PremiumTheme.cardBackground,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Premium animated loading indicator with 3D effect
class PremiumLoadingIndicator extends StatefulWidget {
  const PremiumLoadingIndicator({
    this.size = 60,
    super.key,
  });

  final double size;

  @override
  State<PremiumLoadingIndicator> createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _3DLoadingPainter(
              animation: _controller.value,
              gradientColors: [
                PremiumTheme.royalPurple,
                PremiumTheme.vibrantPurple,
                PremiumTheme.softLavender,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _3DLoadingPainter extends CustomPainter {
  _3DLoadingPainter({
    required this.animation,
    required this.gradientColors,
  });

  final double animation;
  final List<Color> gradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    // Draw rotating 3D cube with glowing edges
    _draw3DRotatingCube(canvas, size);

    // Draw orbital rings for extra effect
    _drawOrbitalRings(canvas, size);
  }

  void _draw3DRotatingCube(Canvas canvas, Size size) {
    final cubeSize = size.width * 0.4;
    final rotation = animation * math.pi * 2;

    // Define cube vertices in 3D space
    final vertices = [
      [-cubeSize, -cubeSize, -cubeSize],
      [cubeSize, -cubeSize, -cubeSize],
      [cubeSize, cubeSize, -cubeSize],
      [-cubeSize, cubeSize, -cubeSize],
      [-cubeSize, -cubeSize, cubeSize],
      [cubeSize, -cubeSize, cubeSize],
      [cubeSize, cubeSize, cubeSize],
      [-cubeSize, cubeSize, cubeSize],
    ];

    // Apply 3D rotation
    final rotatedVertices = vertices.map((v) {
      var x = v[0];
      var y = v[1];
      var z = v[2];

      // Rotate around Y axis
      final cosY = math.cos(rotation);
      final sinY = math.sin(rotation);
      final xRot = x * cosY + z * sinY;
      final zRot = -x * sinY + z * cosY;
      x = xRot;
      z = zRot;

      // Rotate around X axis
      final cosX = math.cos(rotation * 0.7);
      final sinX = math.sin(rotation * 0.7);
      final yRot = y * cosX - z * sinX;
      final zRot2 = y * sinX + z * cosX;
      y = yRot;
      z = zRot2;

      // Apply perspective projection
      final perspective = 500 / (500 + z);
      return Offset(x * perspective, y * perspective);
    }).toList();

    // Define edges and their depth for z-ordering
    final edges = [
      [0, 1], [1, 2], [2, 3], [3, 0], // Back face
      [4, 5], [5, 6], [6, 7], [7, 4], // Front face
      [0, 4], [1, 5], [2, 6], [3, 7], // Connecting edges
    ];

    // Draw edges with gradient based on depth
    for (var i = 0; i < edges.length; i++) {
      final edge = edges[i];
      final v1 = rotatedVertices[edge[0]];
      final v2 = rotatedVertices[edge[1]];

      // Calculate depth for color intensity
      final depth = (i / edges.length);
      final colorIndex = ((animation + depth) % 1.0 * gradientColors.length).floor();
      final nextColorIndex = (colorIndex + 1) % gradientColors.length;
      final t = (animation + depth) % 1.0 * gradientColors.length - colorIndex;

      final color = Color.lerp(
        gradientColors[colorIndex],
        gradientColors[nextColorIndex],
        t,
      )!;

      final paint = Paint()
        ..shader = ui.Gradient.linear(
          v1,
          v2,
          [color, color.withOpacity(0.3)],
        )
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(v1, v2, paint);

      // Add glow effect
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(v1, v2, glowPaint);
    }
  }

  void _drawOrbitalRings(Canvas canvas, Size size) {
    final radius = size.width * 0.45;

    // Draw three orbital rings
    for (var i = 0; i < 3; i++) {
      final angle = (animation + i / 3) * math.pi * 2;

      canvas.save();

      // Rotate the ring
      canvas.transform(Matrix4.rotationY(angle + i * math.pi / 3).storage);

      // Scale to create perspective
      canvas.scale(1.0, 0.25);

      final paint = Paint()
        ..shader = ui.Gradient.sweep(
          Offset.zero,
          [
            gradientColors[i % gradientColors.length].withOpacity(0.6),
            gradientColors[(i + 1) % gradientColors.length].withOpacity(0.2),
            gradientColors[i % gradientColors.length].withOpacity(0.6),
          ],
          [0.0, 0.5, 1.0],
        )
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset.zero, radius, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_3DLoadingPainter oldDelegate) => true;
}

/// Animated scale fade in widget
class ScaleFadeIn extends StatefulWidget {
  const ScaleFadeIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  @override
  State<ScaleFadeIn> createState() => _ScaleFadeInState();
}

class _ScaleFadeInState extends State<ScaleFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Premium icon button with ripple effect
class PremiumIconButton extends StatefulWidget {
  const PremiumIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final double size;

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _depthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _depthAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateX(_depthAnimation.value)
              ..scale(_scaleAnimation.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTheme.vibrantPurple.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: -4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: widget.size * 0.5,
              ),
            ),
          );
        },
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// 3D Floating Shapes Background Animation
class Floating3DShapes extends StatefulWidget {
  const Floating3DShapes({super.key});

  @override
  State<Floating3DShapes> createState() => _Floating3DShapesState();
}

class _Floating3DShapesState extends State<Floating3DShapes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FloatingShape> _shapes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Create random floating shapes
    final random = math.Random();
    _shapes = List.generate(8, (index) {
      return _FloatingShape(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 40 + random.nextDouble() * 80,
        rotationSpeed: 0.5 + random.nextDouble() * 1.5,
        floatSpeed: 0.3 + random.nextDouble() * 0.7,
        shape: index % 3 == 0 ? _ShapeType.cube : (index % 3 == 1 ? _ShapeType.sphere : _ShapeType.pyramid),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _FloatingShapesPainter(
            animation: _controller.value,
            shapes: _shapes,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

enum _ShapeType { cube, sphere, pyramid }

class _FloatingShape {
  final double x;
  final double y;
  final double size;
  final double rotationSpeed;
  final double floatSpeed;
  final _ShapeType shape;

  _FloatingShape({
    required this.x,
    required this.y,
    required this.size,
    required this.rotationSpeed,
    required this.floatSpeed,
    required this.shape,
  });
}

class _FloatingShapesPainter extends CustomPainter {
  final double animation;
  final List<_FloatingShape> shapes;

  _FloatingShapesPainter({
    required this.animation,
    required this.shapes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var shape in shapes) {
      final centerX = size.width * shape.x;
      final centerY = size.height * shape.y + math.sin(animation * math.pi * 2 * shape.floatSpeed) * 30;
      final rotation = animation * math.pi * 2 * shape.rotationSpeed;

      canvas.save();
      canvas.translate(centerX, centerY);

      switch (shape.shape) {
        case _ShapeType.cube:
          _drawRotating3DCube(canvas, shape.size, rotation);
          break;
        case _ShapeType.sphere:
          _drawRotating3DSphere(canvas, shape.size, rotation);
          break;
        case _ShapeType.pyramid:
          _drawRotating3DPyramid(canvas, shape.size, rotation);
          break;
      }

      canvas.restore();
    }
  }

  void _drawRotating3DCube(Canvas canvas, double size, double rotation) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = ui.Gradient.linear(
        Offset(-size / 2, -size / 2),
        Offset(size / 2, size / 2),
        [
          PremiumTheme.royalPurple.withOpacity(0.3),
          PremiumTheme.vibrantPurple.withOpacity(0.2),
          PremiumTheme.softLavender.withOpacity(0.1),
        ],
      );

    final halfSize = size / 2;

    // Define cube vertices in 3D space
    final vertices = [
      [-halfSize, -halfSize, -halfSize],
      [halfSize, -halfSize, -halfSize],
      [halfSize, halfSize, -halfSize],
      [-halfSize, halfSize, -halfSize],
      [-halfSize, -halfSize, halfSize],
      [halfSize, -halfSize, halfSize],
      [halfSize, halfSize, halfSize],
      [-halfSize, halfSize, halfSize],
    ];

    // Apply 3D rotation
    final rotatedVertices = vertices.map((v) {
      final x = v[0];
      final y = v[1];
      final z = v[2];

      // Rotate around Y axis
      final cosY = math.cos(rotation);
      final sinY = math.sin(rotation);
      final xRot = x * cosY + z * sinY;
      final zRot = -x * sinY + z * cosY;

      // Rotate around X axis
      final cosX = math.cos(rotation * 0.7);
      final sinX = math.sin(rotation * 0.7);
      final yRot = y * cosX - zRot * sinX;
      final zRot2 = y * sinX + zRot * cosX;

      // Apply perspective projection
      final perspective = 1000 / (1000 + zRot2);
      return Offset(xRot * perspective, yRot * perspective);
    }).toList();

    // Draw cube edges
    final edges = [
      [0, 1], [1, 2], [2, 3], [3, 0], // Back face
      [4, 5], [5, 6], [6, 7], [7, 4], // Front face
      [0, 4], [1, 5], [2, 6], [3, 7], // Connecting edges
    ];

    for (var edge in edges) {
      canvas.drawLine(rotatedVertices[edge[0]], rotatedVertices[edge[1]], paint);
    }
  }

  void _drawRotating3DSphere(Canvas canvas, double size, double rotation) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = ui.Gradient.radial(
        Offset.zero,
        size / 2,
        [
          PremiumTheme.vibrantPurple.withOpacity(0.4),
          PremiumTheme.softLavender.withOpacity(0.2),
          PremiumTheme.lightLavender.withOpacity(0.05),
        ],
      );

    final radius = size / 2;

    // Draw multiple rotating circles to create 3D sphere effect
    for (var i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi;
      final circleRadius = radius * math.sin(angle);
      final yOffset = radius * math.cos(angle);

      // Apply rotation transformation
      final rotatedAngle = angle + rotation;
      final rotatedY = radius * math.cos(rotatedAngle);

      canvas.save();
      canvas.translate(0, rotatedY);
      canvas.scale(1.0, 0.3); // Create perspective effect
      canvas.drawCircle(Offset.zero, circleRadius, paint);
      canvas.restore();
    }

    // Draw vertical circle
    canvas.save();
    canvas.scale(0.3, 1.0);
    canvas.drawCircle(Offset.zero, radius, paint);
    canvas.restore();
  }

  void _drawRotating3DPyramid(Canvas canvas, double size, double rotation) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = ui.Gradient.linear(
        Offset(-size / 2, -size / 2),
        Offset(size / 2, size / 2),
        [
          PremiumTheme.royalPurple.withOpacity(0.35),
          PremiumTheme.softLavender.withOpacity(0.15),
        ],
      );

    final halfSize = size / 2;

    // Define pyramid vertices
    final vertices = [
      [0.0, -halfSize, 0.0], // Top
      [-halfSize, halfSize, -halfSize], // Base corners
      [halfSize, halfSize, -halfSize],
      [halfSize, halfSize, halfSize],
      [-halfSize, halfSize, halfSize],
    ];

    // Apply 3D rotation
    final rotatedVertices = vertices.map((v) {
      final x = v[0];
      final y = v[1];
      final z = v[2];

      // Rotate around Y axis
      final cosY = math.cos(rotation);
      final sinY = math.sin(rotation);
      final xRot = x * cosY + z * sinY;
      final zRot = -x * sinY + z * cosY;

      // Apply perspective
      final perspective = 1000 / (1000 + zRot);
      return Offset(xRot * perspective, y * perspective);
    }).toList();

    // Draw pyramid edges
    final edges = [
      [0, 1], [0, 2], [0, 3], [0, 4], // Top to base
      [1, 2], [2, 3], [3, 4], [4, 1], // Base edges
    ];

    for (var edge in edges) {
      canvas.drawLine(rotatedVertices[edge[0]], rotatedVertices[edge[1]], paint);
    }
  }

  @override
  bool shouldRepaint(_FloatingShapesPainter oldDelegate) => true;
}

/// Premium empty state widget
class PremiumEmptyState extends StatelessWidget {
  const PremiumEmptyState({
    required this.title,
    required this.description,
    this.icon = Icons.image_outlined,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ScaleFadeIn(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumTheme.vibrantPurple.withOpacity(0.2),
                    PremiumTheme.royalPurple.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: PremiumTheme.vibrantPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 60,
                color: PremiumTheme.vibrantPurple,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
