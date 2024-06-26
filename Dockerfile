# Stage 1: Build the MkDocs documentation
FROM squidfunk/mkdocs-material:9.5.15 as builder

# Set the working directory
WORKDIR /docs

# Install MkDocs plugins
RUN pip install --no-cache-dir mkdocs-render-swagger-plugin

# Copy the MkDocs project files into the container
COPY ./fonts ./.cache/plugin/social/fonts/Roboto
COPY . .

# Build the MkDocs documentation
RUN mkdocs build

# Stage 2: Serve the documentation with Nginx
FROM nginx:alpine

# Copy the custom Nginx config file into the container
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built documentation from the builder stage to the Nginx serve directory
COPY --from=builder /docs/site /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx and serve the documentation
CMD ["nginx", "-g", "daemon off;"]
