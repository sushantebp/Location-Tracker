# Live Location Tracker Setup Guide

## Android Configuration

### 1. Build Configuration

Update your `android/app/build.gradle.kts` to ensure compatibility with the latest Android 14/15 features.

```kotlin
android {
    // Required for Android 14 (API 34) and Android 15 (API 35)
    compileSdk = 35
}
```

### 2. Manifest Permissions

Add the following permissions to android/app/src/main/AndroidManifest.xml. These must be placed inside the <manifest> tag but outside the <application> tag.

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
```

### 3. Foreground Service Declaration (Android 14+)

If you plan to track location while the app is in the background, you must declare the service type inside the <application> tag:

```XML

<service
    android:name="com.baseflow.geolocator.GeolocatorWorkerService"
    android:foregroundServiceType="location"
    android:exported="false" />
```
