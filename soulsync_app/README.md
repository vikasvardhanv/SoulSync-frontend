# soulsync_app

SoulSync - boundary-first, AI-powered dating platform.

## What is now implemented
- Front-page differentiation section plus dedicated page at `/differentiation`.
- Face verification stage in onboarding photo upload flow (iOS) using a native method channel.
- Compatibility narrative in UI focused on:
  - question-based weighted scoring
  - hard boundary filters
  - anti-spam and identity checks

## Faceplugin iOS SDK setup
The Flutter app now calls iOS native methods on channel `soulsync/face_check`.

1. Add `facesdk.framework` from `https://github.com/Faceplugin-ltd/FaceRecognition-iOS` into `ios/Runner` in Xcode.
2. Ensure the framework is added to:
   - `Frameworks, Libraries, and Embedded Content`
   - `Link Binary With Libraries`
3. Build with your activation key:

```bash
flutter run --dart-define=FACEPLUGIN_IOS_LICENSE=YOUR_FACEPLUGIN_LICENSE_KEY
```

Without the framework or key, the app will show explicit face-check errors during onboarding.
