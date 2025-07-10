# Flutter Mobile WebView App

A Flutter application that opens a React web application in a mobile WebView with authentication callback support.

## Features

- Mobile WebView integration
- Authentication callback handling
- Cross-platform support (Android/iOS)
- Environment variable configuration
- Login/logout functionality with user state management

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- Git
- A code editor (VS Code recommended)
- At least 8GB of RAM
- 10GB of free disk space

## 1. Installing and Configuring Android Studio

### Step 1: Download Android Studio
1. Go to [Android Studio official website](https://developer.android.com/studio)
2. Download the latest version for your operating system
3. Run the installer and follow the setup wizard

### Step 2: Create Android Virtual Device (AVD)
1. In Android Studio, go to `Tools > AVD Manager`
2. Click `Create Virtual Device`
3. Choose a device (e.g., Pixel 7)
4. Select a system image (API 34 recommended)
5. Configure AVD settings and click `Finish`

## 3. Installing Flutter Dependencies

### Step 1: Install Flutter SDK
1. Download Flutter SDK from [Flutter official website](https://flutter.dev/docs/get-started/install)
2. Extract the ZIP file to a desired location (e.g., `C:\flutter` on Windows)
3. Add Flutter to your PATH:
   - Windows: Add `C:\flutter\bin` to your PATH environment variable
   - macOS/Linux: Add `export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/bin"` to your shell profile

### Step 2: Verify Flutter Installation
```bash
flutter doctor
```

This command checks your environment and displays a report of the status of your Flutter installation.

### Step 3: Install Project Dependencies
Navigate to your project directory and run:
```bash
cd flutter-app
flutter pub get
```

### Step 4: Configure Environment Variables

Since mobile devices cannot access `localhost` directly, you'll need to expose your local React app using ngrok.

#### Install and Setup ngrok
1. **Download ngrok:**
   - Go to [ngrok.com](https://ngrok.com/)
   - Sign up for a free account
   - Download ngrok for your operating system

2. **Install ngrok:**
   - Extract the downloaded file
   - Add ngrok to your system PATH (optional but recommended)

3. **Authenticate ngrok:**
   ```bash
   ngrok config add-authtoken <your-auth-token>
   ```

4. **Start your React app locally:**
   ```bash
   # Start your React app (usually on port 5173)
   npm start
   # or
   yarn start
   ```

5. **Forward localhost using ngrok:**
   ```bash
   # Forward your local React app (replace 5173 with your port)
   ngrok http 5173
   ```

6. **Copy the forwarding URL:**
   - ngrok will display a forwarding URL like: `https://abc123.ngrok-free.app`
   - Copy this URL for use in your `.env` file

#### Create .env file
Create a `.env` file in the root directory with your ngrok URL:
```env
# Environment variables for Flutter app
WEBVIEW_URL=https://your-ngrok-url.ngrok-free.app
```

**Example:**
```env
# Environment variables for Flutter app
WEBVIEW_URL=https://993005d616e8.ngrok-free.app
```

#### Important Notes:
- Keep ngrok running while testing your Flutter app
- The ngrok URL changes each time you restart ngrok (unless you have a paid plan)
- Update the `.env` file with the new URL if ngrok restarts
- Make sure your React app is running before starting ngrok

## 3. How to Get Flutter Devices

### Check Available Devices
```bash
flutter devices
```

This command will show all available devices including:
- Connected physical devices
- Running emulators
- Web browsers
- Desktop platforms

### Common Device Types
- **Android Emulator**: `emulator-5554` (example)
- **Physical Android Device**: `device-id` (when connected via USB)
- **iOS Simulator**: `ios-simulator-id` (macOS only)
- **Chrome Browser**: `chrome`
- **Edge Browser**: `edge`

### Start Android Emulator
```bash
# List available emulators
flutter emulators

# Start a specific emulator
flutter emulators --launch <emulator_name>
```

## 4. How to Run Flutter on Android Device

### Option 1: Using Android Emulator

1. **Start the emulator:**
   ```bash
   flutter emulators --launch <emulator_name>
   ```

2. **Run on specific device:**
   ```bash
   flutter run --device-id emulator-5554
   ```

### Hot Reload
While the app is running, you can:
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit