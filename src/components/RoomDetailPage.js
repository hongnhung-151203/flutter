import React from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
    AppBar,
    Toolbar,
    IconButton,
    Typography,
    Container,
    Card,
    CardContent,
    Grid,
    Chip,
    Box,
    Button,
    Switch,
    FormControlLabel,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import HomeIcon from '@mui/icons-material/Home';
import PeopleIcon from '@mui/icons-material/People';
import ThermostatIcon from '@mui/icons-material/Thermostat';
import GasMeterIcon from '@mui/icons-material/GasMeter';
import SensorsIcon from '@mui/icons-material/Sensors';
import OpacityIcon from '@mui/icons-material/Opacity';
import LightModeIcon from '@mui/icons-material/LightMode';
import AirIcon from '@mui/icons-material/Air';
import { useRooms } from '../context/RoomsContext';
import { useAuth } from '../context/AuthContext';

const RoomDetailPage = () => {
    const navigate = useNavigate();
    const { id } = useParams();
    const { getRoomById, updateRoom } = useRooms();
    const { canControlRoom, isLandlord, tenantRoomId } = useAuth();
    const room = getRoomById(id);

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

    if (!room) {
        return (
            <Box sx={{ p: 3 }}>
                <Typography>Không tìm thấy phòng.</Typography>
                <Button onClick={() => navigate('/')}>Về trang chủ</Button>
            </Box>
        );
    }

    const canControl = canControlRoom(room.id);
    const canView = isLandlord || (String(tenantRoomId) === String(room.id));

    if (!canView) {
        return (
            <Box sx={{ p: 3 }}>
                <Typography>Bạn không có quyền xem phòng này.</Typography>
                <Button onClick={() => navigate('/')}>Về trang chủ</Button>
            </Box>
        );
    }

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
                </Toolbar>
            </AppBar>

            <Container maxWidth="md" sx={{ mt: 4, mb: 4 }}>
                <Card>
                    <CardContent>
                        <Typography variant="h5" sx={{ fontWeight: 'bold', mb: 2 }}>
                            {room.name}
                        </Typography>

                        <Grid container spacing={2} sx={{ mb: 2 }}>
                            <Grid item xs={12} sm={6}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <HomeIcon color="primary" />
                                    <Typography>Giá: {room.price}</Typography>
                                </Box>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <ThermostatIcon color="secondary" />
                                    <Typography>Nhiệt độ: {room.temperature}</Typography>
                                </Box>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <PeopleIcon color="action" />
                                    <Typography>Người thuê: {room.occupant || '---'}</Typography>
                                </Box>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Chip
                                    label={room.status}
                                    sx={{ backgroundColor: getStatusColor(room.status), color: 'white', fontWeight: 'bold' }}
                                />
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <GasMeterIcon color={room.gasAlert ? 'error' : 'disabled'} />
                                    <Typography>Khí ga: {room.gasAlert ? 'CẢNH BÁO' : 'Bình thường'}</Typography>
                                </Box>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <SensorsIcon color={room.motionDetected ? 'warning' : 'disabled'} />
                                    <Typography>Chuyển động: {room.motionDetected ? 'Có' : 'Không'}</Typography>
                                </Box>
                            </Grid>
                            <Grid item xs={12} sm={6}>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <OpacityIcon color='info' />
                                    <Typography>Độ ẩm: {room.humidity}%</Typography>
                                </Box>
                            </Grid>
                        </Grid>

                        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center', mb: 2 }}>
                            <Button variant="contained" onClick={() => navigate(`/`)}>Về trang chủ</Button>
                            <Button variant="outlined" onClick={() => navigate(-1)}>Quay lại</Button>
                        </Box>

                        {/* Device controls with role-based permission */}
                        <Box sx={{ display: 'flex', gap: 4, alignItems: 'center' }}>
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={!!room.lightOn}
                                        onChange={(e) => updateRoom(room.id, { lightOn: e.target.checked })}
                                        disabled={!canControl}
                                    />
                                }
                                label={<Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}><LightModeIcon /> Đèn</Box>}
                            />
                            <FormControlLabel
                                control={
                                    <Switch
                                        checked={!!room.fanOn}
                                        onChange={(e) => updateRoom(room.id, { fanOn: e.target.checked })}
                                        disabled={!canControl}
                                    />
                                }
                                label={<Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}><AirIcon /> Quạt</Box>}
                            />
                            {!canControl && (
                                <Typography variant="body2" color="text.secondary">
                                    Bạn không có quyền điều khiển phòng này.
                                </Typography>
                            )}
                        </Box>
                    </CardContent>
                </Card>
            </Container>
        </Box>
    );
};

export default RoomDetailPage;


