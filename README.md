# 🔐 Safe Folder App (Flutter)

A secure and user-friendly file management application built using Flutter.
This app allows users to create protected folders, store files securely, and manage data with authentication and API integration.

---

## 🚀 Features

### 🔑 Authentication

* Login / Signup system
* Persistent login using Provider
* Secure logout functionality

### 📁 Folder Management

* Create secure folders
* Password-protected folders
* Delete folders with confirmation

### 📂 File Management

* Add files using file picker
* View stored files
* Delete files easily

### 🔐 Security

* Secure storage using `flutter_secure_storage`
* Sensitive data protection

### 🌐 API Integration

* Fetch and display data from REST API
* Error handling (no crash UX)
* Loading & empty state handling

### 🧠 State Management

* Implemented using **Provider**
* Clean and scalable architecture

---

## 📱 Screens

* Login Screen
* Signup Flow
* Dashboard (Folders)
* Folder Detail (Files)
* API Data Screen

---

## 🛠️ Tech Stack

* **Flutter** (UI Framework)
* **Dart**
* **Provider** (State Management)
* **HTTP Package** (API calls)
* **SharedPreferences** (local storage)
* **Flutter Secure Storage** (secure data)

---

## 📸 Screenshots

> Add screenshots here after uploading images

```
assets/screenshots/login.png
assets/screenshots/home.png
assets/screenshots/files.png
assets/screenshots/api.png
```

---

## ▶️ Run Locally

```bash
git clone https://github.com/YOUR_USERNAME/safe-folder-app.git
cd safe-folder-app
flutter pub get
flutter run
```

---

## 📦 Project Structure

```
lib/
│── providers/
│   └── auth_provider.dart
│
│── screens/
│   ├── login_screen.dart
│   ├── api_screen.dart
│
│── services/
│   └── api_service.dart
│
│── main.dart
```

---

## 💡 Key Learnings

* State management using Provider
* Handling asynchronous API calls
* Secure data handling in Flutter
* Managing app architecture and scalability

---

## 🔮 Future Improvements

* 🔐 Biometric authentication
* ☁️ Cloud storage (Firebase integration)
* 🔍 Search & filter functionality
* 🎨 Improved UI/UX design
* 📤 File upload to server

---

## 👨‍💻 Author

**Akshat Pratap Singh**

---

## ⭐ Show Your Support

If you like this project, give it a ⭐ on GitHub!
