# CoachHub Project Structure

## Important Reminders
- Always use full paths when running terminal commands
- Current workspace path: `F:\Programming\CoachHub`
- Frontend path: `F:\Programming\CoachHub\frontend`
- Backend path: `F:\Programming\CoachHub\backend`

## Directory Structure

```
CoachHub/
├── frontend/                      # Flutter application
│   ├── android/                   # Android platform files
│   ├── ios/                       # iOS platform files
│   ├── lib/                       # Dart source code
│   │   ├── core/                  # Core functionality
│   │   │   ├── constants/         # App constants
│   │   │   ├── errors/           # Error handling
│   │   │   ├── network/          # Network utilities
│   │   │   ├── theme/            # App theme
│   │   │   ├── widgets/          # Shared widgets
│   │   │   ├── utils/            # Utility functions
│   │   │   └── localization/     # Localization files
│   │   ├── features/             # Feature modules
│   │   │   ├── auth/             # Authentication feature
│   │   │   │   ├── data/         # Data layer
│   │   │   │   │   ├── models/   # Data models
│   │   │   │   │   ├── repositories/ # Repositories
│   │   │   │   │   └── sources/  # Data sources
│   │   │   │   ├── domain/       # Domain layer
│   │   │   │   │   ├── entities/ # Business entities
│   │   │   │   │   ├── repositories/ # Repository interfaces
│   │   │   │   │   └── usecases/ # Business logic
│   │   │   │   └── presentation/ # Presentation layer
│   │   │   │       ├── bloc/     # State management
│   │   │   │       ├── screens/  # UI screens
│   │   │   │       └── widgets/  # Feature-specific widgets
│   │   │   ├── coach/            # Coach feature
│   │   │   │   ├── data/         # Coach data layer
│   │   │   │   │   └── models/   # Coach models
│   │   │   │   └── presentation/ # Coach UI layer
│   │   │   │       ├── providers/ # Coach state management
│   │   │   │       ├── screens/  # Coach screens
│   │   │   │       │   ├── chat/ # Coach chat screens
│   │   │   │       │   ├── home/ # Coach home screens
│   │   │   │       │   └── plans/ # Coach plan screens
│   │   │   │       └── widgets/  # Coach-specific widgets
│   │   │   ├── trainee/          # Trainee feature
│   │   │   │   ├── data/         # Trainee data layer
│   │   │   │   │   └── models/   # Trainee models
│   │   │   │   └── presentation/ # Trainee UI layer
│   │   │   │       ├── providers/ # Trainee state management
│   │   │   │       ├── screens/  # Trainee screens
│   │   │   │       │   ├── chat/ # Trainee chat screens
│   │   │   │       │   ├── home/ # Trainee home screens
│   │   │   │       │   ├── notifications/ # Trainee notifications
│   │   │   │       │   ├── profile/ # Trainee profile
│   │   │   │       │   ├── search/ # Trainee search
│   │   │   │       │   └── workout/ # Trainee workout screens
│   │   │   │       └── widgets/  # Trainee-specific widgets
│   │   │   └── plans/            # Training plans feature
│   │   └── main.dart             # App entry point
│   ├── assets/                    # Static assets
│   │   ├── images/               # Image assets
│   │   ├── icons/                # Icon assets
│   │   └── fonts/                # Font files
│   └── pubspec.yaml              # Flutter dependencies
│
├── backend/                       # Node.js/Express backend
│   ├── src/                      # Source code
│   │   ├── config/               # Configuration files
│   │   ├── controllers/          # Route controllers
│   │   ├── models/               # Database models
│   │   ├── routes/               # API routes
│   │   ├── services/             # Business logic
│   │   ├── middleware/           # Custom middleware
│   │   └── utils/                # Utility functions
│   ├── tests/                    # Test files
│   └── package.json              # Node.js dependencies
│
└── docs/                         # Project documentation
    ├── PROJECT_OVERVIEW.md       # Project overview
    ├── IMPLEMENTATION_PLAN.md    # Implementation details
    ├── FRONTEND.md              # Frontend architecture
    ├── BACKEND.md               # Backend architecture
    └── PROJECT_STRUCTURE.md     # This file
```

## Feature Module Structure
Each feature module follows clean architecture principles with three main layers:

### 1. Data Layer
- Models: Data transfer objects (DTOs)
- Repositories: Concrete implementations
- Sources: Remote and local data sources

### 2. Domain Layer (Optional for simpler features)
- Entities: Core business objects
- Repositories: Abstract interfaces
- Use Cases: Business logic operations

### 3. Presentation Layer
- Providers/Bloc: State management
- Screens: UI implementations
  - Role-specific screens in respective directories
- Widgets: Feature-specific components

## Shared Components
- Core widgets: Reusable across all features
- Theme: Consistent styling and branding
- Constants: App-wide configurations
- Utils: Common utility functions

## Role-Based Organization
Features are organized by user role (coach/trainee) when they have distinct implementations:
- Separate screen directories
- Role-specific providers
- Shared core components

## Common Terminal Commands

### Frontend Commands
```bash
# Always use full path
cd F:\Programming\CoachHub\frontend

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build the app
flutter build apk
```

### Backend Commands
```bash
# Always use full path
cd F:\Programming\CoachHub\backend

# Install dependencies
npm install

# Run development server
npm run dev

# Run tests
npm test
```

## Development Guidelines

### Path Usage
- Always use full paths in terminal commands
- Use forward slashes (/) in code paths
- Use backslashes (\) in Windows terminal commands
- Double-check paths before running commands

### Directory Creation
- Create directories using full paths
- Ensure proper permissions
- Follow the clean architecture structure
- Document any deviations

### File Organization
- Keep related files in their respective layers
- Use consistent naming conventions
- Follow feature-first and role-based architecture
- Maintain separation of concerns

## Important Notes
1. Always verify the current working directory before running commands
2. Use full paths to avoid confusion and errors
3. Keep the directory structure clean and organized
4. Document any changes to the structure
5. Follow clean architecture principles
6. Place shared components in core directory
7. Organize role-specific features in their respective directories 