# Dart & Shelf: A Production-Ready Backend
![Language: Dart](https://img.shields.io/badge/Language-Dart_3.x-0175C2?style=for-the-badge&logo=dart)
![Framework: Shelf](https://img.shields.io/badge/Framework-Shelf-F24C00?style=for-the-badge)
![Architecture: Clean](https://img.shields.io/badge/Architecture-Clean-8E44AD?style=for-the-badge)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

A modern, scalable, and robust backend foundation for a full-featured application, meticulously built with **Dart** and the minimalist **Shelf** framework.

This repository serves as an **architectural template** demonstrating production-grade best practices aligned with **2025 software engineering standards**. It's a comprehensive starting point for any Dart developer aiming to build stable, testable, and maintainable systems.

---

## 🚀 Project Philosophy & Core Features

This project showcases a clean, decoupled, and secure approach to backend development within the Dart ecosystem.

🏛️ **Strict Clean Architecture**
The project is strictly divided into three core, independent layers:
- **API Layer (`/lib/api`):** Handles HTTP requests, responses, and validation. It is the only "door" to the application.
- **Domain Layer (`/lib/domain`):** The "brains" of the application, containing business entities, abstract repositories, and use cases. It is completely independent of frameworks and data sources.
- **Data Layer (`/lib/data`):** The "hands" of the application. It implements the contracts defined in the Domain Layer and is the only part that interacts directly with the database.

🔐 **Security as a Priority**
- User authentication and authorization are secured using **JWT (JSON Web Tokens)**.
- Passwords are never stored in plaintext. They are securely hashed using the industry-standard **BCrypt** algorithm via the `bcrypt` package.

🎯 **Type Safety & Robust Error Handling**
- The entire codebase leverages Dart's strong type system.
- All operations that can fail (database queries, business logic checks) use the `Either` type from the `dartz` package, eliminating unexpected `null` values and providing clear, predictable error channels (`Failure` vs. `Success`).

🧱 **Dependency Injection with `get_it`**
- All components are loosely coupled. Dependencies are instantiated and "injected" from a central location (`lib/di.dart`), making the codebase flexible, testable, and easy to refactor.

🔄 **Automated Database Migrations**
- The system includes a simple, automated initial migration service. On first run, it checks for the existence of required tables and creates the entire database schema if they are not found.

---

## 🛠️ Technology Stack

- **Language:** Dart 3.x
- **Backend Framework:** Shelf & Shelf Router
- **Database:** PostgreSQL (`postgres` package)
- **Security:** `dart_jsonwebtoken` (JWT), `bcrypt` (hashing)
- **Configuration:** Manual `.env` parsing
- **Functional Programming:** `dartz` (for `Either`)
- **Dependency Injection:** `get_it`
- **Containerization:** Docker

---

## 📁 Project Structure

A well-organized structure is key to a scalable project.

```
chat_app_backend/
├── .env          # Local configuration (DO NOT COMMIT)
├── Dockerfile    # For building a production-ready container
├── README.md     # You are here!
├── pubspec.yaml
└── lib/
    ├── api/                 # API Layer (The "Door")
    │   └── auth_api.dart
    ├── core/                # Core utilities, middleware, and services
    │   ├── config/
    │   ├── error/
    │   └── security/
    ├── data/                # Data Layer (The "Hands")
    │   ├── models/
    │   └── repositories/
    ├── domain/              # Domain Layer (The "Brain")
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    ├── services/            # Low-level infrastructure services (e.g., Database)
    └── di.dart              # Dependency Injection setup
└── bin/
    └── server.dart          # Application entry point
```

---

## 🏁 Getting Started

### Prerequisites
- Dart SDK (version 3.0+)
- PostgreSQL Server (for local testing)
- Docker (for deployment)

### Local Setup & Installation

1.  **Clone the repository:**
    ```bash
    git clone [Your-GitHub-Repo-URL]
    cd [your-repo-name]
    ```

2.  **Install dependencies:**
    ```bash
    dart pub get
    ```

3.  **Set up environment variables:**
    Create a `.env` file in the project root. You can copy the structure from the example below.

    **`.env.example`:**
    ```env
    # --- APPLICATION ---
    HOST=0.0.0.0
    PORT=8080
    LOG_LEVEL=ALL

    # --- DATABASE (PostgreSQL) ---
    DB_HOST=localhost
    DB_PORT=5432
    DB_USER=postgres
    DB_PASSWORD=your_db_password
    DB_NAME=chat_db

    # --- SECURITY (JWT) ---
    JWT_SECRET=your_super_secret_and_long_jwt_key
    JWT_ISSUER=http://localhost:8080
    JWT_EXPIRATION_MINUTES=60
    ```
    *(For a full list of required variables, see `lib/core/config/env.dart`)*

4.  **Run the server:**
    Ensure your local PostgreSQL server is running. Then, start the application:
    ```bash
    dart run bin/server.dart
    ```
    The server will start on `http://localhost:8080`. The first time it runs, it will automatically create all necessary database tables.

---

## 🌐 API Endpoints

All authentication endpoints are prefixed with `/api/v1/auth`.

| Method | URL                 | Description                  | Protection    |
|:-------|:--------------------|:-----------------------------|:--------------|
| `POST` | `/register`         | Register a new user          | None          |
| `POST` | `/login`            | Log in and receive a JWT     | None          |
| ...    | *...more to come*   |                              | JWT           |

---

## ☁️ Deployment to Google Cloud Run

This project is fully containerized and ready for easy deployment to a serverless platform like Google Cloud Run.

1.  **Set up Cloud SQL for PostgreSQL:** Create a PostgreSQL instance in your Google Cloud project (e.g., in the `europe-west1` region). Note the **Connection Name** and set a password for the `postgres` user.
2.  **Build and Push the Docker Image:**
    ```bash
    # Replace [PROJECT_ID] with your actual Google Cloud Project ID
    docker build -t gcr.io/[PROJECT_ID]/chat-backend .
    docker push gcr.io/[PROJECT_ID]/chat-backend
    ```

3.  **Deploy to Cloud Run:**
    Execute the following command, replacing the placeholders with your actual configuration values. This single command creates the service and configures it completely.

    ```powershell
    # Replace placeholders with your values
    $SQL_CONNECTION_NAME="[YOUR_PROJECT_ID]:[YOUR_REGION]:[YOUR_INSTANCE_ID]"
    $DB_PASSWORD="[YOUR_CLOUD_SQL_PASSWORD]"

    gcloud run deploy chat-backend `
      --image gcr.io/[YOUR_PROJECT_ID]/chat-backend:latest `
      --region [YOUR_REGION] `
      --allow-unauthenticated `
      --project=[YOUR_PROJECT_ID] `
      --add-cloudsql-instances="$SQL_CONNECTION_NAME" `
      --set-env-vars="APP_ENV=production,HOST=0.0.0.0,PORT=8080,LOG_LEVEL=INFO,DB_USER=postgres,DB_PASSWORD=$DB_PASSWORD,DB_NAME=chat_db,DB_HOST=/cloudsql/$SQL_CONNECTION_NAME,DB_POOL_SIZE=10,JWT_SECRET=[YOUR_JWT_SECRET],JWT_EXPIRATION_MINUTES=60"
    ```
    *(Note: Add other variables like SMTP settings to the `--set-env-vars` flag as needed.)*

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. Don't forget to give the project a star! Thanks again!

---

## 📄 License

Distributed under the MIT License. See `LICENSE` file for more information.