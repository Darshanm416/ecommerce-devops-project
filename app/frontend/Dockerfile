# Stage 1: Build the React app
FROM node:18 AS build

WORKDIR /app

COPY package.json ./
COPY package-lock.json ./
RUN npm install

COPY . ./
RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:stable-alpine

# Copy build to nginx public folder
COPY --from=build /app/build /usr/share/nginx/html

# Remove default Nginx config and copy our own
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
