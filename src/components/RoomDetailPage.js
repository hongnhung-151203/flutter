import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { dbRealtime } from '../services/firebase';
import { ref, onValue, off, set } from 'firebase/database';
import {
    AppBar,
    Toolbar,
    IconButton,
    Typography,
    Container,
    Card,
    CardContent,
    Grid,
    Box,
    Button,
    Switch,
    FormControlLabel,
    Chip,
    Alert,
    Slider,
    Divider,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import HomeIcon from '@mui/icons-material/Home';
import PeopleIcon from '@mui/icons-material/People';
import ThermostatIcon from '@mui/icons-material/Thermostat';
import LightModeIcon from '@mui/icons-material/LightMode';
import AirIcon from '@mui/icons-material/Air';
import GasMeterIcon from '@mui/icons-material/GasMeter';
import SensorsIcon from '@mui/icons-material/Sensors';
import OpacityIcon from '@mui/icons-material/Opacity';

const RoomDetailPage = () => {
    const navigate = useNavigate();
    const { id } = useParams();
    const [userInfo, setUserInfo] = useState(null);
    const [roomState, setRoomState] = useState({
        id: id,
        name: `Phòng ${id}`,
        status: 'Trống',
        temperature: '24°C',
        price: '---',
        occupant: null,
        // Thiết bị điều khiển
        lightOn: false,
        fanOn: false,
        fanSpeed: 50,
        // Cảm biến
        gasLevel: 20,
        gasAlert: false,
        motionDetected: false,
        humidity: 50,
        // Nhiệt độ
        temperatureValue: 24,
    });

    // Lấy thông tin user từ localStorage
    useEffect(() => {
        const storedUser = localStorage.getItem('userInfo');
        if (storedUser) {
            setUserInfo(JSON.parse(storedUser));
        }
    }, []);

    // Đọc dữ liệu phòng từ Firebase theo ID
    useEffect(() => {
        if (id) {
            const roomRef = ref(dbRealtime, `rooms/${id}`);

            const unsubscribe = onValue(roomRef, (snapshot) => {
                if (snapshot.exists()) {
                    const roomData = snapshot.val();
                    console.log(`📊 Đã tải dữ liệu phòng ${id}:`, roomData);

                    // Cập nhật state với dữ liệu thật từ Firebase
                    setRoomState(prev => ({
                        ...prev,
                        ...roomData,
                        // Đảm bảo các trường cần thiết có giá trị
                        fanSpeed: roomData.fanSpeed || 50,
                        temperatureValue: parseInt(roomData.temperature) || 24,
                        gasLevel: roomData.gasLevel || 20,
                        humidity: roomData.humidity || 50,
                        lightOn: roomData.lightOn || false,
                        fanOn: roomData.fanOn || false,
                        motionDetected: roomData.motionDetected || false,
                        gasAlert: roomData.gasAlert || false,
                    }));
                } else {
                    console.log(`📊 Không tìm thấy phòng ${id} trong Firebase`);
                    // Giữ nguyên dữ liệu mặc định
                }
            }, (error) => {
                console.error(`❌ Lỗi đọc dữ liệu phòng ${id}:`, error);
            });

            // Cleanup listener khi component unmount hoặc ID thay đổi
            return () => off(roomRef, 'value', unsubscribe);
        }
    }, [id]);

    const isLandlord = userInfo?.role === 'landlord';
    const isTenant = userInfo?.role === 'tenant';

    // Kiểm tra quyền xem phòng
    const canViewRoom = () => {
        if (isLandlord) return true; // Chủ trọ xem tất cả
        if (isTenant) {
            // Người thuê chỉ xem phòng 101 (demo)
            return String(id) === '101';
        }
        return false;
    };

    const handleDeviceToggle = async (device) => {
        try {
            const newValue = !roomState[device];

            // Cập nhật local state
            setRoomState(prev => ({
                ...prev,
                [device]: newValue
            }));

            // Cập nhật vào Firebase
            const roomRef = ref(dbRealtime, `rooms/${id}`);
            await set(roomRef, {
                ...roomState,
                [device]: newValue,
                updatedAt: new Date().toISOString()
            });

            console.log(`✅ Đã cập nhật ${device}: ${newValue}`);
        } catch (error) {
            console.error(`❌ Lỗi cập nhật ${device}:`, error);
            // Revert local state nếu có lỗi
            setRoomState(prev => ({
                ...prev,
                [device]: !prev[device]
            }));
        }
    };

    const handleFanSpeedChange = (event, newValue) => {
        setRoomState(prev => ({
            ...prev,
            fanSpeed: newValue
        }));
    };

    const handleTemperatureChange = (event, newValue) => {
        setRoomState(prev => ({
            ...prev,
            temperatureValue: newValue,
            temperature: `${newValue}°C`
        }));
    };

    const getGasStatus = () => {
        if (roomState.gasLevel > 80) return { color: 'error', text: 'NGUY HIỂM' };
        if (roomState.gasLevel > 60) return { color: 'warning', text: 'CẢNH BÁO' };
        return { color: 'success', text: 'BÌNH THƯỜNG' };
    };

    const gasStatus = getGasStatus();

    return (
        <Box sx={{ flexGrow: 1 }}>
            <AppBar position="static" elevation={0}>
                <Toolbar>
                    <IconButton edge="start" color="inherit" onClick={() => navigate(-1)}>
                        <ArrowBackIcon />
                    </IconButton>
                    <Typography variant="h6" component="div" sx={{ ml: 1, flexGrow: 1 }}>
                        Chi tiết phòng
                    </Typography>
                    {isLandlord && (
                        <Chip
                            label="Chế độ chủ trọ"
                            color="primary"
                            size="small"
                        />
                    )}
                </Toolbar>
            </AppBar>

            <Container maxWidth="md" sx={{ mt: 4, mb: 4 }}>
                {/* Kiểm tra quyền */}
                {!canViewRoom() && (
                    <Alert severity="error" sx={{ mb: 3 }}>
                        <strong>Không có quyền truy cập!</strong>
                        {isTenant ? ' Bạn chỉ có thể xem phòng của mình.' : ' Vui lòng đăng nhập để xem phòng.'}
                    </Alert>
                )}

                {/* Trạng thái tải dữ liệu */}
                {canViewRoom() && (
                    <Alert severity="info" sx={{ mb: 3 }}>
                        <strong>📊 Thông tin phòng:</strong>
                        {roomState.name} - {roomState.status} - {roomState.temperature}
                        {roomState.occupant && ` - Người thuê: ${roomState.occupant}`}
                    </Alert>
                )}

                {/* Thông tin cơ bản */}
                {canViewRoom() && (
                    <>
                        <Card sx={{ mb: 3 }}>
                            <CardContent>
                                <Typography variant="h5" sx={{ fontWeight: 'bold', mb: 2 }}>
                                    {roomState.name}
                                </Typography>

                                <Grid container spacing={2} sx={{ mb: 2 }}>
                                    <Grid item xs={12} sm={6}>
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                            <HomeIcon color="primary" />
                                            <Typography>Giá: {roomState.price}</Typography>
                                        </Box>
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                            <ThermostatIcon color="secondary" />
                                            <Typography>Nhiệt độ: {roomState.temperature}</Typography>
                                        </Box>
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                            <PeopleIcon color="action" />
                                            <Typography>Người thuê: {roomState.occupant || '---'}</Typography>
                                        </Box>
                                    </Grid>
                                    <Grid item xs={12} sm={6}>
                                        <Chip
                                            label={roomState.status}
                                            color={roomState.status === 'Có người' ? 'success' : 'default'}
                                            sx={{ fontWeight: 'bold' }}
                                        />
                                    </Grid>
                                </Grid>

                                <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center' }}>
                                    <Button variant="contained" onClick={() => navigate(`/`)}>Về trang chủ</Button>
                                    <Button variant="outlined" onClick={() => navigate(-1)}>Quay lại</Button>
                                </Box>
                            </CardContent>
                        </Card>

                        {/* Điều khiển thiết bị - Chỉ chủ trọ */}
                        {isLandlord && (
                            <Card sx={{ mb: 3 }}>
                                <CardContent>
                                    <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 3, color: 'primary.main' }}>
                                        🎛️ Điều khiển thiết bị
                                    </Typography>

                                    <Grid container spacing={3}>
                                        {/* Điều khiển đèn */}
                                        <Grid item xs={12} sm={6}>
                                            <Box sx={{ p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                    <LightModeIcon color={roomState.lightOn ? 'warning' : 'disabled'} />
                                                    <Typography variant="h6">Điều khiển đèn</Typography>
                                                </Box>
                                                <FormControlLabel
                                                    control={
                                                        <Switch
                                                            checked={roomState.lightOn}
                                                            onChange={() => handleDeviceToggle('lightOn')}
                                                            color="warning"
                                                        />
                                                    }
                                                    label={roomState.lightOn ? 'Đèn BẬT' : 'Đèn TẮT'}
                                                />
                                            </Box>
                                        </Grid>

                                        {/* Điều khiển quạt */}
                                        <Grid item xs={12} sm={6}>
                                            <Box sx={{ p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                    <AirIcon color={roomState.fanOn ? 'info' : 'disabled'} />
                                                    <Typography variant="h6">Điều khiển quạt</Typography>
                                                </Box>
                                                <FormControlLabel
                                                    control={
                                                        <Switch
                                                            checked={roomState.fanOn}
                                                            onChange={() => handleDeviceToggle('fanOn')}
                                                            color="info"
                                                        />
                                                    }
                                                    label={roomState.fanOn ? 'Quạt BẬT' : 'Quạt TẮT'}
                                                />
                                                {roomState.fanOn && (
                                                    <Box sx={{ mt: 2 }}>
                                                        <Typography variant="body2" color="text.secondary" gutterBottom>
                                                            Tốc độ quạt: {roomState.fanSpeed}%
                                                        </Typography>
                                                        <Slider
                                                            value={roomState.fanSpeed}
                                                            onChange={handleFanSpeedChange}
                                                            min={0}
                                                            max={100}
                                                            step={10}
                                                            marks
                                                            valueLabelDisplay="auto"
                                                        />
                                                    </Box>
                                                )}
                                            </Box>
                                        </Grid>

                                        {/* Điều chỉnh nhiệt độ */}
                                        <Grid item xs={12}>
                                            <Box sx={{ p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                    <ThermostatIcon color="secondary" />
                                                    <Typography variant="h6">Điều chỉnh nhiệt độ</Typography>
                                                </Box>
                                                <Typography variant="body2" color="text.secondary" gutterBottom>
                                                    Nhiệt độ hiện tại: {roomState.temperatureValue}°C
                                                </Typography>
                                                <Slider
                                                    value={roomState.temperatureValue}
                                                    onChange={handleTemperatureChange}
                                                    min={16}
                                                    max={35}
                                                    step={1}
                                                    marks
                                                    valueLabelDisplay="auto"
                                                    color="secondary"
                                                />
                                            </Box>
                                        </Grid>
                                    </Grid>
                                </CardContent>
                            </Card>
                        )}

                        {/* Giám sát cảm biến */}
                        <Card>
                            <CardContent>
                                <Typography variant="h6" sx={{ fontWeight: 'bold', mb: 3, color: 'info.main' }}>
                                    📊 Giám sát cảm biến
                                </Typography>

                                <Grid container spacing={3}>
                                    {/* Cảm biến khí gas */}
                                    <Grid item xs={12} sm={6}>
                                        <Box sx={{ p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                <GasMeterIcon color={gasStatus.color} />
                                                <Typography variant="h6">Cảm biến khí gas</Typography>
                                            </Box>
                                            <Typography variant="h4" color={gasStatus.color} sx={{ fontWeight: 'bold', mb: 1 }}>
                                                {roomState.gasLevel}%
                                            </Typography>
                                            <Chip
                                                label={gasStatus.text}
                                                color={gasStatus.color}
                                                sx={{ fontWeight: 'bold' }}
                                            />
                                            {isLandlord && (
                                                <Box sx={{ mt: 2 }}>
                                                    <Typography variant="body2" color="text.secondary" gutterBottom>
                                                        Mức khí gas: {roomState.gasLevel}%
                                                    </Typography>
                                                    <Slider
                                                        value={roomState.gasLevel}
                                                        onChange={(e, newValue) => setRoomState(prev => ({ ...prev, gasLevel: newValue }))}
                                                        min={0}
                                                        max={100}
                                                        step={5}
                                                        marks
                                                        valueLabelDisplay="auto"
                                                        color={gasStatus.color}
                                                    />
                                                </Box>
                                            )}
                                        </Box>
                                    </Grid>

                                    {/* Cảm biến chuyển động */}
                                    <Grid item xs={12} sm={6}>
                                        <Box sx={{ p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                <SensorsIcon color={roomState.motionDetected ? 'warning' : 'disabled'} />
                                                <Typography variant="h6">Cảm biến chuyển động</Typography>
                                            </Box>
                                            <Typography variant="h4" color={roomState.motionDetected ? 'warning.main' : 'text.secondary'} sx={{ fontWeight: 'bold', mb: 1 }}>
                                                {roomState.motionDetected ? 'CÓ' : 'KHÔNG'}
                                            </Typography>
                                            <Chip
                                                label={roomState.motionDetected ? 'Phát hiện chuyển động' : 'Không có chuyển động'}
                                                color={roomState.motionDetected ? 'warning' : 'default'}
                                                sx={{ fontWeight: 'bold' }}
                                            />
                                            {isLandlord && (
                                                <FormControlLabel
                                                    control={
                                                        <Switch
                                                            checked={roomState.motionDetected}
                                                            onChange={() => handleDeviceToggle('motionDetected')}
                                                            color="warning"
                                                        />
                                                    }
                                                    label="Mô phỏng chuyển động"
                                                    sx={{ mt: 2 }}
                                                />
                                            )}
                                        </Box>
                                    </Grid>

                                    {/* Cảm biến độ ẩm */}
                                    <Grid item xs={12}>
                                        <Box sx={{ p: 2, border: '1px solid #e0e0e0', borderRadius: 2 }}>
                                            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                                                <OpacityIcon color="info" />
                                                <Typography variant="h6">Cảm biến độ ẩm</Typography>
                                            </Box>
                                            <Typography variant="h4" color="info.main" sx={{ fontWeight: 'bold', mb: 1 }}>
                                                {roomState.humidity}%
                                            </Typography>
                                            <Chip
                                                label={`Độ ẩm: ${roomState.humidity}%`}
                                                color="info"
                                                sx={{ fontWeight: 'bold' }}
                                            />
                                            {isLandlord && (
                                                <Box sx={{ mt: 2 }}>
                                                    <Typography variant="body2" color="text.secondary" gutterBottom>
                                                        Độ ẩm: {roomState.humidity}%
                                                    </Typography>
                                                    <Slider
                                                        value={roomState.humidity}
                                                        onChange={(e, newValue) => setRoomState(prev => ({ ...prev, humidity: newValue }))}
                                                        min={20}
                                                        max={90}
                                                        step={5}
                                                        marks
                                                        valueLabelDisplay="auto"
                                                        color="info"
                                                    />
                                                </Box>
                                            )}
                                        </Box>
                                    </Grid>
                                </Grid>
                            </CardContent>
                        </Card>

                        {/* Thông báo cho người thuê */}
                        {!isLandlord && (
                            <Alert severity="info" sx={{ mt: 3 }}>
                                <strong>Lưu ý:</strong> Chỉ chủ trọ mới có thể điều khiển thiết bị và cảm biến.
                            </Alert>
                        )}
                    </>
                )}
            </Container>
        </Box>
    );
};

export default RoomDetailPage;


