importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDXCwnaUFM_pAT6uVAGkP0Demz-3J-n5qs",
  authDomain: "iot-smart-5700d.firebaseapp.com",
  projectId: "iot-smart-5700d",
  messagingSenderId: "730556087229",
  appId: "1:730556087229:web:34ab2aaa7810a98680f0d4",
});

const messaging = firebase.messaging();
