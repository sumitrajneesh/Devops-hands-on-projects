# Stage 1: Build React application
FROM node:20-alpine AS builder 

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./
RUN npm install --silent

COPY . ./

RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:stable-alpine 

WORKDIR /app

# Copy build artifacts from the builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom Nginx configuration (create this file next)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for Nginx
EXPOSE 80

# Nginx runs as foreground process, otherwise Docker exits
CMD ["nginx", "-g", "daemon off;"]