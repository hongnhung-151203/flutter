import {
    ref,
    get,
    set,
    push,
    remove,
    onValue,
    serverTimestamp,
} from 'firebase/database';
import { dbRealtime } from './firebase';

const ROOMS_COL = 'rooms';

export const subscribeRooms = (onChange) => {
    if (!dbRealtime) return () => { };
    const roomsRef = ref(dbRealtime, ROOMS_COL);
    return onValue(roomsRef, (snap) => {
        const data = snap.val();
        if (data) {
            const roomsArray = Object.entries(data).map(([id, room]) => ({ id, ...room }));
            onChange(roomsArray);
        } else {
            onChange([]);
        }
    });
};

export const fetchRooms = async () => {
    if (!dbRealtime) return [];
    const roomsRef = ref(dbRealtime, ROOMS_COL);
    const snap = await get(roomsRef);
    if (snap.exists()) {
        const data = snap.val();
        return Object.entries(data).map(([id, room]) => ({ id, ...room }));
    }
    return [];
};

export const fetchRoomById = async (id) => {
    if (!dbRealtime) return null;
    const roomRef = ref(dbRealtime, `${ROOMS_COL}/${id}`);
    const snap = await get(roomRef);
    return snap.exists() ? { id, ...snap.val() } : null;
};

export const createRoom = async (room) => {
    if (!dbRealtime) return null;

    // Đảm bảo có màu sắc dựa trên status
    const getStatusColor = (status) => {
        switch (status) {
            case 'Có người':
                return '#4CAF50';
            case 'Trống':
                return '#9E9E9E';
            case 'Bảo trì':
                return '#FF9800';
            default:
                return '#9E9E9E';
        }
    };

    const payload = {
        name: room.name ?? '',
        status: room.status ?? 'Trống',
        temperature: room.temperature ?? '26°C',
        price: room.price ?? '',
        occupant: room.occupant ?? null,
        color: room.color ?? getStatusColor(room.status),
        icon: room.icon ?? (room.status === 'Trống' ? 'homeOutlined' : 'home'),
        gasAlert: !!room.gasAlert,
        motionDetected: !!room.motionDetected,
        humidity: Number(room.humidity ?? 50),
        lightOn: !!room.lightOn,
        fanOn: !!room.fanOn,
        createdAt: Date.now(),
    };
    const newRoomRef = push(ref(dbRealtime, ROOMS_COL));
    await set(newRoomRef, payload);
    return { id: newRoomRef.key, ...payload };
};

export const updateRoomById = async (id, partial) => {
    if (!dbRealtime) return;
    const roomRef = ref(dbRealtime, `${ROOMS_COL}/${id}`);
    await set(roomRef, { ...partial }, { merge: true });
};

export const deleteRoomById = async (id) => {
    if (!dbRealtime) return;
    const roomRef = ref(dbRealtime, `${ROOMS_COL}/${id}`);
    await remove(roomRef);
};

export const subscribeRoomById = (id, onChange) => {
    if (!dbRealtime) return () => { };
    const roomRef = ref(dbRealtime, `${ROOMS_COL}/${id}`);
    return onValue(roomRef, (snap) => {
        if (!snap.exists()) {
            onChange(null);
            return;
        }
        onChange({ id, ...snap.val() });
    });
};




