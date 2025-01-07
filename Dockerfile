# Stage 1: Build Angular app
FROM node:18 AS build

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm config set legacy-peer-deps true
RUN npm install

# Uninstall global Angular CLI version (if any) and install specific version
RUN npm uninstall -g @angular/cli
RUN npm install -g @angular/cli@17

# Copy application source code
COPY . .

# Build the Angular application (default output will be in dist/{project_name})
RUN ng build --configuration production
# Stage 2: Use Nginx to serve the app
FROM nginx:alpine

# Copy the built Angular application from the build stage to Nginx's default directory
# Adjusted path to match the output directory created by Angular
COPY --from=build ./app/dist/elp_app_angular /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx to serve the application
CMD ["nginx", "-g", "daemon off;"]

