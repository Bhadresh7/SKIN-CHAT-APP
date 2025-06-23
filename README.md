# 💬 Skin Chat App

A real-time Android chat application built for **job seekers**, enabling seamless communication in a **single group chat**. Powered by **Flutter** and **Firebase**, the app ensures secure and responsive messaging with end-to-end encryption using **Hive**.

---

## 🚀 Features

- 🔒 **Secure Authentication**
  - Sign in via **OAuth** or **username/password**
  - Managed with **Firebase Authentication**

- 💬 **Real-Time Messaging**
  - All users communicate in a single shared group
  - Messages are delivered instantly via **Firebase Realtime Database**

- 🔔 **Push Notifications**
  - Get notified for new messages using **Firebase Cloud Messaging (FCM)**

- 🔐 **Encrypted Messaging**
  - All chat data is encrypted locally using **Hive**

---

## 🛠️ Tech Stack

| Layer          | Technology                     |
|----------------|--------------------------------|
| Frontend       | Flutter                        |
| Backend        | Firebase Realtime Database     |
| Authentication | Firebase Auth (OAuth + Email/Password) |
| Notifications  | Firebase Cloud Messaging       |
| Encryption     | Hive (for secure local storage)|

---

## 📱 Platform Support

Currently available for:

- ✅ **Android Only**

---

## 🏗️ Architecture Overview

```plaintext
[Flutter App]
     |
     |-- Firebase Authentication (OAuth, Email/Password)
     |-- Firebase Realtime Database (Chats)
     |-- Firebase Cloud Messaging (Push Notifications)
     |-- Hive (Local message encryption)
```

---

## 📁 Folder Structure

```
skin-chat-app/
├── android/
├── assets/
├── build/
├── lib/
│   ├── constants/          # App-wide constants
│   ├── firebase_options/   # Firebase configuration
│   ├── helpers/            # Utility helper functions
│   ├── models/             # Data models
│   ├── providers/          # State management (e.g., Provider)
│   ├── screens/            # UI screens
│   ├── services/           # Firebase and local services
│   ├── utils/              # Utility functions/constants
│   ├── widgets/            # Reusable widgets
│   ├── main.dart           # Entry point
│   ├── main_dev.dart       # Dev environment entry
│   └── main_prod.dart      # Prod environment entry
├── test/                   # Unit and widget tests
├── .env                    # Environment variables
└── .flutter-plugins
```

---

## 🧪 Getting Started

### 🔧 Prerequisites

- Flutter SDK (latest stable)
- Android Studio or VS Code with Flutter support
- Firebase project setup

### 📦 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/skin-chat-app.git
   cd skin-chat-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Add your `google-services.json` to `android/app/`
   - Enable Authentication and Realtime Database in Firebase console
   - Configure FCM for push notifications

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🙋‍♂️ Usage Guide

1. **Login/Register**
   - Sign in using your email/password or OAuth provider

2. **Chat in Group**
   - All users are added to a single group chat
   - Send and receive real-time messages
   - Messages are stored encrypted on the device

---

## 🛡️ Security

- ✅ **Firebase Auth** protects access
- ✅ **End-to-End Encryption** via Hive (stored locally)
- ✅ **Rules** in Firebase Realtime Database restrict unauthorized access

---

## 🤝 Contribution

Contributions are welcome! To contribute:

1. Fork the repo
2. Create your feature branch (`git checkout -b feature-name`)
3. Commit your changes (`git commit -m 'Add feature'`)
4. Push to the branch (`git push origin feature-name`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙌 Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Hive](https://pub.dev/packages/hive)

---
