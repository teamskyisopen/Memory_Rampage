# Memory Rampage

**Memory Rampage** is a fast-paced, brain-challenging mobile game developed by **Team SkyIs-Open**.

![Memory Rampage Screenshot](game_pics/FeatureGraphic.png)


## About This Repository

This repository contains **only the source code** (`lib/` folder and assets) required for the game along with the pubspec file.

## Steps to setup the project
1. flutter create memory_rampage
2. cd memory_rampage
3. Copy all Dart files from this repo's lib/ folder into the project lib/ folder.
4. Copy game icon and background music files from this repo's assets/ folder into the project.
5. Replace the pubspec.yaml in your project root with the one from this repository.
6. Run the following command to get dependencies: **flutter pub get**
7. Open android/app/src/main/AndroidManifest.xml
Inside the <application> tag, add the following meta-data tag:
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>

## Steps to Run the game
1. flutter run
2. for creating APK: **flutter build apk --release**
3. This generates a release APK at: build/app/outputs/flutter-apk/app-release.apk
4. for App Bundle for Play Store: **flutter build appbundle --release**
5. This generates a bundle AAB at: build/app/outputs/bundle/release/app-release.aab
