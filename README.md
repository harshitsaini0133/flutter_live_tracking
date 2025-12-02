# Flutter Live Delivery Tracking Module

A real-time delivery tracking module built with Flutter, demonstrating Clean Architecture, MVVM pattern, and BLoC state management.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-2.18+-blue.svg)](https://dart.dev)

## 📋 Overview

This project simulates live delivery tracking with a driver moving along a predefined route in Hyderabad. The module features real-time map updates, dynamic ETA calculations, and status-based UI updates—all powered by mock data streams.

**Key Features:**

- 🗺️ **Live Map Tracking** with Google Maps integration
- 🚗 **Animated Driver Marker** with status-based color coding
- 📍 **Route Polyline** showing the path traveled
- ⏱️ **Real-time ETA & Distance** calculations
- 📊 **Dynamic Status Updates** (Picked → En Route → Arriving → Delivered)
- 🎨 **Polished UI** with draggable bottom sheet

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with **MVVM** pattern and **BLoC** for state management.

### Folder Structure

```
lib/
├── core/
│   └── utils/
│       └── geo_utils.dart          # Haversine distance & ETA calculations
├── data/
│   ├── models/
│   │   ├── driver_model.dart       # Driver data model
│   │   ├── location_model.dart     # Location with speed/heading/status
│   │   └── route_model.dart        # Complete route data model
│   ├── repositories/
│   │   └── tracking_repository_impl.dart  # Repository implementation
│   └── sources/
│       └── mock_stream_service.dart       # Simulated WebSocket stream
├── domain/
│   └── repositories/
│       └── tracking_repository.dart       # Repository interface
├── presentation/
│   ├── blocs/
│   │   ├── tracking_bloc.dart      # Handles tracking events/states
│   │   └── map_bloc.dart           # Handles map interactions
│   ├── pages/
│   │   └── tracking_page.dart      # Main tracking screen
│   └── widgets/
│       ├── bottom_info_sheet.dart  # Driver info & stats display
│       └── driver_marker.dart      # Custom marker widget
├── app.dart                        # App initialization
└── main.dart                       # Entry point
```

### Architecture Layers

#### 1. **Presentation Layer**

- **BLoCs**: Manage UI state and business logic
  - `TrackingBloc`: Handles `LoadRoute`, `StartTracking`, `UpdateLocation`, `StopTracking`
  - `MapBloc`: Manages map camera and polyline updates
- **Widgets**: Reusable UI components
  - `TrackingPage`: Main screen with Google Maps
  - `BottomInfoSheet`: Draggable sheet showing driver info, ETA, distance

#### 2. **Domain Layer**

- **Repository Interface**: Defines contract for data operations
- Keeps business logic independent of data sources

#### 3. **Data Layer**

- **Models**: Data transfer objects (DTOs)
- **Repository Implementation**: Implements domain contract
- **Mock Stream Service**: Simulates real-time WebSocket data every 2 seconds

---

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (3.10+)
- Dart SDK (2.18+)
- Google Maps API Key

### 1. Clone & Install

```bash
git clone <your-repo-url>
cd flutter_live_tracking
flutter pub get
```

### 2. Configure Google Maps API Key

#### Android

Add your API key to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <application>
    ...
    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="YOUR_API_KEY_HERE"/>
  </application>
</manifest>
```

#### iOS

Add to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### 3. Run the App

```bash
flutter run
```

---

## 📊 Mock Data Simulation

### Route Data

The app uses a predefined route in Hyderabad stored in `assets/mock/route_hyd.json`:

- **Start**: 17.437462, 78.448288 (Pickup location)
- **End**: 17.424354, 78.473945 (Near Necklace Road)
- **9 waypoints** with status progression

### Real-time Streaming

`MockStreamService` emits location updates every **2 seconds**, simulating a WebSocket connection:

- Each update includes: `lat`, `lng`, `speed`, `heading`, `status`, `timestamp`
- Status transitions: `picked` → `en_route` → `arriving` → `delivered`

---

## 🎨 Features Implemented

### Map Features

- ✅ Google Maps integration
- ✅ Driver marker with rotation based on heading
- ✅ Status-based marker colors (Blue → Green → Orange → Red)
- ✅ Customer/destination marker
- ✅ Animated polyline showing traveled path
- ✅ Auto-following camera with smooth animations

### UI Components

- ✅ Draggable bottom sheet with driver information
- ✅ Real-time ETA calculation using Haversine formula
- ✅ Distance remaining updates
- ✅ Status badge with color coding
- ✅ Icons for better visual hierarchy
- ✅ Last updated timestamp

### State Management

- ✅ BLoC pattern implementation
- ✅ Event-driven architecture
- ✅ Stream-based location updates
- ✅ Proper lifecycle management

---

## 🧪 Testing

### Run Analysis

```bash
flutter analyze
```

### Run Tests

```bash
flutter test
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1 # State management
  equatable: ^2.0.3 # Value equality
  google_maps_flutter: ^2.2.5 # Maps integration
  geolocator: ^14.0.2 # Location utilities
  intl: ^0.20.2 # Date/time formatting
  vector_math: ^2.1.0 # Math calculations
```

---

## 🎯 Assignment Requirements Checklist

- ✅ Clean Architecture + MVVM + BLoC
- ✅ Google Maps with live marker movement
- ✅ Route polyline visualization
- ✅ Dynamic ETA & distance calculations
- ✅ Bottom sheet with driver info
- ✅ Status-based UI updates
- ✅ Simulated real-time streaming (2-second intervals)
- ✅ Proper folder structure
- ✅ Code documentation
- ✅ README with setup instructions

---

## 📹 Demo Video

[Insert demo video link here]

---

## 🔧 How It Works

1. **App Initialization**: `App` widget initializes `MockStreamService` asynchronously
2. **Load Route**: `TrackingBloc` loads route data from JSON asset
3. **Start Tracking**: Stream subscription begins, emitting locations every 2 seconds
4. **Update UI**: Location updates trigger:
   - Marker position & rotation update
   - Polyline extends with new point
   - Camera follows driver smoothly
   - Bottom sheet shows live ETA/distance
   - Status badge updates color
5. **Completion**: When status = "delivered", camera stops following

---

## 📄 License

This project is created for interview/assignment purposes.

---

## 👨‍💻 Author

Created as part of a Flutter interview assignment demonstrating Clean Architecture, BLoC pattern, and real-time UI updates.
