# 1. Dart bilan build bosqichi
FROM dart:stable AS build

WORKDIR /app

# Dependencies olish
COPY pubspec.* ./
RUN dart pub get

# Kodlarni copy qilish
COPY . ./

# Binary yaratish
RUN dart compile exe bin/server.dart -o bin/server

# 2. Runtime image
FROM debian:stable-slim

# Kerakli paketlarni o'rnatish (Cloud SQL Proxy uchun)
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Compiled binary'ni copy qilish
COPY --from=build /app/bin/server /app/bin/server

# Executable qilish
RUN chmod +x /app/bin/server

# Environment variables
ENV PORT=8080
ENV HOST=0.0.0.0

# Port expose qilish
EXPOSE 8080

# Faqat binary'ni ishga tushirish
CMD ["/app/bin/server"]