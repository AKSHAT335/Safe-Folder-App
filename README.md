# 🔐 Safe Folder App

A Flutter-based secure file management application that allows users to create **normal and password-protected folders**, securely store files, and manage them with persistent local storage.

This project was built as part of an **iOS/Flutter Internship Assignment**.

---

## ✨ Features Implemented

### 📁 Folder Management
- Create normal folders
- Create secure folders
- Delete folders
- Persistent folder storage
- Folder state saved after app restart

### 🔒 Security
- Password-protected folders
- Password securely stored using `flutter_secure_storage`
- Biometric authentication support
- Secure folders auto-lock after inactivity
- App locks secure folder when sent to background
- Re-authentication required on resume

### 📂 File Management
- Add files inside folders
- Supports:
  - Images
  - PDFs
  - Documents
- Local file storage using app directory
- Delete files from folder
- File persistence across app restart

### 🖼️ File Preview
- Image thumbnails
- PDF file icons
- Generic document icons
- Clean grid-based UI
- Better modern card design

### 💾 Storage
- `shared_preferences` for folder metadata
- `flutter_secure_storage` for passwords
- `path_provider` for local file persistence
- `file_picker` for file selection

---

## 📦 Packages Used

```yaml
shared_preferences
flutter_secure_storage
file_picker
path_provider
local_auth
