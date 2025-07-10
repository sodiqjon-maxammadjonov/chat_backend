# 🚀 Dart Chat Backend - Authentication API

> **Real-time chat application** uchun Dart tilida yozilgan authentication backend servisi

## ✨ Features

- 🔐 **Secure Authentication** - JWT token based auth
- 👤 **User Management** - Full CRUD operations
- 🔒 **Password Hashing** - SHA-256 with salt
- 🛡️ **Middleware Protection** - Route-level security
- 📱 **Mobile Ready** - Flutter client uchun optimized
- 🐳 **Docker Support** - Easy deployment
- 🚀 **Railway Ready** - One-click deploy

## 🛠️ Tech Stack

- **Backend**: Dart 3.0+ with Shelf framework
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Deployment**: Railway / Docker
- **IDE**: IntelliJ IDEA / VS Code

## 📋 Prerequisites

- Dart SDK 3.0+
- PostgreSQL 13+
- Git

## 🚀 Quick Start

### 1. Clone repository

```bash
git clone https://github.com/username/dart_chat_backend.git
cd dart_chat_backend
```

### 2. Install dependencies

```bash
dart pub get
```

### 3. Environment setup

`.env` fayl yarating:

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=chat_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT Secret
JWT_SECRET=your-super-secret-key-2024

# Server
PORT=8080
```

### 4. Database setup

PostgreSQL database yarating:

```sql
CREATE DATABASE chat_db;
```

### 5. Run server

```bash
dart run bin/server.dart
```

Server `http://localhost:8080` da ishga tushadi.

## 📡 API Endpoints

### Authentication Routes

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/register` | User registration | ❌ |
| POST | `/api/auth/login` | User login | ❌ |
| GET | `/api/auth/profile` | Get user profile | ✅ |
| PUT | `/api/auth/profile` | Update profile | ✅ |
| POST | `/api/auth/logout` | User logout | ✅ |

### Health Check

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Server health status |

## 🧪 API Testing

### Register User

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "password123",
    "display_name": "John Doe"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Muvaffaqiyatli ro'yxatdan o'tdi",
  "data": {
    "user": {
      "id": "uuid-here",
      "username": "johndoe",
      "email": "john@example.com",
      "display_name": "John Doe",
      "is_online": false,
      "created_at": "2024-01-01T00:00:00Z"
    },
    "token": "jwt-token-here"
  }
}
```

### Login User

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username_or_email": "johndoe",
    "password": "password123"
  }'
```

### Get Profile (Protected)

```bash
curl -X GET http://localhost:8080/api/auth/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 🐳 Docker Deployment

### Build image

```bash
docker build -t dart-chat-backend .
```

### Run container

```bash
docker run -p 8080:8080 \
  -e DB_HOST=your_db_host \
  -e DB_PASSWORD=your_db_password \
  -e JWT_SECRET=your_jwt_secret \
  dart-chat-backend
```

## 🚀 Railway Deployment

### 1. Railway setup

1. [Railway.app](https://railway.app) da account oching
2. GitHub repository connect qiling
3. PostgreSQL plugin qo'shing

### 2. Environment variables

Railway dashboard'da quyidagi environment variables qo'shing:

```env
JWT_SECRET=your-super-secret-key-2024
DB_HOST=${{Postgres.PGHOST}}
DB_PORT=${{Postgres.PGPORT}}
DB_NAME=${{Postgres.PGDATABASE}}
DB_USER=${{Postgres.PGUSER}}
DB_PASSWORD=${{Postgres.PGPASSWORD}}
```

### 3. Deploy

```bash
git push origin main
```

Railway avtomatik deploy qiladi.

## 📊 Database Schema

### Users Table

```sql
CREATE TABLE users (
    id VARCHAR PRIMARY KEY,
    username VARCHAR UNIQUE NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    profile_image VARCHAR,
    display_name VARCHAR,
    bio TEXT,
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
```

## 🔐 Security

- **Password Hashing**: SHA-256 with salt
- **JWT Tokens**: 7 kun expiry
- **CORS**: Enabled for all origins
- **Input Validation**: Server-side validation
- **SQL Injection**: Parameterized queries

## 🛡️ Error Handling

API barcha xatoliklar uchun consistent format qaytaradi:

```json
{
  "success": false,
  "message": "Xatolik matn"
}
```

## 📱 Flutter Integration

Flutter client uchun HTTP requests:

```dart
// Registration
final response = await http.post(
  Uri.parse('$baseUrl/api/auth/register'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username': username,
    'email': email,
    'password': password,
  }),
);

// Login
final response = await http.post(
  Uri.parse('$baseUrl/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username_or_email': usernameOrEmail,
    'password': password,
  }),
);

// Protected request
final response = await http.get(
  Uri.parse('$baseUrl/api/auth/profile'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
);
```

## 📋 TODO

- [ ] Email verification
- [ ] Password reset
- [ ] Profile image upload
- [ ] Social login (Google, Facebook)
- [ ] Rate limiting
- [ ] Refresh tokens
- [ ] User search
- [ ] Friend system
- [ ] Chat rooms
- [ ] Real-time messaging
- [ ] Push notifications

## 🐛 Common Issues

### Database Connection Error

```
Database connection failed: connection refused
```

**Solution**: PostgreSQL server ishlay olganini tekshiring va `.env` fayl to'g'ri ekanligini tasdiqlang.

### JWT Secret Error

```
JWT verification failed
```

**Solution**: `JWT_SECRET` environment variable to'g'ri o'rnatilganini tekshiring.

### Port Already in Use

```
Port 8080 is already in use
```

**Solution**: `.env` faylda `PORT` o'zgartirib boshqa port ishlatng.

## 🤝 Contributing

1. Fork repository
2. Feature branch yarating (`git checkout -b feature/amazing-feature`)
3. Commit qiling (`git commit -m 'Add amazing feature'`)
4. Push qiling (`git push origin feature/amazing-feature`)
5. Pull Request oching

## 📄 License

Bu loyiha MIT License ostida.

## 👨‍💻 Author

**Your Name**
- GitHub: [@username](https://github.com/username)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Dart team for amazing language
- Shelf framework contributors
- Railway for easy deployment
- PostgreSQL for reliable database

---

**⭐ Agar loyiha yoqsa, star bosing!**