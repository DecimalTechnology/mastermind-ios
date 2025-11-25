# Discount Coupon Feature

This feature provides a complete discount coupon system for the Oxygen Mastermind app.

## Features

- **Coupon Listing**: View all available discount coupons with search and filter functionality
- **Coupon Details**: Detailed view of individual coupons with QR code display
- **Search & Filter**: Search by restaurant name or description, filter by discount percentage
- **QR Code Display**: Show QR codes for easy redemption at restaurants
- **Use Coupons**: Mark coupons as used with API integration

## Files Created

### Models
- `lib/models/discount_coupon_model.dart` - Data models for discount coupons

### Repository
- `lib/repository/discount_coupon_repository.dart` - API service for fetching coupon data

### Provider
- `lib/providers/discount_coupon_provider.dart` - State management for coupon data

### Screens
- `lib/screens/discount_coupon/discount_coupon_screen.dart` - Main coupon listing screen
- `lib/screens/discount_coupon/coupon_detail_screen.dart` - Individual coupon details

### Widgets
- `lib/screens/discount_coupon/widgets/coupon_card.dart` - Reusable coupon card component
- `lib/screens/discount_coupon/widgets/coupon_search_bar.dart` - Search functionality
- `lib/screens/discount_coupon/widgets/coupon_filter_chips.dart` - Filter options
- `lib/screens/discount_coupon/widgets/qr_code_dialog.dart` - QR code display dialog

## Navigation

The discount coupon screen is accessible via the route `/discount-coupons`. You can navigate to it using:

```dart
Navigator.pushNamed(context, '/discount-coupons');
```

## API Integration

The feature expects the following API endpoint structure:

```json
{
  "success": true,
  "data": [
    {
      "_id": "68dcc9e79c29fd06709d5dd7",
      "restaurantName": "kfc",
      "discountPercentage": 10,
      "description": "sample description",
      "isActive": true,
      "image": "https://...",
      "createdAt": "2025-10-01T06:27:51.688Z",
      "updatedAt": "2025-10-01T06:27:52.080Z",
      "__v": 0,
      "QRCode": "https://..."
    }
  ]
}
```

## Usage

1. The provider is automatically initialized in `main.dart`
2. The screen loads coupons on initialization
3. Users can search, filter, and view coupon details
4. QR codes can be displayed for easy redemption
5. Coupons can be marked as used through the API

## Customization

- Colors and styling can be modified in the widget files
- API endpoints can be updated in the repository
- Additional filters can be added to the filter chips widget
- Search functionality can be extended in the search bar widget
