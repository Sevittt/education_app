---
name: firebase-storage
description: Comprehensive guide and snippets for using Firebase Cloud Storage
---
# Firebase Cloud Storage
Status: Production Ready Last Updated: 2026-01-25 Dependencies: None (standalone skill) Latest Versions: firebase@12.8.0, firebase-admin@13.6.0

Quick Start (5 Minutes)
1. Initialize Firebase Storage (Client)
// src/lib/firebase.ts
import { initializeApp } from 'firebase/app';
import { getStorage } from 'firebase/storage';

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
  // ... other config
};

const app = initializeApp(firebaseConfig);
export const storage = getStorage(app);
2. Initialize Firebase Admin Storage (Server)
// src/lib/firebase-admin.ts
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getStorage } from 'firebase-admin/storage';

if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  });
}

export const adminStorage = getStorage().bucket();
File Upload (Client SDK)
Basic Upload
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from './firebase';

async function uploadFile(file: File, path: string): Promise<string> {
  const storageRef = ref(storage, path);

  // Upload file
  const snapshot = await uploadBytes(storageRef, file);

  // Get download URL
  const downloadURL = await getDownloadURL(snapshot.ref);

  return downloadURL;
}

// Usage
const url = await uploadFile(file, `uploads/${userId}/${file.name}`);
Upload with Progress
import { ref, uploadBytesResumable, getDownloadURL, UploadTask } from 'firebase/storage';
import { storage } from './firebase';

function uploadFileWithProgress(
  file: File,
  path: string,
  onProgress: (progress: number) => void
): Promise<string> {
  return new Promise((resolve, reject) => {
    const storageRef = ref(storage, path);
    const uploadTask = uploadBytesResumable(storageRef, file);

    uploadTask.on(
      'state_changed',
      (snapshot) => {
        const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        onProgress(progress);
      },
      (error) => {
        reject(error);
      },
      async () => {
        const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
        resolve(downloadURL);
      }
    );
  });
}

// Usage with React state
const [progress, setProgress] = useState(0);
const url = await uploadFileWithProgress(file, path, setProgress);
Upload with Metadata
import { ref, uploadBytes, getDownloadURL, UploadMetadata } from 'firebase/storage';
import { storage } from './firebase';

async function uploadWithMetadata(file: File, path: string) {
  const storageRef = ref(storage, path);

  const metadata: UploadMetadata = {
    contentType: file.type,
    customMetadata: {
      uploadedBy: userId,
      originalName: file.name,
      uploadTime: new Date().toISOString(),
    },
  };

  const snapshot = await uploadBytes(storageRef, file, metadata);
  const downloadURL = await getDownloadURL(snapshot.ref);

  return { downloadURL, metadata: snapshot.metadata };
}
Upload from Data URL / Base64
import { ref, uploadString, getDownloadURL } from 'firebase/storage';
import { storage } from './firebase';

// Upload base64 string
async function uploadBase64(base64String: string, path: string) {
  const storageRef = ref(storage, path);

  // For data URL (includes prefix like "data:image/png;base64,")
  const snapshot = await uploadString(storageRef, base64String, 'data_url');

  // For raw base64 (no prefix)
  // const snapshot = await uploadString(storageRef, base64String, 'base64');

  const downloadURL = await getDownloadURL(snapshot.ref);
  return downloadURL;
}
File Download
Get Download URL
import { ref, getDownloadURL } from 'firebase/storage';
import { storage } from './firebase';

async function getFileURL(path: string): Promise<string> {
  const storageRef = ref(storage, path);
  const downloadURL = await getDownloadURL(storageRef);
  return downloadURL;
}
Download File as Blob
import { ref, getBlob } from 'firebase/storage';
import { storage } from './firebase';

async function downloadFile(path: string): Promise<Blob> {
  const storageRef = ref(storage, path);
  const blob = await getBlob(storageRef);
  return blob;
}

// Trigger browser download
async function downloadAndSave(path: string, filename: string) {
  const blob = await downloadFile(path);
  const url = URL.createObjectURL(blob);

  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();

  URL.revokeObjectURL(url);
}
Get File Metadata
import { ref, getMetadata } from 'firebase/storage';
import { storage } from './firebase';

async function getFileMetadata(path: string) {
  const storageRef = ref(storage, path);
  const metadata = await getMetadata(storageRef);

  return {
    name: metadata.name,
    size: metadata.size,
    contentType: metadata.contentType,
    created: metadata.timeCreated,
    updated: metadata.updated,
    customMetadata: metadata.customMetadata,
  };
}
File Management
Delete File
import { ref, deleteObject } from 'firebase/storage';
import { storage } from './firebase';

async function deleteFile(path: string): Promise<void> {
  const storageRef = ref(storage, path);
  await deleteObject(storageRef);
}
List Files in Directory
import { ref, listAll, list, getDownloadURL } from 'firebase/storage';
import { storage } from './firebase';

// List all files in a directory
async function listAllFiles(directoryPath: string) {
  const storageRef = ref(storage, directoryPath);
  const result = await listAll(storageRef);

  const files = await Promise.all(
    result.items.map(async (itemRef) => ({
      name: itemRef.name,
      fullPath: itemRef.fullPath,
      downloadURL: await getDownloadURL(itemRef),
    }))
  );

  const folders = result.prefixes.map((folderRef) => ({
    name: folderRef.name,
    fullPath: folderRef.fullPath,
  }));

  return { files, folders };
}

// Paginated list (for large directories)
async function listFilesPaginated(directoryPath: string, pageSize = 100) {
  const storageRef = ref(storage, directoryPath);
  const result = await list(storageRef, { maxResults: pageSize });

  // Get next page
  if (result.nextPageToken) {
    const nextPage = await list(storageRef, {
      maxResults: pageSize,
      pageToken: result.nextPageToken,
    });
  }

  return result;
}
Update Metadata
import { ref, updateMetadata } from 'firebase/storage';
import { storage } from './firebase';

async function updateFileMetadata(path: string, newMetadata: object) {
  const storageRef = ref(storage, path);
  const updatedMetadata = await updateMetadata(storageRef, {
    customMetadata: newMetadata,
  });
  return updatedMetadata;
}
Server-Side Operations (Admin SDK)
Upload from Server
import { adminStorage } from './firebase-admin';

async function uploadFromServer(
  buffer: Buffer,
  destination: string,
  contentType: string
) {
  const file = adminStorage.file(destination);

  await file.save(buffer, {
    contentType,
    metadata: {
      metadata: {
        uploadedBy: 'server',
        uploadTime: new Date().toISOString(),
      },
    },
  });

  // Make file publicly accessible (if needed)
  await file.makePublic();

  // Get public URL
  const publicUrl = `https://storage.googleapis.com/${adminStorage.name}/${destination}`;

  return publicUrl;
}
Generate Signed URL
import { adminStorage } from './firebase-admin';

async function generateSignedUrl(
  path: string,
  expiresInMinutes = 60
): Promise<string> {
  const file = adminStorage.file(path);

  const [signedUrl] = await file.getSignedUrl({
    action: 'read',
    expires: Date.now() + expiresInMinutes * 60 * 1000,
  });

  return signedUrl;
}

// For uploads (write access)
async function generateUploadUrl(path: string): Promise<string> {
  const file = adminStorage.file(path);

  const [signedUrl] = await file.getSignedUrl({
    action: 'write',
    expires: Date.now() + 15 * 60 * 1000, // 15 minutes
    contentType: 'application/octet-stream',
  });

  return signedUrl;
}
Delete from Server
import { adminStorage } from './firebase-admin';

async function deleteFromServer(path: string): Promise<void> {
  const file = adminStorage.file(path);
  await file.delete();
}

// Delete entire directory
async function deleteDirectory(directoryPath: string): Promise<void> {
  await adminStorage.deleteFiles({
    prefix: directoryPath,
  });
}
Security Rules
Basic Rules Structure
// storage.rules
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isValidImage() {
      return request.resource.contentType.matches('image/.*')
        && request.resource.size < 5 * 1024 * 1024; // 5MB
    }

    function isValidDocument() {
      return request.resource.contentType.matches('application/pdf')
        && request.resource.size < 10 * 1024 * 1024; // 10MB
    }

    // User uploads (private to user)
    match /users/{userId}/{allPaths=**} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId)
        && (isValidImage() || isValidDocument());
    }

    // Public uploads (anyone can read)
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if isAuthenticated() && isValidImage();
    }

    // Profile pictures
    match /profiles/{userId}/avatar.{ext} {
      allow read: if true;
      allow write: if isOwner(userId)
        && request.resource.contentType.matches('image/.*')
        && request.resource.size < 2 * 1024 * 1024; // 2MB
    }

    // Deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
Deploy Rules
firebase deploy --only storage
CORS Configuration
Configure CORS (Required for Web)
Create cors.json:

[
  {
    "origin": ["https://your-domain.com", "http://localhost:3000"],
    "method": ["GET", "PUT", "POST", "DELETE"],
    "maxAgeSeconds": 3600
  }
]
Apply CORS configuration:

gsutil cors set cors.json gs://your-bucket-name.appspot.com
CRITICAL: Without CORS configuration, uploads from browsers will fail with CORS errors.