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
      case 4:
        context.go(widget.role == UserRole.trainee ? '/trainee/notifications' : '/coach/notifications');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = widget.role == UserRole.trainee
        ? [
            _buildNavItem(Icons.search_outlined, Icons.search, l10n.navSearch, 0),
            _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, l10n.navChats, 1),
            _buildNavItem(Icons.home_outlined, Icons.home, l10n.navHome, 2),
            _buildNavItem(Icons.person_outline, Icons.person, l10n.navProfile, 3),
            _buildNavItem(Icons.notifications_outlined, Icons.notifications, l10n.navNotifications, 4),
          ]
        : [
            _buildNavItem(Icons.fitness_center_outlined, Icons.fitness_center, l10n.navPlans, 0),
            _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, l10n.navChats, 1),
            _buildNavItem(Icons.home_outlined, Icons.home, l10n.navHome, 2),
            _buildNavItem(Icons.person_outline, Icons.person, l10n.navProfile, 3),
            _buildNavItem(Icons.notifications_outlined, Icons.notifications, l10n.navNotifications, 4),
          ];

    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          // Background with cutout
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: CustomPaint(
              painter: NavBarPainter(
                color: AppColors.accent,
                selectedIndex: widget.currentIndex,
                itemCount: items.length,
                context: context,
              ),
            ),
          ),
          // Animated floating circle
          AnimatedBuilder(
            animation: _positionAnimation,
            builder: (context, child) {
              final isRTL = Directionality.of(context) == TextDirection.rtl;
              final itemWidth = MediaQuery.of(context).size.width / items.length;
              final circleSize = 50.0;
              
              // Calculate base position
              double position = _positionAnimation.value * itemWidth;
              
              // Adjust for RTL
              if (isRTL) {
                position = MediaQuery.of(context).size.width - position - itemWidth;
              }
              
              // Center within the item
              position += (itemWidth - circleSize) / 2;

              return Positioned(
                top: 20,
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
                  ),
                ),
              );
            },
          ),
          // Navigation items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = index == widget.currentIndex;
    final itemWidth = MediaQuery.of(context).size.width / 5; // Changed from 6 to 5 items

    return SizedBox(
      width: itemWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTapped(index),
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
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? AppColors.textLight : AppColors.primary,
                    size: 24,
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
    );
  }
}

class NavBarPainter extends CustomPainter {
  final Color color;
  final int selectedIndex;
  final int itemCount;
  final BuildContext context;

  NavBarPainter({
    required this.color,
    required this.selectedIndex,
    required this.itemCount,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final itemWidth = size.width / itemCount;
    var selectedItemX = itemWidth * selectedIndex + itemWidth / 2;
    
    // Adjust for RTL
    if (Directionality.of(context) == TextDirection.rtl) {
      selectedItemX = size.width - selectedItemX;
    }
    
    // Create the main path with the cutout
    final path = Path()
      ..moveTo(0, 35)
      ..lineTo(selectedItemX - 30, 35)
      ..quadraticBezierTo(
        selectedItemX - 25,
        0,
        selectedItemX,
        0,
      )
      ..quadraticBezierTo(
        selectedItemX + 25,
        0,
        selectedItemX + 30,
        35,
      )
      ..lineTo(size.width, 35)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavBarPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
           oldDelegate.color != color ||
           oldDelegate.itemCount != itemCount;
  }
}