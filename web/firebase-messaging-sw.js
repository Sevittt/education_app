importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyA_sKniDcrVI3w7OKVQQugXEwRyBezFMAo",
  authDomain: "educationapp-4780a.firebaseapp.com",
  projectId: "educationapp-4780a",
  storageBucket: "educationapp-4780a.firebasestorage.app",
  messagingSenderId: "660835097321",
  appId: "1:660835097321:web:029b18f8fb84d80ee3ee78",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification ?? {};
  if (!title) return;
  self.registration.showNotification(title, {
    body: body ?? '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
  });
});
