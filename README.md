# 🎯 TaskFocus — iOS Todo Application

A streamlined task management app built with **SwiftUI** and **Firebase** (Authentication & Cloud Firestore) following the **MVVM (Model-View-ViewModel)** architectural pattern.

---

## 🚀 Key Features

- **Authentication System**:
  - Email and password sign-in and account creation via Firebase Auth.
  - Built-in validation (email structure, minimum 6-character passwords, confirmation checks).
  - Preserved login session across application launches.

- **Cloud Firestore Storage**:
  - Live data synchronization using Firestore real-time snapshot listeners.
  - User-isolated data protection: each todo is tied to a `creatorId` matching the authenticated user UID.

- **Task Management**:
  - **Create**: Add new tasks with title, description, and priority level (*Low*, *Normal*, *High*).
  - **Read**: Dynamic list with quick metrics (*Pending* vs. *Completed* counters) and filter tabs (*All*, *Pending*, *Done*).
  - **Update**: Edit existing task details or toggle completion with a single tap.
  - **Delete**: Swipe left on any task item to delete from Cloud Firestore.

---

## 📁 Project Structure

```
todo-ios/
├── todo-ios.xcodeproj               # Xcode project file
└── todo-ios/
    ├── MasumTodoApp.swift           # Application entry point (@main, Firebase configuration)
    ├── GoogleService-Info.plist.example # Firebase configuration template
    ├── Models/
    │   └── TodoRecord.swift         # Core data model & PriorityLevel enum
    ├── Services/
    │   ├── FirebaseAuthenticator.swift # Firebase Auth wrapper (async/await)
    │   └── FirestoreTodoStore.swift    # Firestore real-time CRUD operations
    ├── ViewModels/
    │   ├── AuthCoordinator.swift    # Authentication state coordinator
    │   └── TodoDashboardViewModel.swift # Todo list filtering, metrics, and actions
    └── Views/
        ├── ContentView.swift        # Root switch between auth and dashboard
        ├── AuthView.swift           # Unified login and registration interface
        ├── TodoOverviewView.swift   # Main task dashboard with metric cards
        ├── TodoRowItem.swift        # Individual task item card component
        └── TaskFormSheet.swift      # Modal sheet for adding and editing tasks
```

---

## 🔒 Cloud Firestore Security Rules

Publish these rules in the [Firebase Console](https://console.firebase.google.com/) under **Firestore Database ➔ Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /todos/{todoId} {
      allow create: if request.auth != null
                    && request.auth.uid == request.resource.data.creatorId;

      allow read, delete: if request.auth != null
                          && request.auth.uid == resource.data.creatorId;

      allow update: if request.auth != null
                    && request.auth.uid == resource.data.creatorId
                    && request.auth.uid == request.resource.data.creatorId;
    }
  }
}
```

---

## 🛠️ How to Run in Xcode

1. Open `todo-ios.xcodeproj` in Xcode.
2. In Firebase Console, create an iOS App with Bundle ID: `com.masumapp.taskfocus`.
3. Download your `GoogleService-Info.plist` and place it in the `todo-ios/` folder (or copy `GoogleService-Info.plist.example`).
4. Select an iOS Simulator (e.g. iPhone 16) and press **Cmd + R** to run.
