// src/seed.js
import { dbRealtime } from "./services/firebase";
import { ref, set } from "firebase/database";

// Seed dữ liệu Realtime Database
export async function seedRealtime() {
    try {
        await set(ref(dbRealtime, "rooms/101"), {
            name: "Phòng 101",
            status: "Có người",
            temperature: "26°C",
            color: "#4CAF50",
            icon: "home",
            occupant: "Nguyễn Văn A",
            price: "3.500.000 VND/tháng",
            gasAlert: false,
            motionDetected: false,
            humidity: 55,
            fanOn: false,
            lightOn: true,
        });
        await set(ref(dbRealtime, "rooms/102"), {
            name: "Phòng 102",
            status: "Trống",
            temperature: "24°C",
            color: "#9E9E9E",
            icon: "homeOutlined",
            occupant: null,
            price: "3.200.000 VND/tháng",
            gasAlert: false,
            motionDetected: false,
            humidity: 48,
            fanOn: false,
            lightOn: false,
        });
        console.log("✅ Realtime DB: Thêm rooms thành công!");
    } catch (err) {
        console.error("❌ Realtime error:", err);
    }
}

// Hàm seed tổng
export async function seedAll() {
    await seedRealtime();
}
