import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { auth, dbRealtime as rtdb } from '../services/firebase';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { ref, onValue, set } from 'firebase/database';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
    const [role, setRole] = useState('landlord'); // 'landlord' | 'tenant'
    const [tenantRoomId, setTenantRoomId] = useState(null);
    const [user, setUser] = useState(null);
    const [userProfile, setUserProfile] = useState(null);
    const isCloudEnabled = Boolean(process.env.REACT_APP_FIREBASE_PROJECT_ID);

    // Firebase auth state
    useEffect(() => {
        if (!auth) return;
        const unsub = onAuthStateChanged(auth, (u) => {
            setUser(u);
        });
        return () => unsub && unsub();
    }, []);

    // Subscribe tenant room mapping and user profile if logged in
    useEffect(() => {
        if (!isCloudEnabled || !user || !rtdb) return;

        // Subscribe to tenant room mapping
        const tenantRef = ref(rtdb, `tenants/${user.uid}`);
        const unsubTenant = onValue(tenantRef, (snapshot) => {
            const data = snapshot.val();
            if (data && data.roomID) {
                setTenantRoomId(data.roomID);
            }
        });

        // Subscribe to user profile
        const profileRef = ref(rtdb, `users/${user.uid}`);
        const unsubProfile = onValue(profileRef, (snapshot) => {
            const profile = snapshot.val();
            if (profile) {
                setUserProfile(profile);
                setRole(profile.role || 'tenant');
            }
        });

        return () => {
            unsubTenant && unsubTenant();
            unsubProfile && unsubProfile();
        };
    }, [isCloudEnabled, user, rtdb]);

    const signIn = async (email, password) => {
        const cred = await signInWithEmailAndPassword(auth, email, password);
        setUser(cred.user);

        // Role sẽ được set từ user profile trong useEffect
        // setRole('tenant'); // Removed - role comes from profile

        return cred.user;
    };

    const signOutUser = async () => {
        await signOut(auth);
        setUser(null);
        setTenantRoomId(null);
    };

    const linkTenantRoom = async (roomId) => {
        setTenantRoomId(roomId);
        if (isCloudEnabled && user && rtdb) {
            const tenantRef = ref(rtdb, `tenants/${user.uid}`);
            await set(tenantRef, { roomID: String(roomId) });
        }
    };

    const value = useMemo(() => ({
        role,
        setRole,
        user,
        userProfile,
        signIn,
        signOutUser,
        tenantRoomId,
        setTenantRoomId,
        linkTenantRoom,
        isLandlord: role === 'landlord',
        isTenant: role === 'tenant',
        canControlRoom: (roomId) => role === 'landlord' || (role === 'tenant' && String(tenantRoomId) === String(roomId)),
        canViewRoom: (roomId) => role === 'landlord' || (role === 'tenant' && String(tenantRoomId) === String(roomId)),
        canManageUsers: role === 'landlord',
        canManageRooms: role === 'landlord',
        canViewAllRooms: role === 'landlord',
        canViewOwnRoom: role === 'tenant',
    }), [role, tenantRoomId, user, userProfile]);

    return (
        <AuthContext.Provider value={value}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => {
    const ctx = useContext(AuthContext);
    if (!ctx) throw new Error('useAuth must be used within AuthProvider');
    return ctx;
};


