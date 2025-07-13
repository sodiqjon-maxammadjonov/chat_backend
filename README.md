# Dart & Shelf: Modern Backend for a Real-Time Chat App

![Language: Dart](https://img.shields.io/badge/Language-Dart-0175C2?style=for-the-badge&logo=dart)
![Framework: Shelf](https://img.shields.io/badge/Framework-Shelf-F24C00?style=for-the-badge)
![Architecture: Clean](https://img.shields.io/badge/Architecture-Clean-8E44AD?style=for-the-badge)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

A modern, scalable, and robust backend foundation for a real-time chat application, built with **Dart** and the **Shelf** framework.

This project is more than just a set of APIs; it is an **architectural template** designed to demonstrate best practices for building stable, testable, and maintainable systems aligned with **2025 software engineering standards**.

---

## 🚀 Project Philosophy & Core Features

The primary goal of this project is to showcase a production-ready approach to backend development in the Dart ecosystem.

🏛️ **Clean Architecture**
The project is strictly divided into three core, independent layers:
- **API Layer:** Responsible for handling HTTP requests and responses (`Controllers`, `Middleware`, `Routes`).
- **Business Logic Layer:** The "brains" of the application (`AuthService`), completely independent of frameworks and data sources.
- **Data Layer:** The only part of the application that directly interacts with the database (`DataSource`).

🔐 **Security-First Approach**
- User authorization is secured using **JWT (JSON Web Tokens)**.
- Passwords are never stored in plaintext. They are securely hashed using modern algorithms provided by the **`crypt`** library.

🎯 **Type & Asynchronous Safety**
- The entire codebase is built around asynchronous operations.
- Error handling and success states in the business logic are managed using the `Either` monad from the `fpdart` package, preventing unexpected `null` values and exceptions.

🧱 **Dependency Injection**
- Components are loosely coupled. All dependencies are instantiated and "injected" from a central location (`server.dart`), making the codebase flexible and robust.

---

## 🛠️ Technology Stack

- **Language:** Dart 3.x
- **Backend Framework:** Shelf & Shelf Router
- **Database:** PostgreSQL
- **Security:** `dart_jsonwebtoken` (JWT), `crypt` (hashing)
- **Configuration:** `envied` (for `.env` file management)
- **Functional Programming:** `fpdart` (for `Either`)
- **Containerization:** Docker

---

## 📁 Project Structure

A well-organized structure is key to a scalable project.
chat_backend/
├── .env # Project configuration (do not commit to Git)
├── Dockerfile # For building a production-ready container
├── pubspec.yaml
└── lib/
├── api/ # API Layer (The "Door")
│ ├── controllers/
│ ├── middleware/
│ └── routes.dart
├── business_logic/ # Business Logic Layer (The "Brain")
├── core/ # Core utilities (Failures, Config)
├── data/ # Data Layer (The "Hands")
│ ├── datasources/
│ └── models/
├── services/ # Low-level infrastructure services (DB, Hashing, Token)
└── server.dart # Entry point and dependency injection

---

## 🏁 Getting Started

### Prerequisites
- Dart SDK (version 3.0+)
- PostgreSQL (for local testing) or a cloud-based instance (e.g., Google Cloud SQL)
- Docker (for deployment)

### Local Setup & Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/sodiqjon-maxammadjonov/chat_backend.git
    cd chat_backend
    ```

2.  **Install dependencies:**
    ```bash
    dart pub get
    ```

3.  **Set up environment variables:**
    Create a `.env` file in the project root. You can copy the structure from the example below.

    **`.env.example`:**
    ```env
    # Port for the local development server
    SERVER_PORT=8080

    # PostgreSQL connection settings replace with your own
    DB_HOST=localhost
    DB_PORT=5432
    DB_USER=postgres
    DB_PASSWORD=create your password
    DB_NAME=create your db name 

    # JWT Secret 
    JWT_SECRET_KEY=kreate your own key 
    ```
    After creating your `.env` file, run the code generator:
    ```bash
    dart run build_runner build
    ```

4.  **Set up the database:**
    In your PostgreSQL instance, create a database named `chat_db`. Then, execute the following SQL query to create the `users` table:
    ```sql
    CREATE TABLE users (
        id UUID PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        display_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL
    );
    ```

5.  **Run the server:**
    ```bash
    dart run bin/server.dart
    ```
    The server will start on `http://localhost:8080`.

---

## 🌐 API Endpoints

All primary endpoints are prefixed with `/api/auth`.

| Method | URL                 | Description                  | Protection    |
|:-------|:--------------------|:-----------------------------|:--------------|
| `POST` | `/register`         | Register a new user          | None          |
| `POST` | `/login`            | Log in and receive a JWT     | None          |
| `GET`  | `/profile`          | Get the user's profile data  | JWT           |

---

## ☁️ Deployment to Google Cloud Run

This project is configured for easy deployment to Google Cloud Run.

1.  Set up a Cloud SQL for PostgreSQL instance on your Google Cloud project and create the database and table as described above.
2.  Ensure you have the `gcloud CLI` installed and authenticated.
3.  Execute the following command, replacing the placeholders with your actual configuration values:

    ```powershell
    gcloud run deploy [SERVICE_NAME] `
        --source . `
        --platform managed `
        --region [YOUR_REGION] `
        --allow-unauthenticated `
        --set-env-vars="DB_HOST=[YOUR_CLOUDSQL_CONNECTION_NAME],DB_PORT=5432,DB_USER=[DB_USER],DB_PASSWORD=[DB_PASSWORD],DB_NAME=[DB_NAME],JWT_SECRET_KEY=[YOUR_JWT_KEY]" `
        --add-cloudsql-instances "[YOUR_CLOUDSQL_CONNECTION_NAME]"
    ```

---

## 🤝 Contributing

Contributions are always welcome! Whether you have an idea, find a bug, or want to improve the code, feel free to **Fork** the repository and submit a **Pull Request**. If you find this project useful, please consider giving it a ⭐!

---

## 📄 License

This project is distributed under the MIT License. See the `LICENSE` file for more information.