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

class _HomeCardState extends State<HomeCard> with TickerProviderStateMixin {
  // Controllers
  late AnimationController _mainController;
  late AnimationController _backgroundController;
  late AnimationController _iconController;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialAnimations();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.bounceOut,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOutQuart,
    ));
  }

  void _startInitialAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _iconController.forward();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    _iconController.dispose();
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
    final cardPadding = isTablet ? 20.0 : 16.0;
    final iconSize = isTablet ? 28.0 : 24.0;
    final titleSize = isTablet ? 18.0 : 16.0;
    final subtitleSize = isTablet ? 14.0 : 12.0;
    final borderRadius = isTablet ? 20.0 : 16.0;

    final primaryColor = widget.primaryColor ?? const Color(0xFFCF202F);
    final accentColor = widget.accentColor ?? const Color(0xFFEFA947);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        final clampedValue = animValue.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue * (_isPressed ? 0.95 : 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - clampedValue) * 50),
            child: Opacity(
              opacity: clampedValue,
              child: AspectRatio(
                aspectRatio: widget.aspectRatio ?? 1.2,
                child: MouseRegion(
                  onEnter: (_) => _onHoverEnter(),
                  onExit: (_) => _onHoverExit(),
                  child: GestureDetector(
                    onTapDown: (_) => _onTapDown(),
                    onTapUp: (_) => _onTapUp(),
                    onTapCancel: () => _onTapCancel(),
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(borderRadius),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromRGBO(245, 245, 245, 1),
                                    Color.fromRGBO(230, 230, 230, 1),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(
                                      0.1 + (_elevationAnimation.value * 0.2),
                                    ),
                                    blurRadius: 8 + (_elevationAnimation.value * 4),
                                    offset: Offset(0, 4 + (_elevationAnimation.value * 2)),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Animated background circles
                                  _buildBackgroundCircles(primaryColor),

                                  // Main content
                                  _buildContent(
                                    cardPadding,
                                    iconSize,
                                    titleSize,
                                    subtitleSize,
                                    primaryColor,
                                    accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildBackgroundCircles(Color primaryColor) {
    return Stack(
      children: [
        // Top-right circle
        AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Positioned(
              top: -20,
              right: -20,
              child: Transform.scale(
                scale: _backgroundAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.05),
                  ),
                ),
              ),
            );
          },
        ),
        // Bottom-left circle
        AnimatedBuilder(
          animation: _backgroundAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: -30,
              left: -30,
              child: Transform.scale(
                scale: _backgroundAnimation.value * 0.8,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.03),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(
      double padding,
      double iconSize,
      double titleSize,
      double subtitleSize,
      Color primaryColor,
      Color accentColor,
      ) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 200), // Limit width for compact layout
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            // Animated icon container
            AnimatedBuilder(
              animation: Listenable.merge([
                _iconScaleAnimation,
                _iconRotationAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconScaleAnimation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Transform.rotate(
                      angle: _iconRotationAnimation.value,
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
            SizedBox(height: padding), // Space between icon and text
            // Animated text content
            _buildAnimatedText(titleSize, subtitleSize, primaryColor, accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedText(
      double titleSize,
      double subtitleSize,
      Color primaryColor,
      Color accentColor,
      ) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center, // Center text
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w500,
                      color: accentColor.withOpacity(0.8),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center, // Center text
                  ),
                ],
                const SizedBox(height: 8),
                // Animated underline
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  width: 30 * value,
                  height: 3,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(2),
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