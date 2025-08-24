// src/seed.js
import { dbRealtime } from "./services/firebase";
import { ref, set } from "firebase/database";

// Seed dữ liệu Realtime Database
export async function seedRealtime() {
    try {
        // Seed rooms
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
        await set(ref(dbRealtime, "rooms/103"), {
            name: "Phòng 103",
            status: "Có người",
            temperature: "27°C",
            color: "#4CAF50",
            icon: "home",
            occupant: "Trần Thị B",
            price: "3.800.000 VND/tháng",
            gasAlert: false,
            motionDetected: true,
            humidity: 62,
            fanOn: true,
            lightOn: true,
        });
        await set(ref(dbRealtime, "rooms/104"), {
            name: "Phòng 104",
            status: "Bảo trì",
            temperature: "25°C",
            color: "#FF9800",
            icon: "build",
            occupant: null,
            price: "3.500.000 VND/tháng",
            gasAlert: true,
            motionDetected: false,
            humidity: 40,
            fanOn: false,
            lightOn: false,
        });

        // Seed users (profiles)
        await set(ref(dbRealtime, "users/landlord1"), {
            uid: "landlord1",
            name: "Nguyễn Văn Chủ",
            email: "landlord@example.com",
            role: "landlord",
            phone: "0901234567",
            createdAt: new Date().toISOString(),
            status: "active"
        });

        await set(ref(dbRealtime, "users/tenant1"), {
            uid: "tenant1",
            name: "Nguyễn Văn A",
            email: "tenant@example.com",
            role: "tenant",
            phone: "0901234568",
            createdAt: new Date().toISOString(),
            status: "active"
        });

        await set(ref(dbRealtime, "users/tenant2"), {
            uid: "tenant2",
            name: "Trần Thị B",
            email: "tenant2@example.com",
            role: "tenant",
            phone: "0901234569",
            createdAt: new Date().toISOString(),
            status: "active"
        });

        // Seed tenant-room mappings
        await set(ref(dbRealtime, "tenants/tenant1"), {
            roomID: "101",
            linkedAt: new Date().toISOString()
        });

        await set(ref(dbRealtime, "tenants/tenant2"), {
            roomID: "103",
            linkedAt: new Date().toISOString()
        });

        console.log("✅ Realtime DB: Thêm rooms, users và tenant mappings thành công!");
    } catch (err) {
        console.error("❌ Realtime error:", err);
    }
}

// Hàm thêm phòng mới vào Firebase
export async function addNewRoom(roomData) {
    try {
        // Tạo ID phòng mới (trong thực tế có thể dùng push() để tự động tạo key)
        const roomId = Date.now().toString();

        // Thêm phòng mới vào Firebase
        await set(ref(dbRealtime, `rooms/${roomId}`), {
            id: roomId,
            name: roomData.name,
            status: roomData.status,
            temperature: roomData.temperature,
            color: "#9E9E9E", // Màu mặc định
            icon: "homeOutlined", // Icon mặc định
            occupant: roomData.occupant,
            price: roomData.price,
            gasAlert: roomData.gasAlert,
            motionDetected: roomData.motionDetected,
            humidity: roomData.humidity,
            fanOn: roomData.fanOn,
            lightOn: roomData.lightOn,
            gasLevel: roomData.gasLevel,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        });

        console.log(`✅ Đã thêm phòng mới: ${roomData.name} với ID: ${roomId}`);
        return roomId;
    } catch (err) {
        console.error("❌ Lỗi thêm phòng:", err);
        throw err;
    }
}

// Hàm cập nhật phòng trong Firebase
export async function updateRoom(roomId, roomData) {
    try {
        // Cập nhật phòng trong Firebase
        await set(ref(dbRealtime, `rooms/${roomId}`), {
            ...roomData,
            updatedAt: new Date().toISOString()
        });

        console.log(`✅ Đã cập nhật phòng: ${roomData.name} với ID: ${roomId}`);
        return roomId;
    } catch (err) {
        console.error("❌ Lỗi cập nhật phòng:", err);
        throw err;
    }
}

// Hàm xóa phòng khỏi Firebase
export async function deleteRoom(roomId) {
    try {
        // Xóa phòng khỏi Firebase
        await set(ref(dbRealtime, `rooms/${roomId}`), null);

        console.log(`✅ Đã xóa phòng với ID: ${roomId}`);
        return roomId;
    } catch (err) {
        console.error("❌ Lỗi xóa phòng:", err);
        throw err;
    }
}

// Hàm seed tổng
export async function seedAll() {
    await seedRealtime();
}
