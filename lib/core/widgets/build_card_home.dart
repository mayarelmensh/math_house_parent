import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class HomeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? primaryColor;
  final Color? accentColor;
  final bool enableParticles;
  final bool enableGlow;
  final double? aspectRatio;

  const HomeCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.primaryColor,
    this.accentColor,
    this.enableParticles = true,
    this.enableGlow = true,
    this.aspectRatio = 1.2,
  });

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard>
    with TickerProviderStateMixin {

  // Controllers
  late AnimationController _mainController;
  late AnimationController _particlesController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.fastOutSlowIn,
    ));

    _elevationAnimation = Tween<double>(
      begin: 12.0,
      end: 28.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _textScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.fastOutSlowIn,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Hover handlers
  void _onHoverEnter() {
    if (!_isHovered) {
      setState(() => _isHovered = true);
      _mainController.forward();
    }
  }

  void _onHoverExit() {
    if (_isHovered) {
      setState(() => _isHovered = false);
      _mainController.reverse();
    }
  }

  // Tap handlers
  void _onTapDown() {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Responsive values
    final isTablet = size.width > 600;
    final isMobile = size.width <= 600;

    final cardPadding = isTablet ? 28.0 : 20.0;
    final iconSize = isTablet ? 48.0 : 40.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final subtitleSize = isTablet ? 14.0 : 12.0;
    final borderRadius = isTablet ? 24.0 : 20.0;

    final primaryColor = widget.primaryColor ?? const Color(0xFFCF202F); // AppColors.primary
    final accentColor = widget.accentColor ?? const Color(0xFFEFA947); // AppColors.yellow
    final surfaceColor = theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _pulseAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * (_isPressed ? 0.98 : 1.0),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio ?? 1.2,
            child: MouseRegion(
              onEnter: (_) => _onHoverEnter(),
              onExit: (_) => _onHoverExit(),
              child: GestureDetector(
                onTapDown: (_) => _onTapDown(),
                onTapUp: (_) => _onTapUp(),
                onTapCancel: () => _onTapCancel(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      // Main shadow
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: _elevationAnimation.value,
                        spreadRadius: 2,
                        offset: Offset(0, _elevationAnimation.value / 3),
                      ),
                      // Glow effect
                      if (widget.enableGlow)
                        BoxShadow(
                          color: primaryColor.withOpacity(_glowAnimation.value * 0.1),
                          blurRadius: _elevationAnimation.value * 1.5,
                          spreadRadius: _isHovered ? 4 : 0,
                        ),
                      // Inner light
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(-2, -2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Stack(
                      children: [
                        // Background gradient
                        _buildBackground(primaryColor, accentColor, surfaceColor),

                        // Floating particles
                        if (widget.enableParticles)
                          _buildParticles(primaryColor, isTablet),

                        // Glass overlay
                        _buildGlassOverlay(borderRadius),

                        // Main content
                        _buildContent(
                          cardPadding,
                          iconSize,
                          titleSize,
                          subtitleSize,
                          primaryColor,
                          accentColor,
                          isTablet,
                        ),

                        // Ripple effect
                        _buildRippleEffect(borderRadius),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground(Color primary, Color accent, Color surface) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surface,
            surface.withOpacity(0.9),
            primary.withOpacity(0.05),
            accent.withOpacity(0.03),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildParticles(Color color, bool isTablet) {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final progress = (_particlesController.value + index * 0.125) % 1.0;
            final angle = progress * 2 * math.pi;
            final radius = 30 + (index * 8);
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            final size = isTablet ? 4.0 : 3.0;

            return Positioned(
              left: 50 + x,
              top: 50 + y,
              child: Transform.scale(
                scale: math.sin(progress * math.pi),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2 * math.sin(progress * math.pi)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildGlassOverlay(double borderRadius) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(_isHovered ? 0.3 : 0.15),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      double padding,
      double iconSize,
      double titleSize,
      double subtitleSize,
      Color primaryColor,
      Color accentColor,
      bool isTablet,
      ) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: Listenable.merge([
                _iconScaleAnimation,
                _rotationAnimation,
                _pulseAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconScaleAnimation.value * _pulseAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: iconSize + 16,
                      height: iconSize + 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white,
                            Colors.white.withOpacity(0.9),
                            primaryColor.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: iconSize,
                        color: primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isTablet ? 20 : 16),

            // Animated title
            AnimatedBuilder(
              animation: _textScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _textScaleAnimation.value,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                      letterSpacing: 0.5,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: primaryColor.withOpacity(0.2),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Subtitle
            if (widget.subtitle != null) ...[
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: subtitleSize,
                  fontWeight: FontWeight.w500,
                  color: accentColor.withOpacity(0.8),
                  letterSpacing: 0.3,
                ),
              ),
            ],

            SizedBox(height: isTablet ? 16 : 12),

            // Progress indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isHovered ? 60 : 40,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    accentColor,
                    Colors.white.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRippleEffect(double borderRadius) {
    return AnimatedOpacity(
      opacity: _isPressed ? 0.3 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
        ),
      ),
    );
  }
}