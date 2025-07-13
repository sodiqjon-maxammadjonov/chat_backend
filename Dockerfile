# Dockerfile

FROM dart:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

COPY . .

RUN dart compile exe bin/server.dart -o bin/server

FROM scratch

WORKDIR /app

COPY --from=build /app/bin/server /app/bin/server

COPY --from=build /runtime/ /

ENV PORT 8080
EXPOSE 8080

CMD ["/app/bin/server"]