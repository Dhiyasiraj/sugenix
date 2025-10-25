# Sugenix - AI-Powered Diabetes Management Platform

A comprehensive Flutter application for diabetes management with Firebase backend integration and Cloudinary image storage, designed to work seamlessly on both mobile and web platforms.

## Features

### 🔐 Authentication & User Management
- Firebase Authentication (Email/Password)
- User profile management with medical history
- Emergency contacts management
- Secure data storage

### 📊 Health Monitoring
- Real-time glucose level tracking
- AI-powered analysis and recommendations
- Historical data visualization
- Health statistics and insights

### 📋 Medical Records
- Image upload to Cloudinary
- Record categorization (reports, prescriptions, invoices)
- Search and filtering capabilities
- Export functionality

### 💊 E-Pharmacy
- Medicine search and ordering
- Shopping cart functionality
- Prescription upload
- Order tracking

### 🚨 Emergency Features
- SOS emergency alerts
- Location tracking and sharing
- Emergency contacts management
- SMS notifications

### 🌐 Cross-Platform Support
- Mobile (Android/iOS)
- Web (Progressive Web App)
- Responsive design
- Platform-specific optimizations

## Tech Stack

- **Frontend**: Flutter 3.8+
- **Backend**: Firebase (Authentication, Firestore)
- **Image Storage**: Cloudinary
- **State Management**: Flutter StatefulWidget
- **UI**: Material Design 3
- **Animations**: Flutter Staggered Animations
- **Image Loading**: Cached Network Image

## Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- Firebase project setup
- Cloudinary account with unsigned preset

## Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd sugenix
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup

#### For Mobile (Android/iOS):
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app to the project
3. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
4. Place the files in:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

#### For Web:
1. Add web app to your Firebase project
2. Copy the Firebase configuration
3. Update `web/index.html` with your Firebase config

### 4. Cloudinary Setup
1. Create a Cloudinary account at [Cloudinary](https://cloudinary.com/)
2. Note your cloud name: `dpfhr81ee`
3. Create an unsigned upload preset named: `sugenix`
4. The app is already configured with these settings

### 5. Platform-Specific Configuration

#### Android
- Update `android/app/build.gradle` with Firebase dependencies
- Ensure minimum SDK version is 21+

#### iOS
- Update `ios/Runner/Info.plist` with required permissions
- Ensure iOS deployment target is 11.0+

#### Web
- The app is configured for web deployment
- Supports Progressive Web App features

## Running the Application

### Mobile Development
```bash
# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on connected device
flutter run
```

### Web Development
```bash
# Run on web
flutter run -d web-server --web-port 8080

# Or run on Chrome
flutter run -d chrome
```

### Building for Production

#### Mobile
```bash
# Build APK for Android
flutter build apk --release

# Build App Bundle for Android
flutter build appbundle --release

# Build for iOS
flutter build ios --release
```

#### Web
```bash
# Build for web
flutter build web --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── services/                 # Backend services
│   ├── auth_service.dart     # Firebase Authentication
│   ├── glucose_service.dart  # Glucose monitoring
│   ├── medical_records_service.dart
│   ├── medicine_orders_service.dart
│   ├── emergency_service.dart
│   ├── cloudinary_service.dart
│   ├── platform_image_service.dart
│   └── platform_location_service.dart
├── screens/                  # UI screens
│   ├── home_screen.dart
│   ├── glucose_monitoring_screen.dart
│   ├── medical_records_screen.dart
│   ├── medicine_orders_screen.dart
│   ├── profile_screen.dart
│   └── emergency_screen.dart
├── models/                   # Data models
├── utils/                    # Utility classes
│   └── responsive_layout.dart
└── assets/                   # Static assets
```

## Key Features Implementation

### Cross-Platform Image Handling
- Uses `PlatformImageService` for mobile/web compatibility
- Web: Single image selection
- Mobile: Multiple image selection

### Location Services
- Uses `PlatformLocationService` for cross-platform location
- Web: Simplified coordinate display
- Mobile: Full GPS functionality

### Responsive Design
- Uses `ResponsiveLayout` for adaptive UI
- Mobile: Single column layout
- Tablet: Multi-column layout
- Desktop: Full desktop experience

### Firebase Integration
- Real-time data synchronization
- Offline support
- Secure authentication
- Cloud Firestore for data storage

### Cloudinary Integration
- Optimized image uploads
- Automatic image optimization
- CDN delivery
- Image transformations

## Deployment

### Web Deployment
1. Build the web app: `flutter build web --release`
2. Deploy the `build/web` folder to your hosting service
3. Configure Firebase hosting (optional)

### Mobile Deployment
1. Follow platform-specific deployment guides
2. Upload to Google Play Store (Android)
3. Upload to Apple App Store (iOS)

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure Firebase configuration files are in place
   - Check Firebase project settings

2. **Image upload fails**
   - Verify Cloudinary settings
   - Check internet connection
   - Ensure proper permissions

3. **Location not working**
   - Check device permissions
   - Verify GPS is enabled
   - Test on physical device

4. **Web-specific issues**
   - Clear browser cache
   - Check console for errors
   - Ensure HTTPS for production

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on both mobile and web
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## Future Enhancements

- [ ] Offline data synchronization
- [ ] Push notifications
- [ ] Wearable device integration
- [ ] Advanced AI analytics
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Voice commands
- [ ] Telemedicine integration