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
//
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

## iOS Configuration

### 1. Build Configuration

Update your `ios/Podfile` to ensure minimum iOS version is 13.0:

```ruby
platform :ios, '13.0'

```

and update this for background access of geolocation

```ruby
installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    if target.name == "geolocator_apple"
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'BYPASS_PERMISSION_LOCATION_ALWAYS=1']
      end
    end
  end
```

2. Info.plist
   a. Allowing permission for location

Add these keys to request foreground and background location permissions:

```XML
<!-- Foreground location permission -->

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location while using the app.</string>

<!-- Background location permission -->

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to your location even when the app is in the background.</string>
```

b. Allowing background location updates

Enable background location mode:

```XML
<key>UIBackgroundModes</key>
<array>
  <string>location</string>
</array>

```
