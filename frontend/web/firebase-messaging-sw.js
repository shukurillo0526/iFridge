// Firebase Cloud Messaging Service Worker
// Handles background push notifications for Plately

importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSy" + "AIrvmEslvnuvYZJwqyJrun0yVvbOF2tK4",
  authDomain: "plately-9b737.firebaseapp.com",
  projectId: "plately-9b737",
  storageBucket: "plately-9b737.firebasestorage.app",
  messagingSenderId: "852189904322",
  appId: "1:852189904322:web:fb6eb5f0495df202c2aa5b",
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log("[FCM SW] Background message:", payload);

  const title = payload.notification?.title || "Plately Alert";
  const options = {
    body: payload.notification?.body || "Check your fridge!",
    icon: "/icons/Icon-192.png",
    badge: "/icons/Icon-192.png",
    data: payload.data,
  };

  return self.registration.showNotification(title, options);
});
