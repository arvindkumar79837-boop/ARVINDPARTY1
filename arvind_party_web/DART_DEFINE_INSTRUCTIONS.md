## Instructions for Securely Configuring the Flutter Web Panel

To run the web application securely, you must provide the Firebase credentials as compile-time environment variables using the `--dart-define` flag. This prevents them from being checked into your source control.

### 1. Get Your Firebase Credentials

From your Firebase project settings, go to "Project settings" > "General" and find your web app under "Your apps". You will need the following values from the Firebase config object:
- `apiKey`
- `authDomain`
- `projectId`
- `storageBucket`
- `messagingSenderId`
- `appId`

You will also need the base URL for your backend API (e.g., `http://localhost:5000/api`).

### 2. Run the App with `--dart-define`

Use the `flutter run` command with a `--dart-define` flag for each variable.

**Example Command (replace with your actual values):**
```sh
flutter run -d chrome 
--dart-define=FIREBASE_API_KEY=AIzaSy... 
--dart-define=FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com 
--dart-define=FIREBASE_PROJECT_ID=your-project-id 
--dart-define=FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com 
--dart-define=FIREBASE_MESSAGING_SENDER_ID=1234567890 
--dart-define=FIREBASE_APP_ID=1:1234567890:web:abcdef123456 
--dart-define=API_BASE_URL=http://localhost:5000/api
```

### 3. Build the App with `--dart-define`

When you are ready to build the production version of your web app, use the same `--dart-define` flags with the `flutter build web` command.

**Example Command (replace with your production values):**
```sh
flutter build web 
--dart-define=FIREBASE_API_KEY=AIzaSy... 
--dart-define=FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com 
--dart-define=FIREBASE_PROJECT_ID=your-project-id 
--dart-define=FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com 
--dart-define=FIREBASE_MESSAGING_SENDER_ID=1234567890 
--dart-define=FIREBASE_APP_ID=1:1234567890:web:abcdef123456 
--dart-define=API_BASE_URL=https://api.yourdomain.com/api
```

By using this method, your sensitive keys are injected only during the build process and are not exposed in your repository.
