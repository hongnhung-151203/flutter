import React from 'react';
import { Box, FormControl, InputLabel, MenuItem, Select, TextField, Autocomplete, Button } from '@mui/material';
import { useAuth } from '../context/AuthContext';
import { useRooms } from '../context/RoomsContext';

const RoleSwitcher = () => {
    const { role, setRole, tenantRoomId, setTenantRoomId, linkTenantRoom, user, signIn, signOutUser } = useAuth();
    const { rooms } = useRooms();

    return (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <FormControl size="small" sx={{ minWidth: 140 }}>
                <InputLabel>Vai trò</InputLabel>
                <Select
                    label="Vai trò"
                    value={role}
                    onChange={(e) => setRole(e.target.value)}
                >
                    <MenuItem value="landlord">Chủ trọ</MenuItem>
                    <MenuItem value="tenant">Người thuê</MenuItem>
                </Select>
            </FormControl>
            {role === 'tenant' && (
                <>
                    <Autocomplete
                        size="small"
                        options={rooms}
                        getOptionLabel={(r) => `${r.name} (${r.id})`}
                        sx={{ width: 280 }}
                        value={rooms.find(r => String(r.id) === String(tenantRoomId)) || null}
                        onChange={(e, val) => setTenantRoomId(val ? val.id : null)}
                        renderInput={(params) => <TextField {...params} label="Phòng của tôi" />}
                    />
                    {user ? (
                        <Button size="small" onClick={() => linkTenantRoom(tenantRoomId)} disabled={!tenantRoomId}>Lưu</Button>
                    ) : (
                        <Button size="small" onClick={async () => { try { await signIn('tenant@example.com', 'password'); } catch (e) { } }}>Đăng nhập mẫu</Button>
                    )}
                </>
            )}
        </Box>
    );
};

export default RoleSwitcher;


