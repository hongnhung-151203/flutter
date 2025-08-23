// HomePage.jsx
import React, { useState } from "react";
import {
  AppBar,
  Toolbar,
  Typography,
  Container,
  Grid,
  Card,
  CardContent,
  IconButton,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  TextField,
  DialogActions,
  MenuItem,
  Box,
  Badge,
} from "@mui/material";
import {
  Home,
  HomeOutlined,
  Build,
  People,
  DoorFront,
  Add,
  Thermostat,
  ArrowForwardIos,
} from "@mui/icons-material";

function HomePage() {
  const [rooms, setRooms] = useState([
    {
      name: "Phòng 101",
      status: "Có người",
      temperature: "26°C",
      color: "#4CAF50",
      icon: "home",
      occupant: "Nguyễn Văn A",
      price: "3.500.000 VND/tháng",
    },
    {
      name: "Phòng 102",
      status: "Trống",
      temperature: "24°C",
      color: "#9E9E9E",
      icon: "home_outlined",
      occupant: null,
      price: "3.200.000 VND/tháng",
    },
    {
      name: "Phòng 103",
      status: "Có người",
      temperature: "27°C",
      color: "#4CAF50",
      icon: "home",
      occupant: "Trần Thị B",
      price: "3.800.000 VND/tháng",
    },
    {
      name: "Phòng 104",
      status: "Bảo trì",
      temperature: "25°C",
      color: "#FF9800",
      icon: "build",
      occupant: null,
      price: "3.500.000 VND/tháng",
    },
  ]);

  const [openDialog, setOpenDialog] = useState(false);
  const [newRoom, setNewRoom] = useState({
    name: "",
    price: "",
    status: "Trống",
    temperature: "25°C",
    occupant: "",
  });

  const handleAddRoom = () => {
    const colorMap = {
      "Trống": "#9E9E9E",
      "Có người": "#4CAF50",
      "Bảo trì": "#FF9800",
    };
    const iconMap = {
      "Trống": "home_outlined",
      "Có người": "home",
      "Bảo trì": "build",
    };
    setRooms([
      ...rooms,
      {
        ...newRoom,
        color: colorMap[newRoom.status],
        icon: iconMap[newRoom.status],
        occupant: newRoom.status === "Có người" ? newRoom.occupant : null,
      },
    ]);
    setOpenDialog(false);
    setNewRoom({ name: "", price: "", status: "Trống", temperature: "25°C", occupant: "" });
  };

  const handleDeleteRoom = (index) => {
    if (window.confirm(`Bạn có chắc muốn xóa ${rooms[index].name}?`)) {
      const updated = [...rooms];
      updated.splice(index, 1);
      setRooms(updated);
      alert("Đã xóa phòng thành công!");
    }
  };

  const iconMap = {
    home: <Home />,
    home_outlined: <HomeOutlined />,
    build: <Build />,
  };

  return (
    <div>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6">Quản lý nhà trọ</Typography>
        </Toolbar>
      </AppBar>
      <Container sx={{ mt: 3 }}>
        <Grid container spacing={2}>
          <Grid item xs={4}>
            <StatCard title="Tổng phòng" value={rooms.length} icon={<Home />} color="#4A90E2" />
          </Grid>
          <Grid item xs={4}>
            <StatCard
              title="Đã thuê"
              value={rooms.filter((r) => r.status === "Có người").length}
              icon={<People />}
              color="#4CAF50"
            />
          </Grid>
          <Grid item xs={4}>
            <StatCard
              title="Trống"
              value={rooms.filter((r) => r.status === "Trống").length}
              icon={<DoorFront />}
              color="#9E9E9E"
            />
          </Grid>
        </Grid>

        <Box mt={4}>
          <Typography variant="h5" mb={2}>
            Danh sách phòng
          </Typography>
          <Grid container spacing={2}>
            {rooms.map((room, index) => (
              <Grid item xs={12} key={index}>
                <Card
                  sx={{ display: "flex", alignItems: "center", p: 2 }}
                  onClick={() => alert(`Chi tiết ${room.name}`)}
                  onContextMenu={(e) => {
                    e.preventDefault();
                    handleDeleteRoom(index);
                  }}
                >
                  <Box
                    sx={{
                      width: 60,
                      height: 60,
                      borderRadius: "50%",
                      backgroundColor: room.color + "33",
                      display: "flex",
                      alignItems: "center",
                      justifyContent: "center",
                      mr: 2,
                    }}
                  >
                    {iconMap[room.icon]}
                  </Box>
                  <Box sx={{ flexGrow: 1 }}>
                    <Typography variant="h6">{room.name}</Typography>
                    {room.occupant && (
                      <Typography variant="body2" color="text.secondary">
                        {room.occupant}
                      </Typography>
                    )}
                    <Typography variant="body2" color="success.main">
                      {room.price}
                    </Typography>
                    <Box sx={{ display: "flex", alignItems: "center", mt: 1 }}>
                      <Box
                        sx={{
                          px: 1,
                          py: 0.5,
                          borderRadius: 1,
                          backgroundColor: room.color + "33",
                        }}
                      >
                        <Typography variant="caption" sx={{ color: room.color }}>
                          {room.status}
                        </Typography>
                      </Box>
                      <Box sx={{ flexGrow: 1 }} />
                      <Thermostat sx={{ fontSize: 16, color: "#7F8C8D", mr: 0.5 }} />
                      <Typography variant="caption" color="text.secondary">
                        {room.temperature}
                      </Typography>
                    </Box>
                  </Box>
                  <ArrowForwardIos sx={{ fontSize: 16, color: "#BDC3C7" }} />
                </Card>
              </Grid>
            ))}
          </Grid>
        </Box>
      </Container>

      <Button
        variant="contained"
        color="primary"
        sx={{ position: "fixed", bottom: 24, right: 24 }}
        startIcon={<Add />}
        onClick={() => setOpenDialog(true)}
      >
        Thêm phòng
      </Button>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)}>
        <DialogTitle>Thêm phòng mới</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Tên phòng"
            fullWidth
            value={newRoom.name}
            onChange={(e) => setNewRoom({ ...newRoom, name: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Giá phòng"
            fullWidth
            value={newRoom.price}
            onChange={(e) => setNewRoom({ ...newRoom, price: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Nhiệt độ"
            fullWidth
            value={newRoom.temperature}
            onChange={(e) => setNewRoom({ ...newRoom, temperature: e.target.value })}
          />
          <TextField
            margin="dense"
            select
            label="Trạng thái"
            fullWidth
            value={newRoom.status}
            onChange={(e) => setNewRoom({ ...newRoom, status: e.target.value })}
          >
            {["Trống", "Có người", "Bảo trì"].map((status) => (
              <MenuItem key={status} value={status}>
                {status}
              </MenuItem>
            ))}
          </TextField>
          {newRoom.status === "Có người" && (
            <TextField
              margin="dense"
              label="Người thuê"
              fullWidth
              value={newRoom.occupant}
              onChange={(e) => setNewRoom({ ...newRoom, occupant: e.target.value })}
            />
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Hủy</Button>
          <Button
            variant="contained"
            onClick={handleAddRoom}
            disabled={!newRoom.name || !newRoom.price}
          >
            Thêm
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
}

function StatCard({ title, value, icon, color }) {
  return (
    <Card>
      <CardContent sx={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
        <Box sx={{ color: color, mb: 1 }}>{icon}</Box>
        <Typography variant="h5">{value}</Typography>
        <Typography variant="body2" color="text.secondary">
          {title}
        </Typography>
      </CardContent>
    </Card>
  );
}

export default HomePage;
