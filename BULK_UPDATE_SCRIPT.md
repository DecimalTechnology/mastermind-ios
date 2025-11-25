# Bulk Update Script for Remaining Screens

Due to the large number of files, here's a systematic approach to update all remaining screens:

## Files Still Needing Updates:

### Profile Screens
- lib/screens/profile/myProfile_screen.dart
- lib/screens/profile/profile_edit_screen.dart
- lib/screens/profile/profile_settings_screen.dart

### Search & Connection Screens
- lib/screens/Search/search_screen.dart
- lib/screens/Search/search_details_screen.dart
- lib/screens/connection/connectionDetails.dart
- lib/screens/connection/my_connections.dart
- lib/screens/connection/request_sent.dart
- lib/screens/connection/recive_request.dart

### Event Screens
- lib/screens/event/Event_screen.dart
- lib/screens/event/event_details_screen.dart
- lib/screens/event/registered_events_screen.dart

### Testimonial Screens
- lib/screens/testimonial/testimonial_screen.dart
- lib/screens/testimonial/testimonial_listing_screen.dart
- lib/screens/testimonial/ask_testimonial_screen.dart
- lib/screens/testimonial/testimonialDetails/*.dart (4 files)

### Accountability Screens
- lib/screens/Accountability/accountability_page.dart
- lib/screens/Accountability/accountability_detail_page.dart
- lib/screens/create_accountability_page.dart

### Chat Screens
- lib/screens/chat/Chat_Screen.dart
- lib/screens/chat/Chat_page.dart

### Other Screens
- lib/screens/vision_board_screen.dart
- lib/screens/discount_coupon/*.dart (multiple files)
- lib/screens/tips/tip_session_detail_screen.dart

## Standard Update Pattern for Each File:

1. **Add imports:**
```dart
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/platform_utils.dart';
import 'package:master_mind/widgets/platform_button.dart';
import 'package:master_mind/utils/platform_text_field.dart';
```

2. **Replace Scaffold:**
```dart
// OLD:
return Scaffold(...);

// NEW:
return PlatformWidget.scaffold(
  context: context,
  ...
);
```

3. **Replace Buttons:**
```dart
// OLD:
ElevatedButton(...)

// NEW:
PlatformButton(...)
```

4. **Replace TextFields:**
```dart
// OLD:
TextField(...)

// NEW:
PlatformTextField(...)
```

5. **Replace Navigation:**
```dart
// OLD:
Navigator.push(context, MaterialPageRoute(...))

// NEW:
if (PlatformUtils.isIOS) {
  Navigator.push(context, CupertinoPageRoute(...));
} else {
  Navigator.push(context, MaterialPageRoute(...));
}
```

6. **Replace Dialogs:**
```dart
// OLD:
showDialog(...)

// NEW:
PlatformWidget.showPlatformDialog(...)
```

## Quick Find & Replace Patterns:

### Pattern 1: Scaffold
Find: `return Scaffold(`
Replace: `return PlatformWidget.scaffold(\n      context: context,`

### Pattern 2: ElevatedButton
Find: `ElevatedButton(`
Replace: `PlatformButton(`

### Pattern 3: TextField
Find: `TextField(`
Replace: `PlatformTextField(`

### Pattern 4: MaterialPageRoute
Find: `MaterialPageRoute(builder: (context) =>`
Replace: `PlatformUtils.isIOS ? CupertinoPageRoute(builder: (context) => : MaterialPageRoute(builder: (context) =>`

