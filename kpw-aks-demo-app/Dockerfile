# FROM node:lts-alpine
# ENV NODE_ENV=production
# WORKDIR /usr/src/app
# COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
# RUN npm install --production --silent && mv node_modules ../
# COPY . .
# EXPOSE 3000
# RUN chown -R node /usr/src/app
# USER node
# CMD ["npm", "start"]

# Stage 1: Build
FROM node:24-alpine AS builder

WORKDIR /usr/src/app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./
RUN npm ci  # 'npm ci' is faster and more reliable for CI/CD than 'npm i'

COPY . .

# Run build (Typescript should be a devDependency, no need to install -g)
RUN npm run build 

# Stage 2: Final Production Image
FROM nginx:stable-alpine

# Remove default Nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy ONLY the static build files from the builder stage
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html

# Optional: Copy a custom nginx config if you have client-side routing (SPAs)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]