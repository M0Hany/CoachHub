# CoachHub UI Guidelines

## Brand Identity

### Colors
```dart
// Authentication Screens Colors
static const authBackgroundColor = Color(0xFF0D122A);  // Dark Blue Background
static const authAccentColor = Color(0xFF0FF789);      // Bright Green Accent
static const authTextLight = Colors.white;             // Light Text
static const authInputBackground = Colors.white24;     // Input Fields Background

// Main App Colors
static const mainBackgroundColor = Color(0xFFDDD6D6);  // Light Gray Background
static const primaryButtonColor = Color(0xFF0D122A);   // Navy Blue
static const primaryButtonText = Colors.white;         // White Text
static const secondaryButtonColor = Color(0xFF0FF789); // Bright Green
static const secondaryButtonText = Color(0xFF0D122A);  // Navy Blue Text
static const navBarColor = Color(0xFF0FF789);         // Bright Green

// Status Colors
static const success = Color(0xFF4CAF50);         // Success Green
static const error = Color(0xFFF44336);           // Error Red
static const warning = Color(0xFFFFC107);         // Warning Yellow
static const info = Color(0xFF2196F3);            // Info Blue
```

### Typography

#### Fonts
- **Headers & App Title**: Eras ITC Demi
  - Path: `assets/fonts/eras-itc-demi.ttf`
  - Usage: Main screen titles, app name next to logo
  
- **Body Text**: Alexandria
  - Path: `assets/fonts/Alexandria.ttf`
  - Usage: All other text content, inputs, buttons

#### Text Styles
```dart
// Headers - Eras ITC Demi
static const headerLarge = TextStyle(
  fontFamily: 'ErasITCDemi',
  fontSize: 32,
  fontWeight: FontWeight.w600,
  color: primaryButtonColor, // Navy for main app
);

static const headerMedium = TextStyle(
  fontFamily: 'ErasITCDemi',
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: primaryButtonColor, // Navy for main app
);

// Auth Screen Headers
static const authHeaderLarge = TextStyle(
  fontFamily: 'ErasITCDemi',
  fontSize: 32,
  fontWeight: FontWeight.w600,
  color: authTextLight,
);

static const authHeaderMedium = TextStyle(
  fontFamily: 'ErasITCDemi',
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: authTextLight,
);

// Body - Alexandria
static const bodyLarge = TextStyle(
  fontFamily: 'Alexandria',
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: primaryButtonColor, // Navy for main app
);

static const bodyMedium = TextStyle(
  fontFamily: 'Alexandria',
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: primaryButtonColor, // Navy for main app
);

// Button Text Styles
static const primaryButtonTextStyle = TextStyle(
  fontFamily: 'Alexandria',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: primaryButtonText, // White
);

static const secondaryButtonTextStyle = TextStyle(
  fontFamily: 'Alexandria',
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: secondaryButtonText, // Navy
);
```

### Logo
- Location: `assets/icons/logo.png`
- Usage: App bar, splash screen, login/register screens
- Size Guidelines:
  - App Bar: 32x32
  - Splash Screen: 96x96
  - Auth Screens: 48x48

## Components

### Input Fields

#### Authentication Screens
```dart
static const authInputDecoration = InputDecoration(
  filled: true,
  fillColor: authInputBackground,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  hintStyle: TextStyle(
    fontFamily: 'Alexandria',
    color: Colors.white70,
  ),
  style: TextStyle(
    fontFamily: 'Alexandria',
    color: Colors.white,
    fontSize: 16,
  ),
);
```

#### Main App Screens
```dart
static const mainInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  hintStyle: TextStyle(
    fontFamily: 'Alexandria',
    color: Colors.grey,
  ),
  style: TextStyle(
    fontFamily: 'Alexandria',
    color: primaryButtonColor,
    fontSize: 16,
  ),
);
```

### Buttons

#### Primary Button (Navy)
```dart
static const primaryButton = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(primaryButtonColor),
  foregroundColor: MaterialStateProperty.all(primaryButtonText),
  padding: MaterialStateProperty.all(
    EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  ),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
);
```

#### Secondary Button (Green)
```dart
static const secondaryButton = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(secondaryButtonColor),
  foregroundColor: MaterialStateProperty.all(secondaryButtonText),
  padding: MaterialStateProperty.all(
    EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  ),
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
);
```

## Screen Layouts

### Authentication Screens
- Dark blue background (authBackgroundColor)
- White text and accents
- Semi-transparent white input fields
- Green accent buttons

### Main App Screens
- Light gray background (mainBackgroundColor)
- Navy text and primary buttons
- White input fields
- Green secondary buttons and navigation bar
- Navy text on buttons
- White text on navy buttons

### Common Patterns
- Safe area padding: 16px all around
- Vertical spacing between elements: 16px
- Input field height: 48px
- Button height: 48px
- Form field spacing: 24px

### Content Screens
- App bar with logo and title
- Content area with consistent padding
- Navigation elements at bottom
- Scrollable content when needed

## Responsive Design

### Breakpoints
```dart
static const mobileBreakpoint = 600;
static const tabletBreakpoint = 900;
static const desktopBreakpoint = 1200;
```

### Adaptations
- Mobile: Single column layout
- Tablet: Two column layout where appropriate
- Desktop: Multi-column layout with max-width containers

## Animation Guidelines

### Transitions
- Page transitions: Fade through
- Button press: Scale feedback
- Loading states: Circular progress
- Error states: Shake animation

### Duration Constants
```dart
static const shortAnimation = Duration(milliseconds: 200);
static const mediumAnimation = Duration(milliseconds: 300);
static const longAnimation = Duration(milliseconds: 500);
```

## Accessibility

### Touch Targets
- Minimum touch target size: 48x48
- Spacing between touchable elements: 8px

### Color Contrast
- Text on background: WCAG AA compliant
- Interactive elements: Clear visual feedback
- Error states: Distinctive color coding

## Assets Organization

### Directory Structure
```
assets/
├── fonts/
│   ├── eras-itc-demi.ttf
│   └── Alexandria.ttf
├── icons/
│   └── logo.png
└── images/
    └── [screen-specific-assets]
```

## Theme Implementation

### Usage Example
```dart
Theme(
  data: ThemeData(
    scaffoldBackgroundColor: backgroundColor,
    textTheme: TextTheme(
      headlineLarge: headerLarge,
      headlineMedium: headerMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
    ),
    // ... other theme configurations
  ),
  child: MaterialApp(
    // ... app configuration
  ),
);
``` 