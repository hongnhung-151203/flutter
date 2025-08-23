import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { auth, db } from '../services/firebase';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { doc, onSnapshot, setDoc } from 'firebase/firestore';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
    const [role, setRole] = useState('landlord'); // 'landlord' | 'tenant'
    const [tenantRoomId, setTenantRoomId] = useState(null);
    const [user, setUser] = useState(null);
    const isCloudEnabled = Boolean(process.env.REACT_APP_FIREBASE_PROJECT_ID);

    // Firebase auth state
    useEffect(() => {
        if (!auth) return;
        const unsub = onAuthStateChanged(auth, (u) => {
            setUser(u);
        });
        return () => unsub && unsub();
    }, []);

    // Subscribe tenant room mapping if logged in
    useEffect(() => {
        if (!isCloudEnabled || !user) return;
        const ref = doc(db, 'tenants', user.uid);
        const unsub = onSnapshot(ref, (snap) => {
            const data = snap.data();
            if (data && data.roomId) {
                setTenantRoomId(data.roomId);
            }
        });
        return () => unsub && unsub();
    }, [isCloudEnabled, user]);

    const signIn = async (email, password) => {
        const cred = await signInWithEmailAndPassword(auth, email, password);
        setUser(cred.user);
        setRole('tenant');
        return cred.user;
    };

    const signOutUser = async () => {
        await signOut(auth);
        setUser(null);
        setTenantRoomId(null);
    };

    const linkTenantRoom = async (roomId) => {
        setTenantRoomId(roomId);
        if (isCloudEnabled && user) {
            await setDoc(doc(db, 'tenants', user.uid), { roomId: String(roomId) }, { merge: true });
        }
    };

    const value = useMemo(() => ({
        role,
        setRole,
        user,
        signIn,
        signOutUser,
        tenantRoomId,
        setTenantRoomId,
        linkTenantRoom,
        isLandlord: role === 'landlord',
        canControlRoom: (roomId) => role === 'landlord' || (role === 'tenant' && String(tenantRoomId) === String(roomId)),
    }), [role, tenantRoomId, user]);

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


