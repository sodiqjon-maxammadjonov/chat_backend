# Stage 1: Build stage
FROM dart:stable AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./
RUN dart pub get

# Copy source code
COPY . .

# Compile the application
RUN dart compile exe bin/server.dart -o bin/server

# Stage 2: Runtime stage
FROM dart:stable AS runtime

WORKDIR /app

# Copy the compiled binary
COPY --from=build /app/bin/server ./

# Expose port
EXPOSE 8080

# Set environment variables
ENV PORT=8080

# Run the server
CMD ["./server"]