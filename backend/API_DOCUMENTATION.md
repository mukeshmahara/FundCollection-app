# API Documentation

This project includes comprehensive API documentation using Swagger UI.

## Accessing the API Documentation

Once the Rails server is running, you can access the interactive API documentation at:

```
http://localhost:3000/api-docs
```

## Available API Endpoints

The API documentation includes the following endpoint categories:

### 🔐 Authentication
- `POST /users/sign_up` - Register a new user account
- `POST /users/sign_in` - User login (returns JWT token)
- `DELETE /users/sign_out` - User logout

### 🎯 Campaigns
- `GET /api/v1/campaigns` - List all campaigns
- `POST /api/v1/campaigns` - Create a new campaign
- `GET /api/v1/campaigns/{id}` - Get campaign details
- `PUT /api/v1/campaigns/{id}` - Update a campaign
- `DELETE /api/v1/campaigns/{id}` - Delete a campaign
- `POST /api/v1/campaigns/{id}/donate` - Donate to a campaign
- `GET /api/v1/campaigns/{id}/donations` - List campaign donations

### 💰 Donations
- `GET /api/v1/donations` - List user's donations
- `POST /api/v1/donations` - Create a donation
- `GET /api/v1/donations/{id}` - Get donation details

### 💳 Payments
- `POST /api/v1/payments/create_payment_intent` - Create Stripe payment intent
- `POST /api/v1/payments/confirm` - Confirm payment

### 👤 Users
- `GET /api/v1/users/{id}` - Get user profile
- `PUT /api/v1/users/{id}` - Update user profile

## Authentication

Most API endpoints require authentication using JWT (JSON Web Token). After logging in via `/users/sign_in`, you'll receive a JWT token in the `Authorization` header of the response.

Include this token in subsequent API requests:

```
Authorization: Bearer your-jwt-token-here
```

## Data Models

The API uses the following main data models:

- **User**: User account information
- **Campaign**: Fundraising campaigns
- **Donation**: Individual donations to campaigns
- **Transaction**: Payment transaction records

## Response Format

All API responses follow a consistent JSON format with proper HTTP status codes:

- `200` - Success
- `201` - Created
- `204` - No Content (for successful deletions)
- `401` - Unauthorized
- `404` - Not Found
- `422` - Unprocessable Entity (validation errors)

## Testing the API

You can test the API endpoints directly from the Swagger UI interface:

1. Visit `http://localhost:3000/api-docs`
2. Click on any endpoint to expand it
3. Click "Try it out"
4. Fill in the required parameters
5. Click "Execute" to test the endpoint

For authenticated endpoints, first login via `/users/sign_in` to get a JWT token, then use the "Authorize" button in the Swagger UI to add the token.

## Development

To regenerate the API documentation:

1. Update the `swagger/v1/swagger.yaml` file
2. Restart the Rails server
3. The changes will be reflected at `/api-docs`

The Swagger documentation is served directly from the YAML file located at `swagger/v1/swagger.yaml`.
