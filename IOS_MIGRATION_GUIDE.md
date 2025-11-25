# iOS Migration Guide

This guide explains how to update all remaining screens to use platform-aware widgets for iOS compatibility.

## Quick Migration Pattern

### 1. Update Imports
```dart
// Add these imports
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/utils/platform_text_field.dart';
```

### 2. Replace Scaffold
```dart
// OLD:
return Scaffold(
  appBar: AppBar(...),
  body: ...,
);

// NEW:
return PlatformWidget.scaffold(
  context: context,
  appBar: AppBar(...), // Will auto-convert to CupertinoNavigationBar on iOS
  body: ...,
);
```

### 3. Replace Buttons
```dart
// OLD:
ElevatedButton(
  onPressed: () {},
  child: Text('Click'),
)

// NEW:
PlatformButton(
  onPressed: () {},
  child: Text('Click'),
)

// For text buttons:
PlatformTextButton(
  onPressed: () {},
  child: Text('Click'),
)
```

### 4. Replace Text Fields
```dart
// OLD:
TextField(
  controller: controller,
  decoration: InputDecoration(...),
)

// NEW:
PlatformTextField(
  controller: controller,
  placeholder: 'Hint text',
  labelText: 'Label',
)

// For forms:
PlatformTextFormField(
  controller: controller,
  validator: (value) => ...,
  placeholder: 'Hint text',
)
```

### 5. Replace Dialogs
```dart
// OLD:
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
)

// NEW:
PlatformWidget.showPlatformDialog(
  context: context,
  title: 'Title',
  content: 'Message',
  actions: [...],
)
```

### 6. Replace Navigation
```dart
// OLD:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => Screen()),
)

// NEW:
if (PlatformUtils.isIOS) {
  Navigator.push(
    context,
    CupertinoPageRoute(builder: (context) => Screen()),
  );
} else {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Screen()),
  );
}

// OR use NavigationService (already platform-aware):
NavigationService().navigateToScreen(Screen());
```

## Files That Need Updates

### Auth Screens ✅ (Completed)
- [x] lib/screens/auth/Login_form.dart
- [x] lib/screens/Reset_pass_screen.dart
- [ ] lib/screens/registrarion_form.dart (commented out, may need update if enabled)

### Profile Screens
- [ ] lib/screens/profile/myProfile_screen.dart
- [ ] lib/screens/profile/profile_edit_screen.dart
- [ ] lib/screens/profile/profile_settings_screen.dart

### Search & Connection Screens
- [ ] lib/screens/Search/search_screen.dart
- [ ] lib/screens/Search/search_details_screen.dart
- [ ] lib/screens/connection/connectionDetails.dart
- [ ] lib/screens/connection/my_connections.dart
- [ ] lib/screens/connection/request_sent.dart
- [ ] lib/screens/connection/recive_request.dart

### Event & Testimonial Screens
- [ ] lib/screens/event/Event_screen.dart
- [ ] lib/screens/event/event_details_screen.dart
- [ ] lib/screens/event/registered_events_screen.dart
- [ ] lib/screens/testimonial/testimonial_screen.dart
- [ ] lib/screens/testimonial/testimonial_listing_screen.dart
- [ ] lib/screens/testimonial/ask_testimonial_screen.dart
- [ ] lib/screens/testimonial/testimonialDetails/*.dart

### Accountability & Other Features
- [ ] lib/screens/Accountability/accountability_page.dart
- [ ] lib/screens/Accountability/accountability_detail_page.dart
- [ ] lib/screens/create_accountability_page.dart
- [ ] lib/screens/tyfcb_screen.dart
- [ ] lib/screens/one_to_one.dart
- [ ] lib/screens/vision_board_screen.dart
- [ ] lib/screens/gallery_screen.dart
- [ ] lib/screens/qr_scanner_screen.dart
- [ ] lib/screens/discount_coupon/*.dart

### Chat & Community
- [ ] lib/screens/chat/Chat_Screen.dart
- [ ] lib/screens/chat/Chat_page.dart
- [ ] lib/screens/community_screen.dart
- [ ] lib/screens/Activity_feed.dart

### Other Screens
- [ ] lib/screens/settings_screen.dart
- [ ] lib/screens/Refferal_Screen.dart
- [ ] lib/screens/content_screen.dart
- [ ] lib/screens/home/Landing_screen.dart

### Widget Files
- [ ] lib/widgets/*.dart (check all widget files)
- [ ] lib/screens/home/widgets/*.dart
- [ ] lib/screens/discount_coupon/widgets/*.dart

## Common Patterns to Replace

### CircularProgressIndicator
```dart
// OLD:
CircularProgressIndicator()

// NEW:
PlatformWidget.loadingIndicator()
```

### SnackBar
```dart
// OLD:
ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))

// NEW (iOS uses different approach):
if (PlatformUtils.isIOS) {
  // Show Cupertino-style notification or use dialog
} else {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))
}
```

### AppBar
AppBar will automatically convert to CupertinoNavigationBar when used with PlatformWidget.scaffold, but you can also manually create:

```dart
if (PlatformUtils.isIOS) {
  return CupertinoNavigationBar(
    middle: Text('Title'),
    leading: CupertinoNavigationBarBackButton(),
  );
}
return AppBar(title: Text('Title'));
```

## Testing Checklist

After updating each screen:
- [ ] Test on iOS simulator/device
- [ ] Test on Android to ensure backward compatibility
- [ ] Verify all buttons work correctly
- [ ] Verify all text fields are functional
- [ ] Verify dialogs appear correctly
- [ ] Verify navigation works smoothly
- [ ] Check for any layout issues

## Notes

- All screens using `BaseScreen` or `BaseScreenWithAppBar` are already partially updated
- NavigationService is already platform-aware
- Some screens may need custom iOS-specific layouts for better UX
- Consider using CupertinoListTile for iOS list items instead of ListTile

