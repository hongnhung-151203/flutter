import React, { useEffect, useState } from "react";
import { getDatabase, ref, onValue } from "firebase/database";
import app from "../services/firebase"; // file config Firebase của bạn

export default function FirebaseTest() {
    const [rooms, setRooms] = useState({});

    useEffect(() => {
        const db = getDatabase(app);
        const roomRef = ref(db, "room");

        onValue(roomRef, (snapshot) => {
            const data = snapshot.val();
            setRooms(data || {});
        });
    }, []);

    return (
        <div style={{ padding: 20 }}>
            <h2>Danh sách phòng</h2>
            <ul>
                {Object.entries(rooms).map(([key, room]) => (
                    <li key={key}>
                        <strong>{room.name}</strong> - {room.status} - {room.price} VND
                        {room.tenant && ` (Người thuê: ${room.tenant})`}
                    </li>
                ))}
            </ul>
        </div>
    );
}
