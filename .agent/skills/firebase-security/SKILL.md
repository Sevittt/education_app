---
name: firebase-security
description: Firebase Security Expert (Firestore & Storage Rules). Emphasizes strict data privacy and access control for sensitive court documents. Guides AI on writing rules and generating queries that respect these rules.
---

# Firebase Security Expert & Rules Guidelines

This skill defines the security standards for the education application focused on Uzbekistan Court employees. Given the target audience, the application handles potentially sensitive structural information, user progress, and potentially document-related metadata. Strict adherence to Firebase Security Rules (Firestore and Storage) is mandatory.

## 1. Core Philosophy

*   **Zero Trust by Default:** Everything is denied by default (`allow read, write: if false;`). Explicit rules must be written to grant access.
*   **Authentication is Mandatory:** Almost all operations require a verified, authenticated user (`request.auth != null`).
*   **Data Ownership (The "Owner" Principle):** Users can generally only read and write their own data. Access to other users' data must be strictly controlled and usually reserved for Admin roles.
*   **Validation:** Data being written must be validated against expected schemas and constraints within the rules themselves (e.g., checking data types, required fields, and value ranges).
*   **Least Privilege:** Grant only the minimum access necessary for a feature to function.

## 2. Firestore Security Rules Standards

Firestore rules must be structured logically, usually mirroring the collection structure.

### 2.1 Basic Structure & Authentication Check

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
  
    // Helper Functions (Crucial for readability and reusability)
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isUser(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function isAdmin() {
      return isAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }

    // Default deny
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Feature-specific rules follow...
  }
}
```

### 2.2 Securing User Profiles (`/users/{userId}`)

User profiles contain sensitive data (phone numbers, progress, potentially department info).

```javascript
    match /users/{userId} {
      // Users can read and update their own profiles
      allow get, update: if isUser(userId);
      // Only the backend (Admin SDK) or specific triggers should create users, 
      // or clients can create their own document ONLY upon initial registration.
      allow create: if isUser(userId) && request.resource.data.keys().hasAll(['phoneNumber', 'createdAt']);
      allow list: if isAdmin(); // Only admins can list all users
      allow delete: if false; // Soft deletes preferred, or backend-only
    }
```

### 2.3 Securing Educational Content (e.g., `/courses`, `/modules`)

Educational content is usually read-only for standard users but writable by admins.

```javascript
    match /courses/{courseId} {
      allow read: if isAuthenticated(); // All logged-in users can view courses
      allow write: if isAdmin(); // Only admins can create/edit/delete courses
      
      match /lessons/{lessonId} {
        allow read: if isAuthenticated();
        allow write: if isAdmin();
      }
    }
```

### 2.4 Securing User Progress/Scores (`/userProgress/{progressId}`)

Progress must be securely tied to the user.

```javascript
    // Assuming structure: /userProgress/{userId_courseId}
    match /userProgress/{progressId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      
      // When writing, ensure the user can only write their own progress
      allow create, update: if isAuthenticated() 
                            && request.resource.data.userId == request.auth.uid;
      allow delete: if false;
    }
```

### 2.5 Securing Sensitive Operations containing "Court" or "Legal" data

If the app handles any simulated or actual court cases/documents for training:

```javascript
    match /trainingCases/{caseId} {
      // Must be authenticated and potentially check if the user is enrolled in the relevant course
      allow read: if isAuthenticated(); 
      allow write: if false; // Read-only for users, managed by Admin SDK
    }
```

## 3. Firebase Cloud Storage Security Standards

Storage rules follow similar principles but apply to files (images, PDFs, videos).

### 3.1 Basic Structure

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
  
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /{allPaths=**} {
      allow read, write: if false;
    }
    
    // Feature-specific rules follow...
  }
}
```

### 3.2 User Avatars/Profile Pictures (`/users/{userId}/avatar.png`)

```javascript
    match /users/{userId}/{fileName} {
      // Anyone authenticated can view avatars (if necessary for Leaderboards, etc.)
      allow read: if isAuthenticated();
      // Only the user can upload their avatar. Limit size and type.
      allow write: if isOwner(userId) 
                   && request.resource.size < 5 * 1024 * 1024 // 5MB limit
                   && request.resource.contentType.matches('image/.*');
    }
```

### 3.3 Course Materials (PDFs, Videos) (`/courses/{courseId}/{fileName}`)

```javascript
    match /courses/{courseId}/{fileName} {
      // Authenticated users can download course materials
      allow read: if isAuthenticated();
      // Only admins or backend can upload course materials
      allow write: if false; // Assuming Admin SDK handles uploads
    }
```

## 4. AI Assisant "Sodiq" Guidelines related to Security

When the AI ("Sodiq") assists with writing code that interacts with Firebase:

1.  **Never Assume Open Access:** Sodiq must never generate client-side code that assumes it can read the entire database without filters.
2.  **Enforce Query Filters:** When generating Firestore queries, Sodiq must ensure the query matches the rules. For example, if a rule says `allow read: if resource.data.userId == request.auth.uid`, the Flutter query MUST include `.where('userId', isEqualTo: currentUserId)`. *Rules are not filters; queries must be explicitly filtered to match the allowed subset.*
3.  **Validate Data Locally:** Sodiq should write Flutter code that validates data (e.g., form validation) *before* attempting to write to Firestore to provide a good UX, even though the security rules act as the final gatekeeper.
4.  **No Admin Keys in Client:** Sodiq must strictly warn against and never place Firebase Admin SDK service account keys inside the Flutter app. Admin operations belong in Cloud Functions or a secure backend environment.
5.  **Environment Variables:** Sodiq must emphasize using `.env` files for API keys (even public Firebase config) and utilizing Firebase App Check to protect backend resources from abuse.
6.  **"O'ta maxfiy" (Top Secret) Awareness:** If requested to handle data mimicking court documents, Sodiq must prioritize security above all, opting for restrictive rules and suggesting Cloud Functions for complex, sensitive logic rather than client-side execution.

## 5. Security Checklist for New Features

Whenever proposing a new feature involving data:
1.  What collection/path will store the data?
2.  Who needs to READ this data? (Write the `allow read` rule).
3.  Who needs to WRITE this data? (Write the `allow write` rule).
4.  What data validation (types, limits) must be enforced in the rule?
5.  What indices are required for the client-side queries?
6.  Are we exposing any sensitive information unintentionally?

## 6. Example Interaction Summary

**User:** "Menga yangi 'Sud amaliyoti' moduli uchun hujjatlarni backendga saqlash qismini yozib ber."
**Sodiq (AI):** "Albatta. Sud amaliyotiga oid hujjatlar o'ta maxfiy bo'lishi mumkinligini hisobga olib, avval ularning xavfsizligini ta'minlashimiz kerak. 
1. `firestore.rules` da bu collection uchun faqat o'quvchilarga (read) va adminlarga (write) ruxsat beramiz.
2. Flutter dasturida esa ma'lumotlarni o'qishda albatta foydalanuvchi avtorizatsiyadan o'tganligini tekshiramiz.
Mana sizga tegishli xavfsizlik qoidalari va ishonchli so'rov yozish tartibi..."
