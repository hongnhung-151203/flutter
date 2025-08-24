import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import {
    subscribeRooms,
    createRoom as createRoomCloud,
    updateRoomById as updateRoomCloud,
    deleteRoomById as deleteRoomCloud,
} from '../services/roomsService';
import { dbRealtime } from '../services/firebase';
import { useAuth } from './AuthContext';

const RoomsContext = createContext(null);

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

const createInitialRooms = () => ([
    {
        id: 1,
        name: 'Phòng 101',
        status: 'Có người',
        temperature: '26°C',
        color: '#4CAF50',
        icon: 'home',
        occupant: 'Nguyễn Văn A',
        price: '3.500.000 VND/tháng',
        // Sensors
        gasAlert: false,
        motionDetected: false,
        humidity: 55,
        // Devices
        fanOn: false,
        lightOn: true,
    },
    {
        id: 2,
        name: 'Phòng 102',
        status: 'Trống',
        temperature: '24°C',
        color: '#9E9E9E',
        icon: 'homeOutlined',
        occupant: null,
        price: '3.200.000 VND/tháng',
        gasAlert: false,
        motionDetected: false,
        humidity: 48,
        fanOn: false,
        lightOn: false,
    },
    {
        id: 3,
        name: 'Phòng 103',
        status: 'Có người',
        temperature: '27°C',
        color: '#4CAF50',
        icon: 'home',
        occupant: 'Trần Thị B',
        price: '3.800.000 VND/tháng',
        gasAlert: false,
        motionDetected: true,
        humidity: 62,
        fanOn: true,
        lightOn: true,
    },
    {
        id: 4,
        name: 'Phòng 104',
        status: 'Bảo trì',
        temperature: '25°C',
        color: '#FF9800',
        icon: 'build',
        occupant: null,
        price: '3.500.000 VND/tháng',
        gasAlert: true,
        motionDetected: false,
        humidity: 40,
        fanOn: false,
        lightOn: false,
    },
]);

export const RoomsProvider = ({ children }) => {
    const [rooms, setRooms] = useState([]); // Khởi tạo rỗng, chờ Firebase
    const isCloudEnabled = Boolean(dbRealtime);
    const [hasCloudSnapshot, setHasCloudSnapshot] = useState(false);
    const { role, tenantRoomId, canViewAllRooms, canViewOwnRoom } = useAuth();

    // Đảm bảo tất cả phòng đều có màu sắc
    const ensureRoomColors = (roomList) => {
        return roomList.map(room => ({
            ...room,
            color: room.color || getStatusColor(room.status),
            icon: room.icon || (room.status === 'Trống' ? 'homeOutlined' : 'home'),
        }));
    };

    // Sync from Firebase if configured
    useEffect(() => {
        if (!isCloudEnabled) return;
        const unsubscribe = subscribeRooms((data) => {
            setHasCloudSnapshot(true);

            if (Array.isArray(data) && data.length > 0) {
                console.log('🔥 Firebase data:', data);

                // Xử lý dữ liệu từ Firebase
                const firebaseRooms = data.map(room => ({
                    ...room,
                    color: room.color || getStatusColor(room.status),
                    icon: room.icon || (room.status === 'Trống' ? 'homeOutlined' : 'home'),
                    gasAlert: room.gasAlert ?? false,
                    motionDetected: room.motionDetected ?? false,
                    humidity: room.humidity ?? 50,
                    fanOn: room.fanOn ?? false,
                    lightOn: room.lightOn ?? false,
                }));

                // Luôn sử dụng dữ liệu từ Firebase (không merge với local)
                console.log('✅ Sử dụng dữ liệu từ Firebase:', firebaseRooms);
                setRooms(firebaseRooms);
            } else {
                console.log('📝 Firebase không có dữ liệu, sử dụng dữ liệu local mẫu');
                const localRooms = createInitialRooms();
                setRooms(localRooms);
            }
        });
        return () => unsubscribe && unsubscribe();
    }, [isCloudEnabled]);

    // Đảm bảo dữ liệu local luôn có màu sắc
    useEffect(() => {
        if (!hasCloudSnapshot) {
            const roomsWithColors = ensureRoomColors(rooms);
            if (JSON.stringify(roomsWithColors) !== JSON.stringify(rooms)) {
                console.log('🎨 Đảm bảo dữ liệu local có màu sắc');
                setRooms(roomsWithColors);
            }
        }
    }, [hasCloudSnapshot, rooms]);

    const addRoom = async (room) => {
        // Kiểm tra quyền
        if (role !== 'landlord') {
            throw new Error('Chỉ chủ trọ mới có thể thêm phòng mới');
        }

        // Đảm bảo phòng mới có đầy đủ thuộc tính
        const newRoom = {
            id: Date.now(),
            color: getStatusColor(room.status),
            icon: room.status === 'Trống' ? 'homeOutlined' : 'home',
            gasAlert: false,
            motionDetected: false,
            humidity: 50,
            fanOn: false,
            lightOn: false,
            ...room,
        };

        if (isCloudEnabled) {
            try {
                await createRoomCloud(newRoom);
                // rooms sẽ tự cập nhật qua subscribe
            } catch (err) {
                console.error('[Rooms] createRoomCloud failed, fallback local', err);
                setRooms((prev) => [...prev, newRoom]);
            }
        } else {
            setRooms((prev) => [...prev, newRoom]);
        }
    };

    const deleteRoom = async (id) => {
        // Kiểm tra quyền
        if (role !== 'landlord') {
            throw new Error('Chỉ chủ trọ mới có thể xóa phòng');
        }

        if (isCloudEnabled) {
            try {
                await deleteRoomCloud(String(id));
            } catch (err) {
                console.error('[Rooms] deleteRoomCloud failed, fallback local', err);
                setRooms((prev) => prev.filter((r) => String(r.id) !== String(id)));
            }
        } else {
            setRooms((prev) => prev.filter((r) => String(r.id) !== String(id)));
        }
    };

    const updateRoom = async (id, partial) => {
        // Kiểm tra quyền
        if (role === 'landlord') {
            // Chủ trọ có thể cập nhật tất cả phòng
        } else if (role === 'tenant') {
            // Người thuê chỉ có thể cập nhật phòng của mình
            if (String(tenantRoomId) !== String(id)) {
                throw new Error('Bạn chỉ có thể cập nhật phòng của mình');
            }
        } else {
            throw new Error('Bạn không có quyền cập nhật phòng');
        }

        if (isCloudEnabled) {
            try {
                await updateRoomCloud(String(id), partial);
            } catch (err) {
                console.error('[Rooms] updateRoomCloud failed, fallback local', err);
                setRooms((prev) => prev.map((r) => String(r.id) === String(id) ? { ...r, ...partial } : r));
            }
        } else {
            setRooms((prev) => prev.map((r) => String(r.id) === String(id) ? { ...r, ...partial } : r));
        }
    };

    // Filter rooms based on user permissions
    const filteredRooms = useMemo(() => {
        if (canViewAllRooms) {
            return rooms; // Landlord can see all rooms
        } else if (canViewOwnRoom && tenantRoomId) {
            return rooms.filter(room => String(room.id) === String(tenantRoomId)); // Tenant can only see their room
        }
        return []; // No access
    }, [rooms, canViewAllRooms, canViewOwnRoom, tenantRoomId]);

    const value = useMemo(() => ({
        rooms: filteredRooms,
        allRooms: rooms, // Keep access to all rooms for internal operations
        addRoom,
        deleteRoom,
        updateRoom,
        getRoomById: (id) => rooms.find((r) => String(r.id) === String(id)) || null,
        getOccupiedCount: () => rooms.filter((r) => r.status === 'Có người').length,
        getEmptyCount: () => rooms.filter((r) => r.status === 'Trống').length,
        canManageRooms: role === 'landlord',
        canViewAllRooms,
        canViewOwnRoom,
    }), [filteredRooms, rooms, role, canViewAllRooms, canViewOwnRoom]);

    return (
        <RoomsContext.Provider value={value}>
            {children}
        </RoomsContext.Provider>
    );
};

export const useRooms = () => {
    const ctx = useContext(RoomsContext);
    if (!ctx) throw new Error('useRooms must be used within RoomsProvider');
    return ctx;
};


