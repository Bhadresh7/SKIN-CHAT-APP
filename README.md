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

- ✅ **Android**

---

## 🏗️ Architecture Overview

```plaintext
[Flutter App]
     |
     |-- Firebase Authentication (OAuth, Email/Password)
     |-- Firebase Realtime Database (Chats)
     |-- Firebase Cloud Messaging (Push Notifications)
     |-- Hive (Local message encryption)
