import React, { useState } from 'react';
import {
    Box,
    Button,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    TextField,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    Typography,
    Alert
} from '@mui/material';
import { AccountCircle, Login } from '@mui/icons-material';

const RoleSwitcher = () => {
    const [openLogin, setOpenLogin] = useState(false);
    const [loginData, setLoginData] = useState({
        email: '',
        password: '',
        role: 'landlord'
    });
    const [error, setError] = useState('');
    const [isLoggedIn, setIsLoggedIn] = useState(false);
    const [userInfo, setUserInfo] = useState(null);

    // Kiểm tra trạng thái đăng nhập khi component mount
    React.useEffect(() => {
        const storedUser = localStorage.getItem('userInfo');
        if (storedUser) {
            const userData = JSON.parse(storedUser);
            setIsLoggedIn(true);
            setUserInfo(userData);
        }
    }, []);

    const handleLogin = () => {
        // Demo login - trong thực tế sẽ gọi API
        if (!loginData.email || !loginData.password) {
            setError('Vui lòng điền đầy đủ thông tin');
            return;
        }

        // Simulate successful login
        const userData = {
            email: loginData.email,
            role: loginData.role,
            name: loginData.role === 'landlord' ? 'Nguyễn Văn Chủ' : 'Nguyễn Văn A'
        };

        setIsLoggedIn(true);
        setUserInfo(userData);

        // Lưu vào localStorage để HomePage có thể đọc
        localStorage.setItem('userInfo', JSON.stringify(userData));

        setOpenLogin(false);
        setError('');
        setLoginData({ email: '', password: '', role: 'landlord' });

        // Reload page để cập nhật HomePage
        window.location.reload();
    };

    const handleLogout = () => {
        setIsLoggedIn(false);
        setUserInfo(null);

        // Xóa localStorage
        localStorage.removeItem('userInfo');

        // Reload page để cập nhật HomePage
        window.location.reload();
    };

    return (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            {isLoggedIn ? (
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                    <Typography variant="body2" color="text.secondary">
                        Xin chào, {userInfo.name}
                    </Typography>
                    <Button
                        size="small"
                        variant="outlined"
                        onClick={handleLogout}
                    >
                        Đăng xuất
                    </Button>
                </Box>
            ) : (
                <Button
                    size="small"
                    variant="outlined"
                    startIcon={<Login />}
                    onClick={() => setOpenLogin(true)}
                >
                    Đăng nhập
                </Button>
            )}

            {/* Login Dialog */}
            <Dialog open={openLogin} onClose={() => setOpenLogin(false)} maxWidth="sm" fullWidth>
                <DialogTitle>Đăng nhập</DialogTitle>
                <DialogContent>
                    <Box sx={{ pt: 1 }}>
                        {error && (
                            <Alert severity="error" sx={{ mb: 2 }}>
                                {error}
                            </Alert>
                        )}

                        <TextField
                            fullWidth
                            label="Email"
                            type="email"
                            value={loginData.email}
                            onChange={(e) => setLoginData({ ...loginData, email: e.target.value })}
                            sx={{ mb: 2 }}
                            placeholder="example@email.com"
                        />

                        <TextField
                            fullWidth
                            label="Mật khẩu"
                            type="password"
                            value={loginData.password}
                            onChange={(e) => setLoginData({ ...loginData, password: e.target.value })}
                            sx={{ mb: 2 }}
                            placeholder="Nhập mật khẩu"
                        />

                        <FormControl fullWidth>
                            <InputLabel>Vai trò</InputLabel>
                            <Select
                                value={loginData.role}
                                onChange={(e) => setLoginData({ ...loginData, role: e.target.value })}
                                label="Vai trò"
                            >
                                <MenuItem value="landlord">Chủ trọ</MenuItem>
                                <MenuItem value="tenant">Người thuê</MenuItem>
                            </Select>
                        </FormControl>

                        <Typography variant="body2" color="text.secondary" sx={{ mt: 2 }}>
                            💡 <strong>Demo:</strong> Có thể đăng nhập với bất kỳ email/mật khẩu nào
                        </Typography>
                    </Box>
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => setOpenLogin(false)}>Hủy</Button>
                    <Button onClick={handleLogin} variant="contained" startIcon={<Login />}>
                        Đăng nhập
                    </Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default RoleSwitcher;


