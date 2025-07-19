# Dockerfile (CLOUDRUN UCHUN OPTIMALLASHTIRILGAN VERSIYA)

# 1-BOSQICH: Qurish (Build)
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart pub get --offline
# Kompilyatsiya
RUN dart compile exe bin/server.dart -o bin/server

# 2-BOSQICH: Ishga tushirish (Runtime)
FROM scratch
WORKDIR /app
# Faqat kerakli fayllarni olamiz
COPY --from=build /app/bin/server /app/bin/server
# Tizim sertifikatlari
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Cloud Run avtomatik tarzda `PORT=8080`'ni o'rnatadi.
# Biz `EXPOSE` ni shunchaki ma'lumot uchun qoldiramiz.
EXPOSE 8080

# Ishga tushirish buyrug'i
CMD ["/app/bin/server"]