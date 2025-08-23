// Firebase initialization (SDK v9 modular) - Chỉ sử dụng Realtime Database
import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getDatabase } from 'firebase/database';
import { ref, onValue } from "firebase/database";

const firebaseConfig = {
    apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
    authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
    projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
    storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.REACT_APP_FIREBASE_APP_ID,
    databaseURL: process.env.REACT_APP_FIREBASE_DATABASE_URL,
};

// Debug: Kiểm tra biến môi trường
console.log('Firebase Config Debug:');
console.log('API Key:', process.env.REACT_APP_FIREBASE_API_KEY ? '✅ Có' : '❌ Không có');
console.log('Project ID:', process.env.REACT_APP_FIREBASE_PROJECT_ID ? '✅ Có' : '❌ Không có');
console.log('Database URL:', process.env.REACT_APP_FIREBASE_DATABASE_URL ? '✅ Có' : '❌ Không có');

const hasMinimumConfig = Boolean(firebaseConfig.apiKey && firebaseConfig.projectId);

if (!hasMinimumConfig) {
    // eslint-disable-next-line no-console
    console.warn('[Firebase] Thiếu cấu hình .env (cần tối thiểu API_KEY và PROJECT_ID). Ứng dụng sẽ chạy ở chế độ local demo.');
}

// Initialize Firebase app - Chỉ Realtime Database
let app = null;
let auth = null;
let rtdb = null;

if (hasMinimumConfig) {
    app = getApps().length ? getApp() : initializeApp(firebaseConfig);
    auth = getAuth(app);
    if (firebaseConfig.databaseURL) {
        rtdb = getDatabase(app);
    }
    console.log('✅ Firebase đã được khởi tạo thành công!');
    console.log('App:', app);
    console.log('Realtime Database:', rtdb);
} else {
    console.log('❌ Firebase không thể khởi tạo - thiếu cấu hình');
}

function listenRoomStatus() {
    if (rtdb) {
        const roomRef = ref(rtdb, "rooms/101");
        onValue(roomRef, (snapshot) => {
            console.log("Room 101 data:", snapshot.val());
        });
    }
}

// Export Realtime Database only
export const dbRealtime = rtdb;
export { app, auth, rtdb };
export default app;

// Test kết nối Firebase khi module được load
if (rtdb) {
    console.log('🔄 Đang test kết nối Firebase...');
    listenRoomStatus();
}


