# SoulSync Frontend

A production-ready React frontend for the SoulSync AI-powered dating platform.

## 🚀 Features

- **Modern React Architecture**: Built with React 18, TypeScript, and Vite
- **AI-Powered Matching**: Sophisticated compatibility analysis and intelligent matchmaking
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Real-time Messaging**: Live chat with potential matches
- **Secure Authentication**: JWT-based authentication with refresh tokens
- **Payment Integration**: PayPal and cryptocurrency payment support
- **Production Ready**: Optimized builds with SEO, performance monitoring, and security headers

## 🛠 Tech Stack

- **Frontend**: React 18, TypeScript, Vite
- **Styling**: Tailwind CSS, Framer Motion
- **State Management**: Zustand
- **Forms**: React Hook Form with Zod validation
- **HTTP Client**: Axios
- **Routing**: React Router DOM
- **UI Components**: Lucide React icons
- **Notifications**: React Hot Toast

## 🏃‍♂️ Quick Start

### Prerequisites

- Node.js >= 18.0.0
- npm >= 8.0.0

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/soulsync-frontend.git
   cd soulsync-frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env.local
   ```
   
   Update `.env.local` with your configuration:
   ```env
   VITE_API_URL=https://api.soulsync.solutions/api
   VITE_PAYPAL_CLIENT_ID=your_paypal_client_id
   VITE_ENVIRONMENT=development
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

   The application will be available at `http://localhost:5173`

## 📦 Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run build:production` - Build with production environment
- `npm run build:staging` - Build with staging environment
- `npm run preview` - Preview production build locally
- `npm run lint` - Run ESLint
- `npm run type-check` - Run TypeScript type checking

## 🌍 Deployment

### Static Hosting (Netlify/Vercel)

1. **Build the application**
   ```bash
   npm run build:production
   ```

2. **Deploy to Netlify**
   ```bash
   npm run deploy:netlify
   ```

3. **Deploy to Vercel**
   ```bash
   npm run deploy:vercel
   ```

### Docker Deployment

1. **Build production image**
   ```bash
   docker build -t soulsync-frontend .
   ```

2. **Run container**
   ```bash
   docker run -p 80:80 soulsync-frontend
   ```

3. **Or use Docker Compose**
   ```bash
   docker-compose up -d
   ```

### Traditional Web Server

1. **Build the application**
   ```bash
   npm run build:production
   ```

2. **Upload the `dist` folder** to your web server
3. **Configure your web server** to serve the SPA (see `.htaccess` for Apache configuration)

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `VITE_API_URL` | Backend API URL | `https://api.soulsync.solutions/api` |
| `VITE_APP_URL` | Frontend URL | `https://soulsync.solutions` |
| `VITE_ENVIRONMENT` | Environment (development/staging/production) | `production` |
| `VITE_PAYPAL_CLIENT_ID` | PayPal client ID | - |
| `VITE_DEBUG` | Enable debug mode | `false` |

### Domain Configuration

The application is configured for:
- **Production**: `soulsync.solutions`
- **Staging**: `staging.soulsync.solutions`
- **API**: `api.soulsync.solutions`

## 🏗 Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── ui/             # Basic UI components
│   └── auth/           # Authentication components
├── context/            # React context providers
├── services/           # API services and HTTP client
├── stores/             # Zustand state management
├── utils/              # Utility functions
└── assets/             # Static assets
```

## 🔒 Security Features

- Content Security Policy (CSP) headers
- XSS protection
- CSRF protection
- Secure cookie handling
- Input validation and sanitization
- Rate limiting on API calls

## 🚀 Performance Optimizations

- Code splitting and lazy loading
- Bundle size optimization
- Image optimization
- Browser caching strategies
- Gzip compression
- CDN integration ready

## 📱 PWA Support

The application is configured as a Progressive Web App with:
- Web app manifest
- Service worker (optional)
- Offline support (basic)
- Install prompts

## 🧪 Testing

```bash
# Run unit tests
npm test

# Run integration tests  
npm run test:integration

# Generate coverage report
npm run test:coverage
```

## 🔍 SEO & Analytics

- Complete meta tags for social media
- Structured data (JSON-LD)
- Sitemap generation
- Google Analytics ready
- Open Graph and Twitter Cards

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is private and proprietary to SoulSync Inc.

## 🆘 Support

For support and questions:
- Email: support@soulsync.solutions
- Documentation: [docs.soulsync.solutions](https://docs.soulsync.solutions)
- Issues: [GitHub Issues](https://github.com/yourusername/soulsync-frontend/issues)

## 🏆 Built With Love

Created with ❤️ by the SoulSync team to help people find meaningful connections through the power of AI.

---

**Live Demo**: [https://soulsync.solutions](https://soulsync.solutions)
**Backend Repository**: [soulsync-backend](https://github.com/yourusername/soulsync-backend)