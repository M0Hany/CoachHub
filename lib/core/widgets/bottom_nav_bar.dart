import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../constants/enums.dart';
import '../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatefulWidget {
  final UserRole role;
  final int currentIndex;

  const BottomNavBar({
    Key? key,
    required this.role,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _positionAnimation;
  double _previousPosition = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _positionAnimation = Tween<double>(
      begin: _previousPosition,
      end: widget.currentIndex.toDouble(),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousPosition = oldWidget.currentIndex.toDouble();
      _positionAnimation = Tween<double>(
        begin: _previousPosition,
        end: widget.currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;
    
    switch (index) {
      case 0:
        context.go(widget.role == UserRole.trainee ? '/trainee/search' : '/coach/plans');
        break;
      case 1:
        context.go(widget.role == UserRole.trainee ? '/trainee/chats' : '/coach/chats');
        break;
      case 2:
        context.go(widget.role == UserRole.trainee ? '/trainee/home' : '/coach/home');
        break;
      case 3:
        context.go(widget.role == UserRole.trainee ? '/trainee/profile' : '/coach/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTrainee = widget.role == UserRole.trainee;
    final navItems = isTrainee
        ? [
            {'label': l10n.navSearch, 'active': 'assets/icons/navigation/Search Active.png', 'inactive': 'assets/icons/navigation/Search Inactive.png'},
            {'label': l10n.navChats, 'active': 'assets/icons/navigation/Chats Active.png', 'inactive': 'assets/icons/navigation/Chats Inactive.png'},
            {'label': l10n.navHome, 'active': 'assets/icons/navigation/Home Active.png', 'inactive': 'assets/icons/navigation/Home Inactive.png'},
            {'label': l10n.navProfile, 'active': 'assets/icons/navigation/Profile Active.png', 'inactive': 'assets/icons/navigation/Profile Inactive.png'},
          ]
        : [
            {'label': l10n.navPlans, 'active': 'assets/icons/navigation/Plans Active.png', 'inactive': 'assets/icons/navigation/Plans Inactive.png'},
            {'label': l10n.navChats, 'active': 'assets/icons/navigation/Chats Active.png', 'inactive': 'assets/icons/navigation/Chats Inactive.png'},
            {'label': l10n.navHome, 'active': 'assets/icons/navigation/Home Active.png', 'inactive': 'assets/icons/navigation/Home Inactive.png'},
            {'label': l10n.navProfile, 'active': 'assets/icons/navigation/Profile Active.png', 'inactive': 'assets/icons/navigation/Profile Inactive.png'},
          ];

    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          // Main bar background (no cutout, square top corners)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 90,
            child: CustomPaint(
              painter: NavBarBarPainter(
                color: AppColors.accent,
                itemCount: 4,
              ),
            ),
          ),
          // Cutout curve under the floating icon
          AnimatedBuilder(
            animation: _positionAnimation,
            builder: (context, child) {
              final isRTL = Directionality.of(context) == TextDirection.rtl;
              final itemWidth = MediaQuery.of(context).size.width / 4;
              final circleSize = 50.0;
              double position = _positionAnimation.value * itemWidth;
              if (isRTL) {
                position = MediaQuery.of(context).size.width - position - itemWidth;
              }
              position += (itemWidth - circleSize) / 2 + circleSize / 2;
              return Positioned(
                top: 60,
                left: 0,
                right: 0,
                height: 55,
                child: CustomPaint(
                  painter: NavBarCutoutPainter(
                    color: AppTheme.mainBackgroundColor,
                    cutoutCenterX: position,
                  ),
                ),
              );
            },
          ),
          // Animated floating circle with selected icon
          AnimatedBuilder(
            animation: _positionAnimation,
            builder: (context, child) {
              final isRTL = Directionality.of(context) == TextDirection.rtl;
              final itemWidth = MediaQuery.of(context).size.width / 4;
              final circleSize = 50.0;
              double position = _positionAnimation.value * itemWidth;
              if (isRTL) {
                position = MediaQuery.of(context).size.width - position - itemWidth;
              }
              position += (itemWidth - circleSize) / 2;
              return Positioned(
                top: 32, // Move the circle down a bit
                left: position,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        navItems[widget.currentIndex]['active']!,
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Navigation items (inactive icons and labels)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                final isSelected = index == widget.currentIndex;
                return _buildNavItem(
                  navItems[index]['inactive']!,
                  navItems[index]['label']!,
                  isSelected,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Only show inactive icon and label for unselected tabs
  Widget _buildNavItem(String iconPath, String label, bool isSelected) {
    final itemWidth = MediaQuery.of(context).size.width / 4;
    return SizedBox(
      width: itemWidth,
      child: IgnorePointer(
        ignoring: isSelected, // Don't allow tap on selected tab
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onItemTapped(navLabelToIndex(label)),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            child: SizedBox(
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.translationValues(
                      0,
                      isSelected ? -45 : 0,
                      0,
                    ),
                    child: isSelected
                        ? const SizedBox(height: 28) // Placeholder for selected icon
                        : Image.asset(
                            iconPath,
                            width: 28,
                            height: 28,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to map label to index for onTap
  int navLabelToIndex(String label) {
    final l10n = AppLocalizations.of(context)!;
    final isTrainee = widget.role == UserRole.trainee;
    if (isTrainee) {
      if (label == l10n.navSearch) return 0;
      if (label == l10n.navChats) return 1;
      if (label == l10n.navHome) return 2;
      if (label == l10n.navProfile) return 3;
    } else {
      if (label == l10n.navPlans) return 0;
      if (label == l10n.navChats) return 1;
      if (label == l10n.navHome) return 2;
      if (label == l10n.navProfile) return 3;
    }
    return 0;
  }
}

// New painter for the main bar (no cutout, square top corners)
class NavBarBarPainter extends CustomPainter {
  final Color color;
  final int itemCount;

  NavBarBarPainter({
    required this.color,
    required this.itemCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavBarBarPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.itemCount != itemCount;
  }
}

// New painter for the cutout curve only
class NavBarCutoutPainter extends CustomPainter {
  final Color color;
  final double cutoutCenterX;

  NavBarCutoutPainter({
    required this.color,
    required this.cutoutCenterX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // Cutout shape: a small curve under the floating icon
    const cutoutWidth = 90.0;
    const cutoutDepth = 60.0;
    final left = cutoutCenterX - cutoutWidth / 2;
    final right = cutoutCenterX + cutoutWidth / 2;
    final path = Path()
      ..moveTo(left, 0)
      ..quadraticBezierTo(
        cutoutCenterX,
        cutoutDepth,
        right,
        0,
      )
      ..lineTo(left, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavBarCutoutPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.cutoutCenterX != cutoutCenterX;
  }
}