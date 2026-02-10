# Matrimony Technopalette

A comprehensive matrimony platform application featuring a cross-platform mobile app and a robust backend system.

## Project Overview

This project is a full-stack application designed to facilitate matrimonial connections. It includes:
- A mobile application built with **Flutter** for user interaction.
- A powerful backend API built with **Django** and **Django REST Framework**.
- Real-time communication features powered by **Agora** and **Firebase Cloud Functions**.

## Project Structure

The repository is organized into the following main directories:

- `matrimony_app/`: The Flutter frontend application source code.
- `matrimony_backend/`: The Django backend project containing API logic, user management, and deployment scripts.
- `agora_functions/`: Firebase Cloud Functions used for generating Agora tokens for video/audio calls.

## Technology Stack

### Frontend (Mobile App)
- **Framework**: Flutter (Dart)
- **State Management**: Change notifier with Animated Builder, Singleton instance for DI
- **Features**: Profile management, Matchmaking, Chat, Video Calls.

### Backend (API)
- **Framework**: Django (Python)
- **API**: Django REST Framework
- **Server**: Gunicorn, Nginx
- **Database**: PostgreSQL (Recommended for production)

### Real-time Services
- **Video/Audio**: Agora IO
- **Serverless**: Firebase Cloud Functions

## Getting Started

### Prerequisites
- Flutter SDK
- Python 3.x
- Node.js (for Firebase functions)
- PostgreSQL (or SQLite for local dev)

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd matrimony_backend
   ```

2. Create and activate a virtual environment:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run migrations:
   ```bash
   python manage.py migrate
   ```

5. Start the development server:
   ```bash
   python manage.py runserver
   ```

### Frontend Setup

1. Navigate to the app directory:
   ```bash
   cd matrimony_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -t lib/main_dev.dart
   ```

### Agora Functions Setup

1. Navigate to the functions directory:
   ```bash
   cd agora_functions
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Deploy functions (requires Firebase CLI):
   ```bash
   npm run serve
   ```

## Deployment

The `matrimony_backend` directory contains several shell scripts for deployment configuration, including:
- `server_deploy_gunicorn.sh`
- `server_deploy_nginx.sh`

Refer to these scripts for production deployment configurations on a Linux server.

## License

[Add License Information Here]
