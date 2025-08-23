import React, { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    AppBar,
    Toolbar,
    Typography,
    Container,
    Grid,
    Card,
    CardContent,
    CardActions,
    Button,
    IconButton,
    Box,
    Chip,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    TextField,
    FormControl,
    InputLabel,
    Select,
    MenuItem,
    Fab,
    Snackbar,
    Alert,
} from '@mui/material';
import {
    Home as HomeIcon,
    HomeOutlined as HomeOutlinedIcon,
    Build as BuildIcon,
    People as PeopleIcon,
    DoorFront as DoorFrontIcon,
    Add as AddIcon,
    Delete as DeleteIcon,
    Edit as EditIcon,
} from '@mui/icons-material';
import GasMeterIcon from '@mui/icons-material/GasMeter';
import SensorsIcon from '@mui/icons-material/Sensors';
import OpacityIcon from '@mui/icons-material/Opacity';
import { useRooms } from '../context/RoomsContext';
import { useAuth } from '../context/AuthContext';

const HomePage = () => {
    const navigate = useNavigate();
    const { rooms, addRoom, deleteRoom, getEmptyCount, getOccupiedCount } = useRooms();
    const { isLandlord, tenantRoomId } = useAuth();

    const [openAddDialog, setOpenAddDialog] = useState(false);
    const [openDeleteDialog, setOpenDeleteDialog] = useState(false);
    const [roomToDelete, setRoomToDelete] = useState(null);
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
    const [newRoom, setNewRoom] = useState({
        name: '',
        status: 'Trống',
        temperature: '',
        price: '',
        occupant: '',
    });

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

    const getStatusIcon = (icon) => {
        switch (icon) {
            case 'home':
                return <HomeIcon />;
            case 'homeOutlined':
                return <HomeOutlinedIcon />;
            case 'build':
                return <BuildIcon />;
            default:
                return <HomeIcon />;
        }
    };

    const handleAddRoom = () => {
        if (newRoom.name && newRoom.temperature && newRoom.price) {
            addRoom(newRoom);
            setNewRoom({ name: '', status: 'Trống', temperature: '', price: '', occupant: '' });
            setOpenAddDialog(false);
            setSnackbar({ open: true, message: 'Đã thêm phòng thành công!', severity: 'success' });
        }
    };

    const handleDeleteRoom = () => {
        if (roomToDelete !== null) {
            deleteRoom(roomToDelete);
            setOpenDeleteDialog(false);
            setRoomToDelete(null);
            setSnackbar({ open: true, message: 'Đã xóa phòng thành công!', severity: 'success' });
        }
    };

    const confirmDelete = (room) => {
        setRoomToDelete(room.id);
        setOpenDeleteDialog(true);
    };

    const visibleRooms = useMemo(
        () => (isLandlord ? rooms : rooms.filter(r => r.id === tenantRoomId)),
        [isLandlord, rooms, tenantRoomId]
    );

    const totalGasAlerts = useMemo(() => visibleRooms.filter(r => r.gasAlert).length, [visibleRooms]);
    const totalMotion = useMemo(() => visibleRooms.filter(r => r.motionDetected).length, [visibleRooms]);
    const averageHumidity = useMemo(
        () => (
            visibleRooms.length
                ? Math.round(
                    visibleRooms.reduce((acc, r) => acc + (Number(r.humidity) || 0), 0) / visibleRooms.length
                )
                : 0
        ),
        [visibleRooms]
    );

    return (
        <Box sx={{ flexGrow: 1 }}>
            <AppBar position="static" elevation={0}>
                <Toolbar>
                    <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                        Quản lý nhà trọ
                    </Typography>
                </Toolbar>
            </AppBar>

            <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
                {/* Header with gradient background */}
                <Box
                    sx={{
                        background: 'linear-gradient(135deg, #4A90E2 0%, #357ABD 50%, #1E3A8A 100%)',
                        borderRadius: 4,
                        p: 4,
                        mb: 4,
                        color: 'white',
                        position: 'relative',
                        overflow: 'hidden',
                    }}
                >
                    <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 2 }}>
                        Quản lý nhà trọ
                    </Typography>
                    <Typography variant="body1" sx={{ opacity: 0.9 }}>
                        Hệ thống quản lý thông minh cho nhà trọ của bạn
                    </Typography>

                    {/* Decorative circles */}
                    <Box
                        sx={{
                            position: 'absolute',
                            top: 50,
                            right: -50,
                            width: 200,
                            height: 200,
                            borderRadius: '50%',
                            backgroundColor: 'rgba(255,255,255,0.1)',
                        }}
                    />
                    <Box
                        sx={{
                            position: 'absolute',
                            bottom: -30,
                            left: -30,
                            width: 150,
                            height: 150,
                            borderRadius: '50%',
                            backgroundColor: 'rgba(255,255,255,0.08)',
                        }}
                    />
                </Box>

                {/* Statistics Cards */}
                <Grid container spacing={3} sx={{ mb: 4 }}>
                    <Grid item xs={12} sm={4}>
                        <Card sx={{ textAlign: 'center', py: 2 }}>
                            <CardContent>
                                <HomeIcon sx={{ fontSize: 40, color: 'primary.main', mb: 1 }} />
                                <Typography variant="h4" color="primary" sx={{ fontWeight: 'bold' }}>
                                    {visibleRooms.length}
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
                                <PeopleIcon sx={{ fontSize: 40, color: 'secondary.main', mb: 1 }} />
                                <Typography variant="h4" color="secondary" sx={{ fontWeight: 'bold' }}>
                                    {isLandlord ? getOccupiedCount() : visibleRooms.filter(r => r.status === 'Có người').length}
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
                                <DoorFrontIcon sx={{ fontSize: 40, color: 'text.secondary', mb: 1 }} />
                                <Typography variant="h4" color="text.secondary" sx={{ fontWeight: 'bold' }}>
                                    {isLandlord ? getEmptyCount() : visibleRooms.filter(r => r.status === 'Trống').length}
                                </Typography>
                                <Typography variant="body2" color="text.secondary">
                                    Trống
                                </Typography>
                            </CardContent>
                        </Card>
                    </Grid>
                    <Grid item xs={12} sm={4}>
                        <Card sx={{ textAlign: 'center', py: 2 }}>
                            <CardContent>
                                <GasMeterIcon sx={{ fontSize: 40, color: totalGasAlerts ? 'error.main' : 'text.secondary', mb: 1 }} />
                                <Typography variant="h4" color={totalGasAlerts ? 'error' : 'text.secondary'} sx={{ fontWeight: 'bold' }}>
                                    {totalGasAlerts}
                                </Typography>
                                <Typography variant="body2" color="text.secondary">
                                    Cảnh báo khí ga
                                </Typography>
                            </CardContent>
                        </Card>
                    </Grid>
                    <Grid item xs={12} sm={4}>
                        <Card sx={{ textAlign: 'center', py: 2 }}>
                            <CardContent>
                                <SensorsIcon sx={{ fontSize: 40, color: totalMotion ? 'warning.main' : 'text.secondary', mb: 1 }} />
                                <Typography variant="h4" color={totalMotion ? 'warning' : 'text.secondary'} sx={{ fontWeight: 'bold' }}>
                                    {totalMotion}
                                </Typography>
                                <Typography variant="body2" color="text.secondary">
                                    Chuyển động phát hiện
                                </Typography>
                            </CardContent>
                        </Card>
                    </Grid>
                    <Grid item xs={12} sm={4}>
                        <Card sx={{ textAlign: 'center', py: 2 }}>
                            <CardContent>
                                <OpacityIcon sx={{ fontSize: 40, color: 'info.main', mb: 1 }} />
                                <Typography variant="h4" color={'info.main'} sx={{ fontWeight: 'bold' }}>
                                    {averageHumidity}%
                                </Typography>
                                <Typography variant="body2" color="text.secondary">
                                    Độ ẩm trung bình
                                </Typography>
                            </CardContent>
                        </Card>
                    </Grid>
                </Grid>

                {/* Room List Header */}
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                    <Typography variant="h5" sx={{ fontWeight: 'bold', color: '#2C3E50' }}>
                        Danh sách phòng
                    </Typography>
                </Box>

                {/* Room List */}
                <Grid container spacing={3}>
                    {visibleRooms.map((room) => {
                        console.log(`🎨 Rendering room ${room.name}:`, room);
                        return (
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
                                        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
                                            <Box
                                                sx={{
                                                    color: room.color,
                                                    mr: 2,
                                                    display: 'flex',
                                                    alignItems: 'center',
                                                }}
                                            >
                                                {getStatusIcon(room.icon)}
                                            </Box>
                                            <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                                                {room.name}
                                            </Typography>
                                        </Box>

                                        <Box sx={{ mb: 2 }}>
                                            <Chip
                                                label={room.status}
                                                size="small"
                                                sx={{
                                                    backgroundColor: room.color,
                                                    color: 'white',
                                                    fontWeight: 'bold',
                                                    mb: 1,
                                                }}
                                            />
                                        </Box>

                                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                            Nhiệt độ: {room.temperature}
                                        </Typography>
                                        <Typography variant="body2" color={room.gasAlert ? 'error.main' : 'text.secondary'} sx={{ mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                                            <GasMeterIcon fontSize="small" /> Khí ga: {room.gasAlert ? 'CẢNH BÁO' : 'Bình thường'}
                                        </Typography>
                                        <Typography variant="body2" color={room.motionDetected ? 'warning.main' : 'text.secondary'} sx={{ mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                                            <SensorsIcon fontSize="small" /> Chuyển động: {room.motionDetected ? 'Có' : 'Không'}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                                            <OpacityIcon fontSize="small" /> Độ ẩm: {room.humidity}%
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                            Giá: {room.price}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary">
                                            Người thuê: {room.occupant || '---'}
                                        </Typography>
                                    </CardContent>

                                    {isLandlord && (
                                        <CardActions sx={{ justifyContent: 'space-between', px: 2, pb: 2 }}>
                                            <Button
                                                size="small"
                                                startIcon={<EditIcon />}
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    // Handle edit
                                                }}
                                            >
                                                Sửa
                                            </Button>
                                            <Button
                                                size="small"
                                                color="error"
                                                startIcon={<DeleteIcon />}
                                                onClick={(e) => {
                                                    e.stopPropagation();
                                                    confirmDelete(room);
                                                }}
                                            >
                                                Xóa
                                            </Button>
                                        </CardActions>
                                    )}
                                </Card>
                            </Grid>
                        );
                    })}
                </Grid>

                {/* Add Room FAB */}
                {isLandlord && (
                    <Fab
                        color="primary"
                        aria-label="add"
                        sx={{ position: 'fixed', bottom: 24, right: 24 }}
                        onClick={() => setOpenAddDialog(true)}
                    >
                        <AddIcon />
                    </Fab>
                )}

                {/* Add Room Dialog */}
                {isLandlord && (
                    <Dialog open={openAddDialog} onClose={() => setOpenAddDialog(false)} maxWidth="sm" fullWidth>
                        <DialogTitle>Thêm phòng mới</DialogTitle>
                        <DialogContent>
                            <Grid container spacing={2} sx={{ mt: 1 }}>
                                <Grid item xs={12}>
                                    <TextField
                                        fullWidth
                                        label="Tên phòng"
                                        value={newRoom.name}
                                        onChange={(e) => setNewRoom({ ...newRoom, name: e.target.value })}
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <FormControl fullWidth>
                                        <InputLabel>Trạng thái</InputLabel>
                                        <Select
                                            value={newRoom.status}
                                            label="Trạng thái"
                                            onChange={(e) => setNewRoom({ ...newRoom, status: e.target.value })}
                                        >
                                            <MenuItem value="Trống">Trống</MenuItem>
                                            <MenuItem value="Có người">Có người</MenuItem>
                                            <MenuItem value="Bảo trì">Bảo trì</MenuItem>
                                        </Select>
                                    </FormControl>
                                </Grid>
                                <Grid item xs={6}>
                                    <TextField
                                        fullWidth
                                        label="Nhiệt độ"
                                        value={newRoom.temperature}
                                        onChange={(e) => setNewRoom({ ...newRoom, temperature: e.target.value })}
                                        placeholder="26°C"
                                    />
                                </Grid>
                                <Grid item xs={6}>
                                    <TextField
                                        fullWidth
                                        label="Giá phòng"
                                        value={newRoom.price}
                                        onChange={(e) => setNewRoom({ ...newRoom, price: e.target.value })}
                                        placeholder="3.500.000 VND/tháng"
                                    />
                                </Grid>
                                <Grid item xs={12}>
                                    <TextField
                                        fullWidth
                                        label="Người thuê (nếu có)"
                                        value={newRoom.occupant}
                                        onChange={(e) => setNewRoom({ ...newRoom, occupant: e.target.value })}
                                        placeholder="Để trống nếu chưa có người thuê"
                                    />
                                </Grid>
                            </Grid>
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={() => setOpenAddDialog(false)}>Hủy</Button>
                            <Button onClick={handleAddRoom} variant="contained">Thêm phòng</Button>
                        </DialogActions>
                    </Dialog>
                )}

                {/* Delete Confirmation Dialog */}
                {isLandlord && (
                    <Dialog open={openDeleteDialog} onClose={() => setOpenDeleteDialog(false)}>
                        <DialogTitle>Xác nhận xóa</DialogTitle>
                        <DialogContent>
                            <Typography>
                                Bạn có chắc muốn xóa phòng này?
                            </Typography>
                        </DialogContent>
                        <DialogActions>
                            <Button onClick={() => setOpenDeleteDialog(false)}>Hủy</Button>
                            <Button onClick={handleDeleteRoom} color="error" variant="contained">
                                Xóa
                            </Button>
                        </DialogActions>
                    </Dialog>
                )}

                {/* Snackbar */}
                <Snackbar
                    open={snackbar.open}
                    autoHideDuration={3000}
                    onClose={() => setSnackbar({ ...snackbar, open: false })}
                >
                    <Alert severity={snackbar.severity} sx={{ width: '100%' }}>
                        {snackbar.message}
                    </Alert>
                </Snackbar>
            </Container>
        </Box>
    );
};

export default HomePage;
