# Backend API Setup for Discount Coupons

## Current Status
The discount coupon feature is currently using **mock data** for testing the UI. To make it fully functional, you need to create the backend API endpoint.

## Required API Endpoint

### GET `/v1/discounts`
**Description:** Retrieve all available discount coupons

**Headers:**
```
Content-Type: application/json
access-token: <user_auth_token>
```

**Response Format:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "68dcc9e79c29fd06709d5dd7",
      "restaurantName": "KFC",
      "discountPercentage": 15,
      "description": "Get 15% off on your next meal at KFC. Valid on orders above ₹299.",
      "isActive": true,
      "image": "https://your-bucket.s3.amazonaws.com/images/kfc-logo.png",
      "createdAt": "2025-01-15T06:27:51.688Z",
      "updatedAt": "2025-01-15T06:27:52.080Z",
      "__v": 0,
      "QRCode": "https://your-bucket.s3.amazonaws.com/images/kfc-qr.png"
    }
  ]
}
```

### POST `/v1/discounts/use`
**Description:** Mark a coupon as used

**Request Body:**
```json
{
  "couponId": "coupon_id_here"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Coupon used successfully"
}
```

## Database Schema

### DiscountCoupons Collection
```javascript
{
  _id: ObjectId,
  restaurantName: String,
  discountPercentage: Number,
  description: String,
  isActive: Boolean,
  image: String, // URL to restaurant logo
  QRCode: String, // URL to QR code image
  createdAt: Date,
  updatedAt: Date,
  __v: Number
}
```

## Sample Data
```javascript
// Insert sample data for testing
db.discountcoupons.insertMany([
  {
    restaurantName: "KFC",
    discountPercentage: 15,
    description: "Get 15% off on your next meal at KFC. Valid on orders above ₹299.",
    isActive: true,
    image: "https://your-bucket.s3.amazonaws.com/images/kfc-logo.png",
    QRCode: "https://your-bucket.s3.amazonaws.com/images/kfc-qr.png",
    createdAt: new Date(),
    updatedAt: new Date(),
    __v: 0
  },
  {
    restaurantName: "McDonald's",
    discountPercentage: 20,
    description: "Enjoy 20% discount on McDonald's burgers and meals. Minimum order ₹199.",
    isActive: true,
    image: "https://your-bucket.s3.amazonaws.com/images/mcdonalds-logo.png",
    QRCode: "https://your-bucket.s3.amazonaws.com/images/mcdonalds-qr.png",
    createdAt: new Date(),
    updatedAt: new Date(),
    __v: 0
  }
]);
```

## Backend Implementation (Node.js/Express Example)

```javascript
// routes/discountCoupons.js
const express = require('express');
const router = express.Router();
const DiscountCoupon = require('../models/DiscountCoupon');

// GET /v1/discount-coupons
router.get('/', async (req, res) => {
  try {
    const coupons = await DiscountCoupon.find({ isActive: true });
    res.json({
      success: true,
      data: coupons
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch discount coupons'
    });
  }
});

// GET /v1/discount-coupons/:id
router.get('/:id', async (req, res) => {
  try {
    const coupon = await DiscountCoupon.findById(req.params.id);
    if (!coupon) {
      return res.status(404).json({
        success: false,
        message: 'Coupon not found'
      });
    }
    res.json({
      success: true,
      data: coupon
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to fetch coupon details'
    });
  }
});

// POST /v1/discount-coupons/:id/use
router.post('/:id/use', async (req, res) => {
  try {
    const coupon = await DiscountCoupon.findById(req.params.id);
    if (!coupon) {
      return res.status(404).json({
        success: false,
        message: 'Coupon not found'
      });
    }
    
    if (!coupon.isActive) {
      return res.status(400).json({
        success: false,
        message: 'Coupon is not active'
      });
    }
    
    // Here you can add logic to track usage, update user's used coupons, etc.
    
    res.json({
      success: true,
      message: 'Coupon used successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to use coupon'
    });
  }
});

module.exports = router;
```

## Switching from Mock to Real API

Once your backend API is ready:

1. **Remove the mock data call** in `lib/repository/discount_coupon_repository.dart`
2. **Uncomment the real API call** in the `getDiscountCoupons()` method
3. **Test the endpoint** to ensure it returns the expected format

### Code Changes Required:
```dart
// In lib/repository/discount_coupon_repository.dart
// Replace this line:
return _getMockDiscountCoupons();

// With this (uncomment the API call):
final response = await http.get(
  Uri.parse('$baseurl/v1/discount-coupons'),
  headers: {
    'Content-Type': 'application/json',
    'access-token': accessToken,
  },
);
```

## Testing the API

You can test the API using curl or Postman:

```bash
# Get all coupons
curl -X GET "http://175.1.1.95:3000/v1/discounts" \
  -H "Content-Type: application/json" \
  -H "access-token: YOUR_AUTH_TOKEN"

# Use a coupon
curl -X POST "http://175.1.1.95:3000/v1/discounts/use" \
  -H "Content-Type: application/json" \
  -H "access-token: YOUR_AUTH_TOKEN" \
  -d '{"couponId": "68dcc9e79c29fd06709d5dd7"}'
```

## Notes
- Make sure to implement proper authentication middleware
- Add rate limiting for the use coupon endpoint
- Consider adding expiration dates for coupons
- Implement proper error handling and validation
- Add logging for coupon usage analytics
