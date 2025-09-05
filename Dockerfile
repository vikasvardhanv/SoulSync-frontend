# Multi-stage Docker build for SoulSync Frontend
# Stage 1: Build the application
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY . .

# Build arguments for environment
ARG NODE_ENV=production
ARG VITE_API_URL=https://api.soulsync.solutions/api
ARG VITE_APP_URL=https://soulsync.solutions
ARG VITE_ENVIRONMENT=production

# Set environment variables
ENV NODE_ENV=${NODE_ENV}
ENV VITE_API_URL=${VITE_API_URL}
ENV VITE_APP_URL=${VITE_APP_URL}
ENV VITE_ENVIRONMENT=${VITE_ENVIRONMENT}

# Build the application
RUN npm run build

# Stage 2: Serve the application with nginx
FROM nginx:alpine AS production

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy built application from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy additional static files
COPY --from=builder /app/public/*.txt /usr/share/nginx/html/
COPY --from=builder /app/public/*.xml /usr/share/nginx/html/
COPY --from=builder /app/public/.htaccess /usr/share/nginx/html/

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Create a non-root user for nginx
RUN addgroup -g 1001 -S nodejs && \
    adduser -S soulsync -u 1001 -G nodejs

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]