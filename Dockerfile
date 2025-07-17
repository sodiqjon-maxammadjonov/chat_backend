# 1. Dart bilan build bosqichi
FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . ./
RUN dart compile exe bin/server.dart -o bin/server

# 2. Minimal image
FROM debian:stable-slim

# Foydali utilitalarni o'rnatamiz
RUN apt-get update && apt-get install -y \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/bin/server /app/bin/server

COPY .env .env

ENTRYPOINT ["sh", "-c", "export $(cat .env | grep -v '^#' | xargs) && /app/bin/server"]
