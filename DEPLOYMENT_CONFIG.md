# Deployment Configuration Guide

## Backend URL Management

All frontend applications (iOS, React) are configured to fetch API endpoints from **environment variables only**. This means backend URL changes require **zero code changes**.

### iOS/Flutter App

**Current Backend:** `https://soulsync-backend-k2bt.onrender.com/api`

**To build with a different backend:**
```bash
cd soulsync-frontend/soulsync_app

# Build with custom backend URL
flutter build ios --dart-define=API_BASE_URL=https://your-new-backend.com/api

# Build with current backend (default)
flutter build ios
```

**Configuration File:** `lib/config/api_config.dart`
- Reads from Dart environment variable `API_BASE_URL`
- Falls back to default: `https://soulsync-backend-k2bt.onrender.com/api`
- **No hardcoded URLs in code** ✅

### React Frontend

**Current Backend:** `https://soulsync-backend-k2bt.onrender.com/api`

**Environment Files:**
- `.env.example` - Template with current backend URL
- `.env.production` - Production environment (used in builds)

**To change backend:**
1. Update `VITE_API_URL` in `.env.production`
2. Rebuild: `npm run build`

**Configuration File:** `src/services/api.ts`
- Reads from `VITE_API_URL` environment variable
- Falls back to default: `https://soulsync-backend-k2bt.onrender.com/api`
- **No hardcoded URLs in code** ✅

### Backend Deployment Changes Workflow

When you deploy backend to a new URL:

1. **Update Render URL** (if using Render):
   - Take note of new URL (e.g., `https://new-backend.onrender.com`)

2. **Update React Frontend:**
   ```bash
   # In soulsync-frontend/.env.production
   VITE_API_URL=https://new-backend.onrender.com
   
   # Rebuild and deploy
   npm run build
   ```

3. **Update iOS App:**
   ```bash
   cd soulsync-app
   flutter build ios --dart-define=API_BASE_URL=https://new-backend.onrender.com
   ```

4. **No code changes needed in either app** ✅

## Environment Variable Summary

| App | Variable | File | Default |
|-----|----------|------|---------|
| iOS/Flutter | `API_BASE_URL` | `lib/config/api_config.dart` | `https://soulsync-backend-k2bt.onrender.com/api` |
| React | `VITE_API_URL` | `src/services/api.ts` | `https://soulsync-backend-k2bt.onrender.com/api` |

## Quick Commands

### iOS Build with Different Backend
```bash
flutter build ios --dart-define=API_BASE_URL=https://your-backend.com/api
```

### React Development with Different Backend
```bash
VITE_API_URL=https://your-backend.com/api npm run dev
```

### React Production Build with Different Backend
```bash
VITE_API_URL=https://your-backend.com/api npm run build
```
