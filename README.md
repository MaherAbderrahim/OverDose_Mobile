# Project Title
OverDose

## Overview
OverDose is a Flutter application that serves as the user interface for the Django backend. Esprit School of Engineering.

The app lets users:

- sign in or create an account,
- view and edit their profile,
- see saved products,
- take a photo or import one from the gallery,
- run segmentation when multiple products appear in a photo,
- select one or more detected products,
- send selected products to the Django backend for analysis,
- show detected ingredients on the result screen,
- save an analyzed product to the database if desired,
- personalize the profile with allergies and free-form info.

Risk and recommendation logic is not yet integrated in the mobile app and remains on the backend for a later phase.

## Features
- Authentication (login and registration)
- Profile management
- Product list and saved products
- Camera and gallery import
- Product segmentation and selection
- Scan analysis workflow with ingredient display
- Optional product saving after analysis
- Allergy and profile customization

## Tech Stack
### Frontend
- Flutter
- `provider` for global state
- `http` for API calls
- `flutter_secure_storage` for token storage
- `image_picker` for camera and gallery
- `google_fonts` for visual identity

### Backend
- Django (API backend)

### Other Tools
- None specified in this README

## Directory Structure
The main source code is in `lib/src/`.

- `app.dart`: app entry point and bootstrap
- `app_shell.dart`: main navigation with 4 tabs
- `app_controller.dart`: global state, auth, profiles, products
- `services/api_client.dart`: HTTP client for Django
- `services/auth_store.dart`: secure token storage
- `screens/login_screen.dart`: login and registration
- `screens/home_screen.dart`: home dashboard
- `screens/scan_screen.dart`: camera, gallery, and scan start
- `screens/segmentation_screen.dart`: segmented product selection
- `screens/scan_result_screen.dart`: simplified results with ingredients
- `screens/products_screen.dart`: "My products" page
- `screens/profile_screen.dart`: user profile page

## Getting Started
### 1. Install Flutter dependencies
From the `app_mobile` folder:

```bash
flutter pub get
```

### 2. Run the Django backend
The Django API must run locally on port 8000.

```bash
cd ../App_Django
python manage.py runserver
```

### 3. Run the mobile app

```bash
cd ../app_mobile
flutter run
```

If testing on Chrome or another desktop client, the app uses `127.0.0.1:8000`.
If testing on the Android emulator, the app uses `10.0.2.2:8000`.

### 4. Change the backend URL if needed
To target another backend (for example, ngrok later):

```bash
flutter run --dart-define=API_BASE_URL=https://ton-url.ngrok-free.app
```

To force the local backend on web:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

To test on Android emulator, keep the default or force it:

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## API Endpoints
The mobile app calls Django endpoints locally by default.

- Base URL Web/desktop/iOS simulator: `http://127.0.0.1:8000`
- Base URL Android emulator: `http://10.0.2.2:8000`
- Base URL configurable via `API_BASE_URL`

Endpoints used:

- `POST /api/users/auth/register/`
- `POST /api/users/auth/login/`
- `GET /api/users/me/`
- `PATCH /api/users/me/`
- `GET /api/users/allergies/`
- `GET /api/users/me/allergies/`
- `PATCH /api/users/me/allergies/`
- `POST /api/users/allergies/`
- `GET /api/products/`
- `POST /api/products/`
- `POST /api/scan/segment/`
- `POST /api/scan/selected/`
- `POST /api/scan/`

## Postman Collection
Not specified in this README.

## Acknowledgments
None specified in this README.

## GitHub Repository Metadata (Suggested)
Description: Flutter mobile app for OverDose with Django backend integration, scan workflow, and profile management.
Topics: flutter, django, mobile, provider, image-picker, flutter-secure-storage, google-fonts, api