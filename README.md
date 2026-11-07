# Vista Companies frontend

Flutter client for the Vista Companies API. It lists companies with their
services and supports creating companies and services.

## Run locally

Start the backend first. The backend listens on `http://localhost:3000`.

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

For an Android emulator, use the host loopback address instead:

```bash
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

The default API URL is `http://localhost:3000`, which is suitable for desktop
and web development.

## Validate

```bash
flutter analyze
flutter test
```

## Database Setup

Create the test database with the following command:

```sql
CREATE DATABASE vista_test;
```
