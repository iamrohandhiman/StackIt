# Problem Statement : StackIt – A Minimal Q&A Forum Platform


# StackIt

StackIt is a full-stack, minimal Q&A forum platform inspired by Stack Overflow. It provides a space for users to ask questions, post answers, and engage in a community-driven knowledge-sharing environment. This monorepo contains the complete project, including a Node.js backend, a Flutter mobile application, and a React web application.

## Features

*   **User Authentication**: Secure user signup and login using JSON Web Tokens (JWT). The system uses cookie-based authentication for the web and bearer tokens for the mobile application.
*   **Question & Answer System**: Users can create questions with a title, a detailed body, and relevant tags. Other users can provide answers to these questions.
*   **Voting Mechanism**: Answers can be upvoted or downvoted to highlight the most helpful and relevant solutions.
*   **Dynamic Feeds**: Questions can be browsed and sorted by various criteria, including newest, most answered, trending, and unanswered.
*   **Search Functionality**: A robust search feature allows users to find questions based on keywords in the title or body.
*   **User Mentions**: Users can mention others in answers, triggering notifications and enhancing collaboration.
*   **Cross-Platform Client Support**: The platform is accessible via both a React-based web interface and a Flutter-based mobile app.
*   **User Profiles**: Each user has a profile page that displays their activity, including questions asked, answers provided, and mentions.

## Technology Stack

| Component        | Technologies                                               |
| ---------------- | ---------------------------------------------------------- |
| **Backend**      | Node.js, Express.js, MongoDB, Mongoose, JWT, CORS, bcrypt  |
| **Web Frontend** | React, Vite, Tailwind CSS, Axios, React Router             |
| **Mobile App**   | Flutter, Dart                                              |

## Project Structure

The repository is organized as a monorepo with three main directories:

-   `Backend/`: Contains the Node.js/Express server, which handles API logic, database interactions, and user authentication.
-   `Frontend/`: Contains the Flutter application for iOS and Android.
-   `WebFrontend/`: Contains the React application for the web interface.

## Setup and Installation

### Prerequisites

-   Node.js and npm
-   MongoDB instance (local or remote)
-   Flutter SDK

### 1. Backend Setup

The backend server powers the API for both the web and mobile clients.

1.  Navigate to the `Backend` directory:
    ```bash
    cd Backend
    ```
2.  Install the required dependencies:
    ```bash
    npm install
    ```
3.  Create a `.env` file in the `Backend` directory and add the following environment variables:
    ```env
    MONGO_URI_BASE=your_mongodb_connection_string_without_db
    DB_NAME=stackit
    JWT_SECRET=your_jwt_secret_key
    JWT_EXPIRES_IN=1d
    PORT=5000
    ```
4.  Start the development server:
    ```bash
    npm run dev
    ```
    The server will be running on `http://localhost:5000`.

### 2. Web Frontend Setup

The web application provides a full-featured interface for interacting with the platform.

1.  Navigate to the `WebFrontend` directory:
    ```bash
    cd WebFrontend
    ```
2.  Install the required dependencies:
    ```bash
    npm install
    ```
3.  Start the development server:
    ```bash
    npm run dev
    ```
    The React application will be available at `http://localhost:5173`. The API proxy is already configured to communicate with the backend.

### 3. Mobile Frontend Setup

The Flutter app provides a native mobile experience.

1.  Navigate to the `Frontend` directory:
    ```bash
    cd Frontend
    ```
2.  Install the required Dart packages:
    ```bash
    flutter pub get
    ```
3.  Ensure your API endpoint URLs in the Flutter controllers (e.g., in `lib/controller/`) are pointing to your running backend server (e.g., `http://YOUR_LOCAL_IP:5000`).
4.  Run the application on an emulator or a connected device:
    ```bash
    flutter run
    ```

## API Endpoints

The backend exposes the following RESTful API endpoints.

<details>
<summary><strong>Authentication Routes</strong></summary>

| Method | Endpoint                        | Description                   |
| ------ | ------------------------------- | ----------------------------- |
| `POST` | `/api/v1/auth/signup`           | Register a new user.          |
| `POST` | `/api/v1/auth/login/web`        | Log in a user (cookie-based). |
| `POST` | `/api/v1/auth/login/mobile`     | Log in a user (token-based).  |
| `POST` | `/api/v1/auth/logout`           | Log out the current user.     |
| `GET`  | `/api/v1/auth/me`               | Get current user's profile.   |
| `PATCH`| `/api/v1/auth/mentions/markAllViewed` | Mark all mentions as viewed.  |

</details>

<details>
<summary><strong>Question and Answer Routes</strong></summary>

| Method | Endpoint                               | Description                                     |
| ------ | -------------------------------------- | ----------------------------------------------- |
| `GET`  | `/api/v1/questions`                    | Get all questions.                              |
| `POST` | `/api/v1/questions`                    | Create a new question.                          |
| `GET`  | `/api/v1/questions/search`             | Search for questions by a query string.         |
| `GET`  | `/api/v1/questions/:questionId`        | Get a single question by its ID.                |
| `GET`  | `/api/v1/dashboard/questions`          | Get paginated and sorted questions.             |
| `POST` | `/api/v1/questions/:questionId/answers`| Add an answer to a specific question.           |
| `POST` | `/api/v1/answers/:answerId/upvote`     | Upvote a specific answer.                       |
| `POST` | `/api/v1/answers/:answerId/downvote`   | Downvote a specific answer.                     |

</details>
