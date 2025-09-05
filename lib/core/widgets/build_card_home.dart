import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:math_house_parent/core/utils/app_colors.dart';

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
  late AnimationController _mainController;
  late AnimationController _particlesController;
  late AnimationController _pulseController;

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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.fastOutSlowIn),
    );

    _elevationAnimation = Tween<double>(begin: 12.0, end: 28.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOut),
    );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _textScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.02.h),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.fastOutSlowIn));

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particlesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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
    final isTablet = size.width > 600;

    // Responsive sizing using ScreenUtil
    final cardPadding = isTablet ? 28.w : 20.w;
    final iconSize = isTablet ? 48.sp : 40.sp;
    final titleSize = isTablet ? 18.sp : 16.sp;
    final subtitleSize = isTablet ? 14.sp : 12.sp;
    final borderRadius = isTablet ? 24.r : 20.r;
    final particleSize = isTablet ? 4.w : 3.w;
    final particleRadius = isTablet ? 40.w : 30.w;
    final shadowBlur = isTablet ? 12.r : 8.r;
    final shadowSpread = isTablet ? 2.r : 1.r;

    final primaryColor = widget.primaryColor ?? AppColors.primaryColor;
    final accentColor = widget.accentColor ?? const Color(0xFFEFA947);
    final surfaceColor = theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation, _glowAnimation]),
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
                  margin: EdgeInsets.all(8.w), // Responsive margin
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.03),
                        blurRadius: _elevationAnimation.value,
                        spreadRadius: shadowSpread,
                        offset: Offset(0, _elevationAnimation.value / 3),
                      ),
                      if (widget.enableGlow)
                        BoxShadow(
                          color: primaryColor.withOpacity(_glowAnimation.value * 0.1),
                          blurRadius: _elevationAnimation.value * 1.5,
                          spreadRadius: _isHovered ? 4.r : 0,
                        ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: shadowBlur,
                        offset: Offset(-2.w, -2.h),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Stack(
                      children: [
                        _buildBackground(primaryColor, accentColor, surfaceColor),
                        if (widget.enableParticles)
                          _buildParticles(primaryColor, particleSize, particleRadius),
                        _buildGlassOverlay(borderRadius),
                        _buildContent(
                          cardPadding,
                          iconSize,
                          titleSize,
                          subtitleSize,
                          primaryColor,
                          accentColor,
                          isTablet,
                        ),
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

  Widget _buildParticles(Color color, double particleSize, double particleRadius) {
    return AnimatedBuilder(
      animation: _particlesController,
      builder: (context, child) {
        return Stack(
          children: List.generate(8, (index) {
            final progress = (_particlesController.value + index * 0.125) % 1.0;
            final angle = progress * 2 * math.pi;
            final radius = particleRadius + (index * 8.w);
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;

            return Positioned(
              left: (50.w + x).clamp(0, MediaQuery.of(context).size.width),
              top: (50.h + y).clamp(0, MediaQuery.of(context).size.height),
              child: Transform.scale(
                scale: math.sin(progress * math.pi),
                child: Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2 * math.sin(progress * math.pi)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 4.r,
                        spreadRadius: 1.r,
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
          width: 1.5.w,
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
            AnimatedBuilder(
              animation: Listenable.merge([_iconScaleAnimation, _rotationAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _iconScaleAnimation.value * _pulseAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: iconSize + 16.w,
                      height: iconSize + 16.h,
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
                            blurRadius: 12.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, size: iconSize, color: primaryColor),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: isTablet ? 20.h : 16.h),
            AnimatedBuilder(
              animation: _textScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _textScaleAnimation.value,
                  child: Center(
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
                            offset: Offset(0, 1.h),
                            blurRadius: 3.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.subtitle != null) ...[
              SizedBox(height: isTablet ? 8.h : 6.h),
              Center(
                child: Text(
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
              ),
            ],
            SizedBox(height: isTablet ? 16.h : 12.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isHovered ? 60.w : 40.w,
              height: 3.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2.r),
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor, Colors.white.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 6.r,
                    spreadRadius: 1.r,
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
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}