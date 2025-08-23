// RoomDetailPage.jsx
import React, { useState } from "react";
import {
  AppBar,
  Toolbar,
  Typography,
  Container,
  Card,
  CardContent,
  Box,
  Divider,
  Switch,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Button,
} from "@mui/material";
import {
  Home,
  HomeOutlined,
  Build,
  Toys,
  Lightbulb,
  Thermostat,
  WaterDrop,
  LocalGasStation,
  MotionPhotosOn,
} from "@mui/icons-material";

const iconMap = {
  home: <Home />,
  home_outlined: <HomeOutlined />,
  build: <Build />,
};

function RoomDetailPage({ room }) {
  const [fanOn, setFanOn] = useState(false);
  const [lightOn, setLightOn] = useState(false);
  const [motionDetected, setMotionDetected] = useState(false);
  const [humidity, setHumidity] = useState(60);
  const [gasLevel, setGasLevel] = useState(120);

  return (
    <div>
      <AppBar position="static" sx={{ backgroundColor: room.color || "#1976d2" }}>
        <Toolbar>
          <Typography variant="h6">{room.name || "Chi tiết phòng"}</Typography>
        </Toolbar>
      </AppBar>
      <Container sx={{ mt: 3, mb: 3 }}>
        <Card sx={{ p: 3, borderRadius: 2 }}>
          <CardContent>
            <Box display="flex" alignItems="center" mb={3}>
              <Box mr={2} fontSize={40} color={room.color}>
                {iconMap[room.icon] || <Home />}
              </Box>
              <Typography variant="h5" fontWeight="bold">
                {room.name}
              </Typography>
            </Box>

            {/* Thông tin phòng */}
            <InfoRow label="Trạng thái:" value={room.status} />
            <InfoRow label="Giá phòng:" value={room.price} />
            <InfoRow label="Nhiệt độ:" value={room.temperature} />
            <InfoRow label="Độ ẩm:" value={`${humidity.toFixed(1)}%`} />
            <InfoRow label="Khí ga:" value={`${gasLevel.toFixed(1)} ppm`} />
            <InfoRow label="Người thuê:" value={room.occupant || "---"} />

            <Box my={3}>
              <Divider />
            </Box>

            {/* Điều khiển thiết bị */}
            <Typography variant="h6" mb={2}>
              Điều khiển thiết bị
            </Typography>
            <Box display="flex" alignItems="center" mb={1}>
              <Toys sx={{ color: fanOn ? "blue" : "grey", mr: 1 }} />
              <Typography>Quạt</Typography>
              <Box flexGrow={1} />
              <Switch checked={fanOn} onChange={(e) => setFanOn(e.target.checked)} />
            </Box>
            <Box display="flex" alignItems="center" mb={3}>
              <Lightbulb sx={{ color: lightOn ? "yellow" : "grey", mr: 1 }} />
              <Typography>Đèn</Typography>
              <Box flexGrow={1} />
              <Switch checked={lightOn} onChange={(e) => setLightOn(e.target.checked)} />
            </Box>

            <Box my={3}>
              <Divider />
            </Box>

            {/* Thông báo */}
            <Typography variant="h6" mb={2}>
              Thông báo
            </Typography>
            <List>
              <ListItem>
                <ListItemIcon>
                  <Thermostat sx={{ color: "red" }} />
                </ListItemIcon>
                <ListItemText primary={`Nhiệt độ hiện tại: ${room.temperature || "--"}`} />
              </ListItem>
              <ListItem>
                <ListItemIcon>
                  <WaterDrop sx={{ color: "blue" }} />
                </ListItemIcon>
                <ListItemText primary={`Độ ẩm hiện tại: ${humidity.toFixed(1)}%`} />
              </ListItem>
              <ListItem
                secondaryAction={
                  <Button
                    variant="contained"
                    onClick={() =>
                      setGasLevel((prev) => (prev > 200 ? 120 : 250))
                    }
                  >
                    Giả lập
                  </Button>
                }
              >
                <ListItemIcon>
                  <LocalGasStation sx={{ color: "orange" }} />
                </ListItemIcon>
                <ListItemText primary={`Khí ga hiện tại: ${gasLevel.toFixed(1)} ppm`} />
              </ListItem>
              <ListItem
                secondaryAction={
                  <Button
                    variant="contained"
                    onClick={() => setMotionDetected(!motionDetected)}
                  >
                    Giả lập
                  </Button>
                }
              >
                <ListItemIcon>
                  <MotionPhotosOn
                    sx={{ color: motionDetected ? "green" : "grey" }}
                  />
                </ListItemIcon>
                <ListItemText
                  primary={
                    motionDetected ? "Phát hiện chuyển động!" : "Không có chuyển động"
                  }
                />
              </ListItem>
            </List>
          </CardContent>
        </Card>
      </Container>
    </div>
  );
}

function InfoRow({ label, value }) {
  return (
    <Box display="flex" mb={1}>
      <Typography fontWeight={600} mr={1}>
        {label}
      </Typography>
      <Typography>{value}</Typography>
    </Box>
  );
}

export default RoomDetailPage;
