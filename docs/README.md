# CoachHub - Fitness Coaching Platform

CoachHub is a mobile application that connects fitness trainees with certified coaches in Egypt. The platform emphasizes structured coaching, personalized training plans, and intelligent coach-trainee matching.

## Project Structure

```
.
├── backend/               # Node.js/Express backend
│   ├── src/
│   │   ├── config/       # Configuration files
│   │   ├── controllers/  # Route controllers
│   │   ├── models/       # Database models
│   │   ├── routes/       # API routes
│   │   ├── services/     # Business logic
│   │   └── utils/        # Utility functions
│   └── package.json
│
├── frontend/             # Flutter frontend
│   ├── lib/
│   │   ├── core/        # Core functionality
│   │   ├── data/        # Data layer
│   │   ├── features/    # Feature modules
│   │   └── presentation/# UI layer
│   └── pubspec.yaml
│
└── docs/                # Documentation
```

## Prerequisites

### Backend
- Node.js (v16 or higher)
- MySQL (v8.0 or higher)
- Redis
- Elasticsearch

### Frontend
- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode
- Firebase account

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file:
   ```bash
   cp .env.example .env
   ```

4. Update the `.env` file with your configuration

5. Start the development server:
   ```bash
   npm run dev
   ```

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create a `.env` file:
   ```bash
   cp .env.example .env
   ```

4. Update the `.env` file with your configuration

5. Run the app:
   ```bash
   flutter run
   ```

## Development Guidelines

### Code Style
- Backend: Follow ESLint configuration
- Frontend: Follow Flutter style guide

### Git Workflow
1. Create feature branches from `develop`
2. Submit PRs to `develop`
3. Merge to `main` for releases

### Testing
- Backend: `npm test`
- Frontend: `flutter test`

## API Documentation

API documentation is available at `/api/docs` when running the backend server.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 