# Dockerfile

# 1-BOSQICH: Qurish (Build) muhiti
# Loyihani kompilyatsiya qilish uchun rasmiy Dart SDK'siga ega image'dan foydalanamiz
FROM dart:stable AS build

# Konteyner ichida ishlash uchun direktoriya
WORKDIR /app

# Birinchi navbatda faqat bog'liqliklar faylini nusxalaymiz.
# Bu Docker'ning keshidan samarali foydalanishga yordam beradi.
# Agar faqat kod o'zgarsa, bog'liqliklar qaytadan yuklanmaydi.
COPY pubspec.* ./
RUN dart pub get

# Butun loyiha kodini konteynerga nusxalaymiz
COPY . .

# Xavfsizlik uchun yana bir bor tekshirib, bog'liqliklarni offline rejimda olamiz.
RUN dart pub get --offline

# Ilovamizni production uchun optimallashtirilgan yagona ishga tushirish fayliga kompilyatsiya qilamiz (AOT compilation).
RUN dart compile exe bin/server.dart -o bin/server


# 2-BOSQICH: Ishga tushirish (Runtime) muhiti
# Ilgari qurilgan image'dagi natijani kichik va xavfsiz `scratch` image'iga o'tkazamiz.
# `scratch` - bu hech qanday ortiqcha narsasi yo'q bo'm-bo'sh image.
FROM scratch

WORKDIR /app

# Birinchi bosqichdan faqat kerakli fayllarni nusxalaymiz:
# 1. Kompilyatsiya qilingan server fayli
COPY --from=build /app/bin/server /app/bin/

# 2. Xavfsiz HTTPS ulanishlari uchun zarur bo'lgan tizim sertifikatlari
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# `.env` fayli konteynerga kiritilmaydi. U tashqaridan `--env-file` bayrog'i
# yoki bulutli platformalarning (Cloud Run, AWS) maxsus xizmatlari orqali ta'minlanadi.

# Konteyner qaysi portni "tinglashini" ko'rsatamiz.
# Bu `.env` faylidagi PORT bilan bir xil bo'lishi tavsiya etiladi.
EXPOSE 8080

# Konteyner ishga tushganda bajariladigan asosiy buyruq
CMD ["/app/bin/server"]