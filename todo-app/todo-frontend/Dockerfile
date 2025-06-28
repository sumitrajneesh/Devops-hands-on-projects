# Stage 1: Build the React application
FROM node:20-alpine AS builder 

WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package.json ./
COPY package-lock.json ./

# Install dependencies
RUN npm install --silent

# Copy the rest of the application code
COPY . ./

# Build the React app for production
RUN npm run build

# Stage 2: Serve the React application with Nginx
FROM nginx:stable-alpine 

WORKDIR /usr/share/nginx/html

# Copy the built React app from the builder stage
COPY --from=builder /app/build .

# Copy the custom Nginx configuration file
# IMPORTANT: This copies 'nginx.conf' from the same directory as this Dockerfile
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 (where Nginx will listen)
EXPOSE 80

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]