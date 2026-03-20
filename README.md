# SoulSync Frontend

A modern, spiritual connection and dating platform frontend built with React, TypeScript, and Tailwind CSS.

## 🚀 Features

- **Modern UI/UX**: Beautiful, responsive design with Tailwind CSS
- **Authentication**: Complete signup/login flow with email verification
- **User Profiles**: Rich user profiles with photo uploads
- **Personality Quizzes**: Interactive quizzes for better matching
- **Smart Matching**: AI-powered compatibility matching
- **Real-time Chat**: Instant messaging with matched users
- **Payment Integration**: Crypto and card payment support
- **Subscription Plans**: Premium and VIP membership tiers
- **Notifications**: Real-time notifications for matches and messages
- **Location-based**: Find matches near you
- **Responsive Design**: Works on desktop, tablet, and mobile

## 📋 Prerequisites

- Node.js >= 18.0.0
- npm >= 8.0.0

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/soulsync-frontend.git
   cd soulsync-frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   
   Create a `.env` file in the root directory:
   ```env
   # API Configuration
   VITE_API_URL=https://your-backend-api.com/api
   
   # Optional: PayPal Configuration
   VITE_PAYPAL_CLIENT_ID=your_paypal_client_id
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

## 🚀 Running the Application

### Development Mode
```bash
npm run dev
```
The app will be available at `http://localhost:5173`

### Production Build
```bash
npm run build
```

### Preview Production Build
```bash
npm run preview
```

### Type Checking
```bash
npm run type-check
```

## 🏗️ Project Structure

```
soulsync-frontend/
├── public/                    # Static assets
├── src/
│   ├── components/            # React components
│   │   ├── auth/              # Authentication components
│   │   │   ├── LoginForm.tsx
│   │   │   └── SignupForm.tsx
│   │   ├── Dashboard.tsx      # Main dashboard
│   │   ├── PersonalityQuiz.tsx
│   │   ├── CompatibilityQuiz.tsx
│   │   ├── AIMatching.tsx
│   │   ├── MatchReveal.tsx
│   │   ├── ChatInterface.tsx
│   │   ├── ProfileEdit.tsx
│   │   ├── Settings.tsx
│   │   ├── PaymentModal.tsx
│   │   └── ...
│   ├── context/
│   │   └── AppContext.tsx     # Global app context
│   ├── stores/
│   │   └── authStore.ts       # Zustand auth store
│   ├── services/
│   │   ├── api.ts             # API service layer
│   │   └── aiMatching.ts      # AI matching service
│   ├── data/
│   │   └── questionBank.ts    # Question data
│   ├── utils/                 # Utility functions
│   ├── App.tsx                # Main app component
│   ├── main.tsx               # App entry point
│   └── index.css              # Global styles
├── .env                       # Environment variables
├── index.html                 # HTML template
├── package.json               # Dependencies
├── tailwind.config.js         # Tailwind configuration
├── tsconfig.json              # TypeScript configuration
├── vite.config.ts             # Vite configuration
└── vercel.json                # Vercel deployment config
```

## 🎨 Tech Stack

- **React 18**: Modern React with hooks
- **TypeScript**: Type-safe development
- **Vite**: Fast build tool and dev server
- **Tailwind CSS**: Utility-first CSS framework
- **Framer Motion**: Smooth animations
- **Zustand**: Lightweight state management
- **React Router**: Client-side routing
- **React Hook Form**: Form validation
- **Axios**: HTTP client
- **Zod**: Schema validation
- **React Hot Toast**: Toast notifications
- **Lucide React**: Beautiful icons

## 🔐 Authentication Flow

1. **Sign Up**: User creates account with email, password, and basic info
2. **Email Verification**: Optional email verification for security
3. **Login**: User logs in with email and password
4. **JWT Tokens**: Access and refresh tokens for secure API calls
5. **Protected Routes**: Automatic redirect for unauthenticated users
6. **Token Refresh**: Automatic token refresh on expiry

## 📱 Key Components

### Dashboard
- View potential matches
- See match notifications
- Access messaging
- Manage profile and settings

### Personality Quiz
- Interactive personality assessment
- Multiple question categories
- Progress tracking
- Results visualization

### Matching System
- AI-powered compatibility scores
- Location-based matching
- Filter by preferences
- Daily match recommendations

### Chat Interface
- Real-time messaging
- Message history
- Typing indicators
- Read receipts

### Profile Management
- Photo uploads (up to 6 photos)
- Bio and interests
- Location settings
- Privacy controls

### Payment & Subscriptions
- Crypto payment support (NOWPayments)
- Card payment support (PayPal)
- Premium and VIP tiers
- Subscription management

## 🚀 Deployment

### GCP Deployment (Recommended)

See `gcp-deployment.md` for detailed GCP deployment instructions.

### Vercel Deployment

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Deploy**
   ```bash
   npm run deploy:vercel
   ```

### Netlify Deployment

1. **Build the project**
   ```bash
   npm run build
   ```

2. **Deploy**
   ```bash
   npm run deploy:netlify
   ```

### Docker Deployment

```bash
docker build -t soulsync-frontend .
docker run -p 80:80 soulsync-frontend
```

## 🔧 Configuration

### Vite Configuration

The `vite.config.ts` file includes:
- React plugin
- Path aliases
- Build optimizations
- Code splitting
- Console log removal in production
- Terser minification

### Tailwind Configuration

The `tailwind.config.js` includes:
- Custom color palette
- Extended utilities
- Responsive breakpoints
- Animation configurations

## 🎯 Best Practices

1. **Component Organization**: Components are organized by feature
2. **Type Safety**: Full TypeScript coverage
3. **Code Splitting**: Automatic code splitting for better performance
4. **Lazy Loading**: Lazy loading for heavy components (e.g., PaymentModal)
5. **Error Boundaries**: Global error handling
6. **Form Validation**: Zod schemas for form validation
7. **API Abstraction**: Centralized API layer
8. **State Management**: Zustand for global state
9. **Responsive Design**: Mobile-first approach
10. **Accessibility**: ARIA labels and keyboard navigation

## 📊 Performance Optimizations

- **Code Splitting**: Manual chunks for vendor libraries
- **Tree Shaking**: Remove unused code
- **Minification**: Terser minification
- **Image Optimization**: Optimized image loading
- **Lazy Loading**: Route-based code splitting
- **Bundle Analysis**: Available via `npm run analyze`

## 🧪 Testing

```bash
# Type checking
npm run type-check

# Linting
npm run lint
```

## 📝 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `VITE_API_URL` | Backend API URL | Yes |
| `VITE_PAYPAL_CLIENT_ID` | PayPal client ID | No |

## 🎨 Styling Guidelines

- Use Tailwind utility classes
- Follow mobile-first approach
- Maintain consistent spacing
- Use custom color palette from theme
- Implement smooth animations with Framer Motion

## 🔄 State Management

### Zustand Auth Store
- User authentication state
- Sign up, sign in, sign out
- Profile updates
- Token management
- Email verification

### App Context
- Global app state
- Quiz progress
- Match data
- User preferences

## 🌐 API Integration

The app communicates with the backend through:

- `authAPI`: Authentication endpoints
- `usersAPI`: User management
- `matchesAPI`: Matching system
- `messagesAPI`: Chat functionality
- `paymentsAPI`: Payment processing
- `subscriptionsAPI`: Subscription management
- `questionsAPI`: Quiz questions
- `imagesAPI`: Image uploads
- `locationsAPI`: Location data

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary and confidential.

## 👥 Support

For support, email support@soulsync.solutions or open an issue in the repository.

## 🔄 Changelog

### Version 1.0.0 (Current)
- Initial release
- Complete authentication flow
- Personality and compatibility quizzes
- AI-powered matching
- Real-time chat
- Payment integration
- Subscription management
- Profile and settings
- Responsive design
- Performance optimizations

---

Made with ❤️ by the SoulSync Team



### Your algorithm (question-based, robust version)

  Use a two-stage scorer:

  1. Hard filters

  - Deal-breakers, location radius, age bounds, relationship intent, orientation, language.

  2. Compatibility score

  - S = 0.45*Values + 0.20*Lifestyle + 0.15*Communication + 0.10*Intent + 0.10*Reliability
  - Values/Lifestyle/Communication come from questionnaire similarity (with per-question importance weights set
    by user).
  - Reliability includes behavior quality signals (response consistency, cancellation/ghosting patterns, report
    history weightings).

  3. Mutuality

  - Final match score uses reciprocal score (not one-way attraction only).

  4. Safety re-rank

  - Down-rank or block candidates above risk threshold.

  5. Learning loop

  - Use feedback from likes/skips/replies/date outcomes to update weights, but never override user deal-breakers.
