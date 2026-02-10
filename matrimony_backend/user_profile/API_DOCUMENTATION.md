# User Profile API Documentation

## Overview
The User Profile app provides endpoints for managing user profile information in the matrimony application. Each user has a OneToOne relationship with their profile.

## Base URL
```
/api/profiles/
```

## Authentication
All endpoints require authentication using Token or Bearer authentication.

## Endpoints

### 1. Get Current User's Profile
**GET** `/api/profiles/me/`

Returns the authenticated user's profile.

**Response (200 OK):**
```json
{
    "user": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "photo": "https://s3.amazonaws.com/bucket/profile_photos/photo.jpg",
    "height": 175.50,
    "weight": 70.00,
    "address_line1": "123 Main St",
    "address_line2": "Apt 4B",
    "city": "New York",
    "state": "NY",
    "country": "USA",
    "postal_code": "10001",
    "father_name": "Robert Doe",
    "mother_name": "Jane Doe",
    "siblings": 2,
    "family_type": "nuclear",
    "family_status": "middle_class",
    "bio": "Looking for a life partner...",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
}
```

**Response (404 Not Found):**
```json
{
    "detail": "Profile not found"
}
```

---

### 2. Update Current User's Profile
**POST/PUT/PATCH** `/api/profiles/update_me/`

Creates or updates the authenticated user's profile.

**Request Body:**
```json
{
    "photo": "base64_encoded_image_or_file",
    "height": 175.50,
    "weight": 70.00,
    "address_line1": "123 Main St",
    "address_line2": "Apt 4B",
    "city": "New York",
    "state": "NY",
    "country": "USA",
    "postal_code": "10001",
    "father_name": "Robert Doe",
    "mother_name": "Jane Doe",
    "siblings": 2,
    "family_type": "nuclear",
    "family_status": "middle_class",
    "bio": "Looking for a life partner..."
}
```

**Notes:**
- All fields are optional
- Use PATCH for partial updates
- Use POST or PUT for full updates

**Response (200 OK):**
Returns the updated profile (same format as GET /me/)

---

### 3. List All Profiles (Admin Only)
**GET** `/api/profiles/`

Lists all user profiles. Regular users only see their own profile.

**Query Parameters:**
- `page`: Page number (pagination)
- `page_size`: Number of items per page

**Response (200 OK):**
```json
{
    "count": 100,
    "next": "http://api.example.com/api/profiles/?page=2",
    "previous": null,
    "results": [
        {
            "user": 1,
            "username": "john_doe",
            "email": "john@example.com",
            ...
        }
    ]
}
```

---

### 4. Get Specific Profile (Admin Only)
**GET** `/api/profiles/{user_id}/`

Retrieves a specific user's profile by user ID.

**Response (200 OK):**
Returns profile data (same format as GET /me/)

---

### 5. Update Specific Profile (Admin Only)
**PUT/PATCH** `/api/profiles/{user_id}/`

Updates a specific user's profile.

**Request Body:**
Same as update_me endpoint

**Response (200 OK):**
Returns updated profile data

---

### 6. Delete Profile (Admin Only)
**DELETE** `/api/profiles/{user_id}/`

Deletes a specific user's profile.

**Response (204 No Content)**

---

## Field Descriptions

### Photo
- **Type:** ImageField
- **Upload to:** `profile_photos/`
- **Optional:** Yes
- **Description:** User's profile photo

### Height
- **Type:** Decimal (5 digits, 2 decimal places)
- **Unit:** Centimeters
- **Optional:** Yes
- **Example:** 175.50

### Weight
- **Type:** Decimal (5 digits, 2 decimal places)
- **Unit:** Kilograms
- **Optional:** Yes
- **Example:** 70.00

### Address Fields
- **address_line1:** String (max 255 chars)
- **address_line2:** String (max 255 chars)
- **city:** String (max 100 chars)
- **state:** String (max 100 chars)
- **country:** String (max 100 chars)
- **postal_code:** String (max 20 chars)

### Family Information
- **father_name:** String (max 255 chars)
- **mother_name:** String (max 255 chars)
- **siblings:** Integer (number of siblings)
- **family_type:** Choice field
  - `nuclear`: Nuclear family
  - `joint`: Joint family
- **family_status:** Choice field
  - `middle_class`: Middle Class
  - `upper_middle_class`: Upper Middle Class
  - `rich`: Rich

### Bio
- **Type:** TextField
- **Description:** Personal bio/description
- **Optional:** Yes

---

## Example Usage

### Create/Update Profile (cURL)
```bash
curl -X POST https://api.matrimony.com/api/profiles/update_me/ \
  -H "Authorization: Token YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "height": 175.50,
    "weight": 70.00,
    "city": "New York",
    "state": "NY",
    "country": "USA",
    "bio": "Looking for a life partner..."
  }'
```

### Get Current User Profile (cURL)
```bash
curl -X GET https://api.matrimony.com/api/profiles/me/ \
  -H "Authorization: Token YOUR_TOKEN_HERE"
```

---

## Error Responses

### 401 Unauthorized
```json
{
    "detail": "Authentication credentials were not provided."
}
```

### 403 Forbidden
```json
{
    "detail": "You do not have permission to perform this action."
}
```

### 404 Not Found
```json
{
    "detail": "Profile not found"
}
```

### 400 Bad Request
```json
{
    "field_name": [
        "Error message for this field"
    ]
}
```

---

## Notes

1. **OneToOne Relationship:** Each user can have only one profile
2. **Auto-creation:** Profile is automatically created when using `update_me` endpoint
3. **Permissions:** Regular users can only access their own profile
4. **Admin Access:** Staff users can view and modify all profiles
5. **File Uploads:** Profile photos are stored in S3 (configured in settings)
6. **Validation:** All fields have appropriate validation based on their types
