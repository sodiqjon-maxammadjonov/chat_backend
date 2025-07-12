# Stage 1: build stage
FROM dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart compile exe bin/server.dart -o bin/server

# Stage 2: runtime stage
FROM dart:stable AS runtime

WORKDIR /app
COPY --from=build /app/bin/server ./

EXPOSE 8080

CMD [".bin/server"]
