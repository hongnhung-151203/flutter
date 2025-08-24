import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { addNewRoom, updateRoom, deleteRoom } from '../seed.js';
import { dbRealtime } from '../services/firebase';
import { ref, onValue, off } from 'firebase/database';
import {
    Container,
    Grid,
    Card,
    CardContent,
    Typography,
    Box,
    Button,
    Chip,
    Alert,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    TextField,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    FormControlLabel,
    Switch,
    Slider,
} from '@mui/material';
import { Home as HomeIcon, Add as AddIcon, Edit as EditIcon, Delete as DeleteIcon } from '@mui/icons-material';

const HomePage = () => {
    const navigate = useNavigate();
    const [userInfo, setUserInfo] = useState(null);
    const [rooms, setRooms] = useState([]); // Dữ liệu phòng từ Firebase
    const [openAddRoom, setOpenAddRoom] = useState(false);
    const [openEditRoom, setOpenEditRoom] = useState(false);
    const [editingRoom, setEditingRoom] = useState(null);
    const [newRoom, setNewRoom] = useState({
        name: '',
        status: 'Trống',
        temperature: '24°C',
        price: '',
        occupant: null,
        lightOn: false,
        fanOn: false,
        gasLevel: 20,
        gasAlert: false,
        motionDetected: false,
        humidity: 50,
    });

    // Lấy thông tin user từ localStorage (demo)
    useEffect(() => {
        const storedUser = localStorage.getItem('userInfo');
        if (storedUser) {
            setUserInfo(JSON.parse(storedUser));
        }
    }, []);

    // Đọc dữ liệu phòng từ Firebase
    useEffect(() => {
        const roomsRef = ref(dbRealtime, 'rooms');

        const unsubscribe = onValue(roomsRef, (snapshot) => {
            if (snapshot.exists()) {
                const roomsData = snapshot.val();
                const roomsArray = Object.keys(roomsData).map(key => ({
                    id: key,
                    ...roomsData[key]
                }));
                setRooms(roomsArray);
                console.log('📊 Đã tải dữ liệu phòng từ Firebase:', roomsArray);
            } else {
                console.log('📊 Chưa có dữ liệu phòng trong Firebase');
                setRooms([]);
            }
        }, (error) => {
            console.error('❌ Lỗi đọc dữ liệu phòng:', error);
        });

        // Cleanup listener khi component unmount
        return () => off(roomsRef, 'value', unsubscribe);
    }, []);

    // Fallback data nếu Firebase chưa có dữ liệu
    const fallbackRooms = [
        {
            id: '101',
            name: 'Phòng 101',
            status: 'Có người',
            temperature: '26°C',
            price: '3.500.000 VND/tháng',
            occupant: 'Nguyễn Văn A',
            lightOn: false,
            fanOn: false,
            gasLevel: 25,
            gasAlert: false,
            motionDetected: false,
            humidity: 55,
        },
        {
            id: '102',
            name: 'Phòng 102',
            status: 'Trống',
            temperature: '24°C',
            price: '3.200.000 VND/tháng',
            occupant: null,
            lightOn: false,
            fanOn: false,
            gasLevel: 15,
            gasAlert: false,
            motionDetected: false,
            humidity: 48,
        },
    ];

    // Sử dụng dữ liệu từ Firebase, fallback về mock data nếu cần
    const displayRooms = rooms.length > 0 ? rooms : fallbackRooms;

    const canManageRooms = userInfo?.role === 'landlord';
    const canViewOwnRoom = userInfo?.role === 'tenant';

    // Hàm xử lý thêm phòng
    const handleAddRoom = async () => {
        if (newRoom.name && newRoom.price) {
            try {
                // Thêm phòng vào Firebase
                const roomId = await addNewRoom(newRoom);

                // Reset form
                setNewRoom({
                    name: '',
                    status: 'Trống',
                    temperature: '24°C',
                    price: '',
                    occupant: null,
                    lightOn: false,
                    fanOn: false,
                    gasLevel: 20,
                    gasAlert: false,
                    motionDetected: false,
                    humidity: 50,
                });

                setOpenAddRoom(false);

                // Hiển thị thông báo thành công
                alert(`✅ Đã thêm phòng mới: ${newRoom.name}\nID: ${roomId}\n\nPhòng mới sẽ hiển thị ngay lập tức!`);

            } catch (error) {
                console.error('Lỗi thêm phòng:', error);
                alert('❌ Lỗi thêm phòng: ' + error.message);
            }
        }
    };

    // Hàm xử lý thay đổi input
    const handleInputChange = (field, value) => {
        setNewRoom(prev => ({
            ...prev,
            [field]: value
        }));
    };

    // Hàm mở form chỉnh sửa phòng
    const handleEditRoom = (room) => {
        setEditingRoom(room);
        setOpenEditRoom(true);
    };

    // Hàm xử lý chỉnh sửa phòng
    const handleUpdateRoom = async () => {
        if (editingRoom && editingRoom.name && editingRoom.price) {
            try {
                // Cập nhật phòng trong Firebase
                await updateRoom(editingRoom.id, editingRoom);

                setOpenEditRoom(false);
                setEditingRoom(null);

                alert(`✅ Đã cập nhật phòng: ${editingRoom.name}`);

            } catch (error) {
                console.error('Lỗi cập nhật phòng:', error);
                alert('❌ Lỗi cập nhật phòng: ' + error.message);
            }
        }
    };

    // Hàm xử lý xóa phòng
    const handleDeleteRoom = async (roomId, roomName) => {
        if (window.confirm(`⚠️ Bạn có chắc chắn muốn xóa phòng "${roomName}"?\n\nHành động này không thể hoàn tác!`)) {
            try {
                // Xóa phòng khỏi Firebase
                await deleteRoom(roomId);

                alert(`✅ Đã xóa phòng: ${roomName}`);

            } catch (error) {
                console.error('Lỗi xóa phòng:', error);
                alert('❌ Lỗi xóa phòng: ' + error.message);
            }
        }
    };

    return (
        <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
            {/* User Info Alert */}
            {userInfo && (
                <Alert severity="info" sx={{ mb: 3 }}>
                    <strong>Xin chào {userInfo.name}!</strong>
                    Bạn đang đăng nhập với vai trò: <strong>{userInfo.role === 'landlord' ? 'Chủ trọ' : 'Người thuê'}</strong>
                </Alert>
            )}

            {/* Firebase Connection Status */}
            <Alert severity={rooms.length > 0 ? 'success' : 'warning'} sx={{ mb: 3 }}>
                <strong>📊 Trạng thái dữ liệu:</strong>
                {rooms.length > 0
                    ? ` Đã kết nối Firebase thành công! Hiển thị ${rooms.length} phòng từ database.`
                    : ' Đang kết nối Firebase... Sử dụng dữ liệu mẫu.'
                }
            </Alert>

            {/* Header */}
            <Box sx={{ mb: 4, textAlign: 'center' }}>
                <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 2 }}>
                    🏠 Quản lý nhà trọ
                </Typography>
                <Typography variant="body1" color="text.secondary">
                    Hệ thống quản lý thông minh cho nhà trọ của bạn
                </Typography>
            </Box>

            {/* Statistics */}
            <Grid container spacing={3} sx={{ mb: 4 }}>
                <Grid item xs={12} sm={4}>
                    <Card sx={{ textAlign: 'center', py: 2 }}>
                        <CardContent>
                            <HomeIcon sx={{ fontSize: 40, color: 'primary.main', mb: 1 }} />
                            <Typography variant="h4" color="primary" sx={{ fontWeight: 'bold' }}>
                                {displayRooms.length}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                                Tổng phòng
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
                <Grid item xs={12} sm={4}>
                    <Card sx={{ textAlign: 'center', py: 2 }}>
                        <CardContent>
                            <Typography variant="h4" color="secondary" sx={{ fontWeight: 'bold' }}>
                                {displayRooms.filter(r => r.status === 'Có người').length}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                                Đã thuê
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
                <Grid item xs={12} sm={4}>
                    <Card sx={{ textAlign: 'center', py: 2 }}>
                        <CardContent>
                            <Typography variant="h4" color="text.secondary" sx={{ fontWeight: 'bold' }}>
                                {displayRooms.filter(r => r.status === 'Trống').length}
                            </Typography>
                            <Typography variant="body2" color="text.secondary">
                                Trống
                            </Typography>
                        </CardContent>
                    </Card>
                </Grid>
            </Grid>

            {/* Room List Header */}
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h5" sx={{ fontWeight: 'bold' }}>
                    Danh sách phòng
                </Typography>
                {canManageRooms && (
                    <Button
                        variant="contained"
                        startIcon={<AddIcon />}
                        onClick={() => setOpenAddRoom(true)}
                    >
                        Thêm phòng
                    </Button>
                )}
            </Box>

            {/* Room List */}
            <Grid container spacing={3}>
                {displayRooms
                    .filter(room => {
                        if (canManageRooms) return true; // Chủ trọ xem tất cả
                        if (canViewOwnRoom) {
                            // Người thuê chỉ xem phòng của mình (demo: phòng 101)
                            return room.id === '101'; // Phòng 101
                        }
                        return false;
                    })
                    .map((room) => (
                        <Grid item xs={12} sm={6} md={4} key={room.id}>
                            <Card
                                sx={{
                                    cursor: 'pointer',
                                    transition: 'transform 0.2s, box-shadow 0.2s',
                                    '&:hover': {
                                        transform: 'translateY(-4px)',
                                        boxShadow: '0 8px 25px rgba(0,0,0,0.15)',
                                    }
                                }}
                                onClick={() => navigate(`/room/${room.id}`)}
                            >
                                <CardContent>
                                    <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 2 }}>
                                        {room.name}
                                    </Typography>

                                    <Box sx={{ mb: 2 }}>
                                        <Chip
                                            label={room.status}
                                            color={room.status === 'Có người' ? 'success' : 'default'}
                                            sx={{ fontWeight: 'bold' }}
                                        />
                                    </Box>

                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                        Nhiệt độ: {room.temperature}
                                    </Typography>
                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                        Giá: {room.price}
                                    </Typography>
                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                        Người thuê: {room.occupant || '---'}
                                    </Typography>

                                    {/* Trạng thái thiết bị */}
                                    <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mt: 1 }}>
                                        <Chip
                                            label={`💡 ${room.lightOn ? 'BẬT' : 'TẮT'}`}
                                            size="small"
                                            color={room.lightOn ? 'warning' : 'default'}
                                            variant="outlined"
                                        />
                                        <Chip
                                            label={`💨 ${room.fanOn ? 'BẬT' : 'TẮT'}`}
                                            size="small"
                                            color={room.fanOn ? 'info' : 'default'}
                                            variant="outlined"
                                        />
                                        <Chip
                                            label={`🌡️ ${room.humidity}%`}
                                            size="small"
                                            color="info"
                                            variant="outlined"
                                        />
                                    </Box>

                                    {/* Cảnh báo */}
                                    {room.gasLevel > 60 && (
                                        <Chip
                                            label="⚠️ CẢNH BÁO KHÍ GAS"
                                            size="small"
                                            color="error"
                                            sx={{ mt: 1 }}
                                        />
                                    )}
                                    {room.motionDetected && (
                                        <Chip
                                            label="🚨 CÓ CHUYỂN ĐỘNG"
                                            size="small"
                                            color="warning"
                                            sx={{ mt: 1 }}
                                        />
                                    )}

                                    {/* Nút chỉnh sửa và xóa - Chỉ chủ trọ */}
                                    {canManageRooms && (
                                        <Box sx={{ display: 'flex', gap: 1, mt: 2, justifyContent: 'flex-end' }}>
                                            <Button
                                                size="small"
                                                variant="outlined"
                                                color="primary"
                                                startIcon={<EditIcon />}
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    handleEditRoom(room);
                                                }}
                                            >
                                                Sửa
                                            </Button>
                                            <Button
                                                size="small"
                                                variant="outlined"
                                                color="error"
                                                startIcon={<DeleteIcon />}
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    handleDeleteRoom(room.id, room.name);
                                                }}
                                            >
                                                Xóa
                                            </Button>
                                        </Box>
                                    )}
                                </CardContent>
                            </Card>
                        </Grid>
                    ))}
            </Grid>

            {/* Demo Info */}
            {!userInfo && (
                <Alert severity="warning" sx={{ mt: 4 }}>
                    <strong>Demo:</strong> Đăng nhập để trải nghiệm đầy đủ tính năng của ứng dụng!
                </Alert>
            )}

            {/* Dialog thêm phòng */}
            <Dialog open={openAddRoom} onClose={() => setOpenAddRoom(false)} maxWidth="md" fullWidth>
                <DialogTitle>
                    <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                        🏠 Thêm phòng mới
                    </Typography>
                </DialogTitle>
                <DialogContent>
                    <Grid container spacing={3} sx={{ mt: 1 }}>
                        {/* Thông tin cơ bản */}
                        <Grid item xs={12} sm={6}>
                            <TextField
                                fullWidth
                                label="Tên phòng"
                                value={newRoom.name}
                                onChange={(e) => handleInputChange('name', e.target.value)}
                                placeholder="VD: Phòng 105"
                                required
                            />
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <TextField
                                fullWidth
                                label="Giá thuê"
                                value={newRoom.price}
                                onChange={(e) => handleInputChange('price', e.target.value)}
                                placeholder="VD: 3.500.000 VND/tháng"
                                required
                            />
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <FormControl fullWidth>
                                <InputLabel>Trạng thái</InputLabel>
                                <Select
                                    value={newRoom.status}
                                    label="Trạng thái"
                                    onChange={(e) => handleInputChange('status', e.target.value)}
                                >
                                    <MenuItem value="Trống">Trống</MenuItem>
                                    <MenuItem value="Có người">Có người</MenuItem>
                                    <MenuItem value="Bảo trì">Bảo trì</MenuItem>
                                    <MenuItem value="Đang sửa">Đang sửa</MenuItem>
                                </Select>
                            </FormControl>
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <TextField
                                fullWidth
                                label="Nhiệt độ"
                                value={newRoom.temperature}
                                onChange={(e) => handleInputChange('temperature', e.target.value)}
                                placeholder="VD: 24°C"
                            />
                        </Grid>

                        {/* Thiết lập cảm biến */}
                        <Grid item xs={12}>
                            <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 2, color: 'primary.main' }}>
                                📊 Thiết lập cảm biến ban đầu
                            </Typography>
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <Typography variant="body2" color="text.secondary" gutterBottom>
                                Mức khí gas: {newRoom.gasLevel}%
                            </Typography>
                            <Slider
                                value={newRoom.gasLevel}
                                onChange={(e, newValue) => handleInputChange('gasLevel', newValue)}
                                min={0}
                                max={100}
                                step={5}
                                marks
                                valueLabelDisplay="auto"
                                color="warning"
                            />
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <Typography variant="body2" color="text.secondary" gutterBottom>
                                Độ ẩm: {newRoom.humidity}%
                            </Typography>
                            <Slider
                                value={newRoom.humidity}
                                onChange={(e, newValue) => handleInputChange('humidity', newValue)}
                                min={20}
                                max={90}
                                step={5}
                                marks
                                valueLabelDisplay="auto"
                                color="info"
                            />
                        </Grid>

                        {/* Thiết lập thiết bị */}
                        <Grid item xs={12}>
                            <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 2, color: 'secondary.main' }}>
                                🎛️ Thiết lập thiết bị ban đầu
                            </Typography>
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={newRoom.lightOn}
                                        onChange={(e) => handleInputChange('lightOn', e.target.checked)}
                                        color="warning"
                                    />
                                }
                                label={`Đèn: ${newRoom.lightOn ? 'BẬT' : 'TẮT'}`}
                            />
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={newRoom.fanOn}
                                        onChange={(e) => handleInputChange('fanOn', e.target.checked)}
                                        color="info"
                                    />
                                }
                                label={`Quạt: ${newRoom.fanOn ? 'BẬT' : 'TẮT'}`}
                            />
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={newRoom.motionDetected}
                                        onChange={(e) => handleInputChange('motionDetected', e.target.checked)}
                                        color="warning"
                                    />
                                }
                                label={`Chuyển động: ${newRoom.motionDetected ? 'CÓ' : 'KHÔNG'}`}
                            />
                        </Grid>
                        <Grid item xs={12} sm={6}>
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={newRoom.gasAlert}
                                        onChange={(e) => handleInputChange('gasAlert', e.target.checked)}
                                        color="error"
                                    />
                                }
                                label={`Cảnh báo gas: ${newRoom.gasAlert ? 'BẬT' : 'TẮT'}`}
                            />
                        </Grid>
                    </Grid>
                </DialogContent>
                <DialogActions sx={{ p: 3 }}>
                    <Button onClick={() => setOpenAddRoom(false)} color="inherit">
                        Hủy
                    </Button>
                    <Button
                        onClick={handleAddRoom}
                        variant="contained"
                        color="primary"
                        disabled={!newRoom.name || !newRoom.price}
                    >
                        Thêm phòng
                    </Button>
                </DialogActions>
            </Dialog>

            {/* Dialog chỉnh sửa phòng */}
            <Dialog open={openEditRoom} onClose={() => setOpenEditRoom(false)} maxWidth="md" fullWidth>
                <DialogTitle>
                    <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                        ✏️ Chỉnh sửa phòng: {editingRoom?.name}
                    </Typography>
                </DialogTitle>
                <DialogContent>
                    {editingRoom && (
                        <Grid container spacing={3} sx={{ mt: 1 }}>
                            {/* Thông tin cơ bản */}
                            <Grid item xs={12} sm={6}>
                                <TextField
                                    fullWidth
                                    label="Tên phòng"
                                    value={editingRoom.name}
                                    onChange={(e) => setEditingRoom(prev => ({ ...prev, name: e.target.value }))}
                                    placeholder="VD: Phòng 105"
                                    required
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <TextField
                                    fullWidth
                                    label="Giá thuê"
                                    value={editingRoom.price}
                                    onChange={(e) => setEditingRoom(prev => ({ ...prev, price: e.target.value }))}
                                    placeholder="VD: 3.500.000 VND/tháng"
                                    required
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <FormControl fullWidth>
                                    <InputLabel>Trạng thái</InputLabel>
                                    <Select
                                        value={editingRoom.status}
                                        label="Trạng thái"
                                        onChange={(e) => setEditingRoom(prev => ({ ...prev, status: e.target.value }))}
                                    >
                                        <MenuItem value="Trống">Trống</MenuItem>
                                        <MenuItem value="Có người">Có người</MenuItem>
                                        <MenuItem value="Bảo trì">Bảo trì</MenuItem>
                                        <MenuItem value="Đang sửa">Đang sửa</MenuItem>
                                    </Select>
                                </FormControl>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <TextField
                                    fullWidth
                                    label="Nhiệt độ"
                                    value={editingRoom.temperature}
                                    onChange={(e) => setEditingRoom(prev => ({ ...prev, temperature: e.target.value }))}
                                    placeholder="VD: 24°C"
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <TextField
                                    fullWidth
                                    label="Người thuê"
                                    value={editingRoom.occupant || ''}
                                    onChange={(e) => setEditingRoom(prev => ({ ...prev, occupant: e.target.value || null }))}
                                    placeholder="Để trống nếu không có người thuê"
                                />
                            </Grid>

                            {/* Thiết lập cảm biến */}
                            <Grid item xs={12}>
                                <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 2, color: 'primary.main' }}>
                                    📊 Thiết lập cảm biến
                                </Typography>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Typography variant="body2" color="text.secondary" gutterBottom>
                                    Mức khí gas: {editingRoom.gasLevel}%
                                </Typography>
                                <Slider
                                    value={editingRoom.gasLevel}
                                    onChange={(e, newValue) => setEditingRoom(prev => ({ ...prev, gasLevel: newValue }))}
                                    min={0}
                                    max={100}
                                    step={5}
                                    marks
                                    valueLabelDisplay="auto"
                                    color="warning"
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Typography variant="body2" color="text.secondary" gutterBottom>
                                    Độ ẩm: {editingRoom.humidity}%
                                </Typography>
                                <Slider
                                    value={editingRoom.humidity}
                                    onChange={(e, newValue) => setEditingRoom(prev => ({ ...prev, humidity: newValue }))}
                                    min={20}
                                    max={90}
                                    step={5}
                                    marks
                                    valueLabelDisplay="auto"
                                    color="info"
                                />
                            </Grid>

                            {/* Thiết lập thiết bị */}
                            <Grid item xs={12}>
                                <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 2, color: 'secondary.main' }}>
                                    🎛️ Thiết lập thiết bị
                                </Typography>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={editingRoom.lightOn}
                                            onChange={(e) => setEditingRoom(prev => ({ ...prev, lightOn: e.target.checked }))}
                                            color="warning"
                                        />
                                    }
                                    label={`Đèn: ${editingRoom.lightOn ? 'BẬT' : 'TẮT'}`}
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={editingRoom.fanOn}
                                            onChange={(e) => setEditingRoom(prev => ({ ...prev, fanOn: e.target.checked }))}
                                            color="info"
                                        />
                                    }
                                    label={`Quạt: ${editingRoom.fanOn ? 'BẬT' : 'TẮT'}`}
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={editingRoom.motionDetected}
                                            onChange={(e) => setEditingRoom(prev => ({ ...prev, motionDetected: e.target.checked }))}
                                            color="warning"
                                        />
                                    }
                                    label={`Chuyển động: ${editingRoom.motionDetected ? 'CÓ' : 'KHÔNG'}`}
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <FormControlLabel
                                    control={
                                        <Switch
                                            checked={editingRoom.gasAlert}
                                            onChange={(e) => setEditingRoom(prev => ({ ...prev, gasAlert: e.target.checked }))}
                                            color="error"
                                        />
                                    }
                                    label={`Cảnh báo gas: ${editingRoom.gasAlert ? 'BẬT' : 'TẮT'}`}
                                />
                            </Grid>
                        </Grid>
                    )}
                </DialogContent>
                <DialogActions sx={{ p: 3 }}>
                    <Button onClick={() => setOpenEditRoom(false)} color="inherit">
                        Hủy
                    </Button>
                    <Button
                        onClick={handleUpdateRoom}
                        variant="contained"
                        color="primary"
                        disabled={!editingRoom?.name || !editingRoom?.price}
                    >
                        Cập nhật
                    </Button>
                </DialogActions>
            </Dialog>
        </Container>
    );
};

export default HomePage;
