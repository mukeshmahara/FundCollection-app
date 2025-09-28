# FundCollection App

A modern crowdfunding platform built with Rails 8 API backend and Next.js frontend with Stripe payment integration.

## Tech Stack

### Backend (Rails 8 API)
- Ruby on Rails 8.0
- PostgreSQL database
- Devise JWT for authentication
- Stripe for payments
- Active Storage for file uploads
- Action Text for rich text content

### Frontend (Next.js + React)
- Next.js 14 with App Router
- TypeScript
- Tailwind CSS
- Stripe.js for payment processing
- React Query for API management
- React Hook Form for form handling

## Features

- **User Authentication**: JWT-based authentication with admin/donor roles
- **Campaign Management**: Create, edit, and manage fundraising campaigns
- **Donation Processing**: Secure payment processing via Stripe
- **Admin Dashboard**: Administrative interface for campaign and user management
- **Responsive Design**: Mobile-first responsive design with Tailwind CSS
- **Real-time Updates**: Live campaign progress tracking

## Project Structure

```
fundcollection-app/
├── backend/                 # Rails 8 API
│   ├── app/
│   │   ├── controllers/     # API controllers
│   │   ├── models/          # Data models
│   │   └── serializers/     # JSON serializers
│   ├── config/              # Rails configuration
│   └── db/                  # Database migrations
└── frontend/                # Next.js app
    ├── app/                 # Next.js App Router
    ├── components/          # React components
    ├── lib/                 # Utilities and API
    └── styles/              # CSS styles
```

## Setup Instructions

### Prerequisites
- Ruby 3.2+
- Node.js 18+
- PostgreSQL
- Stripe account

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Setup environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Start the Rails server:**
   ```bash
   rails server -p 3001
   ```

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Setup environment variables:**
   ```bash
   cp .env.local.example .env.local
   # Add your Stripe publishable key and API URL
   ```

4. **Start the development server:**
   ```bash
   npm run dev
   ```

### Environment Variables

#### Backend (.env)
```env
DB_USERNAME=postgres
DB_PASSWORD=password
DB_HOST=localhost
DEVISE_JWT_SECRET_KEY=your_jwt_secret
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
SECRET_KEY_BASE=your_rails_secret_key
```

#### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
```

## Database Models

### User
- Authentication with Devise JWT
- Roles: donor, admin
- Profile information and avatar

### Campaign
- Title, description, goal amount, deadline
- Status tracking (draft, active, completed, cancelled)
- Image attachments
- Rich text descriptions

### Donation
- Amount and anonymous flag
- Status tracking (pending, successful, failed, refunded)
- Links to user and campaign

### Transaction
- Stripe payment intent tracking
- Payment status and metadata

## API Endpoints

### Authentication
- `POST /users/sign_in` - Login
- `POST /users/sign_up` - Register
- `DELETE /users/sign_out` - Logout

### Campaigns
- `GET /api/v1/campaigns` - List campaigns
- `POST /api/v1/campaigns` - Create campaign
- `GET /api/v1/campaigns/:id` - Get campaign
- `PUT /api/v1/campaigns/:id` - Update campaign
- `POST /api/v1/campaigns/:id/donate` - Create donation

### Donations
- `GET /api/v1/donations` - User donations
- `POST /api/v1/donations` - Create donation

### Payments
- `POST /api/v1/payments/create_payment_intent` - Create Stripe payment
- `POST /api/v1/payments/confirm` - Confirm payment
- `POST /api/v1/webhooks/stripe` - Stripe webhooks

## Stripe Integration

1. **Setup Stripe account** and get API keys
2. **Configure webhook endpoint** in Stripe dashboard:
   - URL: `https://yourdomain.com/api/v1/webhooks/stripe`
   - Events: `payment_intent.succeeded`, `payment_intent.payment_failed`
3. **Add webhook secret** to environment variables

## Deployment

### Backend (Heroku)
1. Create Heroku app
2. Add PostgreSQL addon
3. Set environment variables
4. Deploy with Git

### Frontend (Vercel)
1. Connect GitHub repository
2. Set environment variables
3. Deploy automatically on push

## Development

### Running Tests
```bash
# Backend
cd backend
bundle exec rspec

# Frontend
cd frontend
npm test
```

### Code Quality
```bash
# Backend
bundle exec rubocop

# Frontend
npm run lint
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.
