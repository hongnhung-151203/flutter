// index.jsx
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import HomePage from "./screens/HomePage";
import RoomDetailPage from "./screens/RoomDetailPage";

// App component
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/room/:roomIndex" element={<RoomDetailPageWrapper />} />
      </Routes>
    </BrowserRouter>
  );
}

// Wrapper để truyền dữ liệu phòng vào RoomDetailPage
import roomsData from "./data/rooms"; // giả sử bạn lưu dữ liệu phòng ở đây

function RoomDetailPageWrapper() {
  const { useParams } = require("react-router-dom");
  const { roomIndex } = useParams();
  const room = roomsData[parseInt(roomIndex, 10)];
  return <RoomDetailPage room={room} />;
}

// Render App
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(<App />);
