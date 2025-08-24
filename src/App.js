import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import HomePage from './components/HomePage';
import RoomDetailPage from './components/RoomDetailPage';
import RoleSwitcher from './components/RoleSwitcher';
import { AppBar, Toolbar, Box } from '@mui/material';
import FirebaseTest from "./components/FirebaseTest";
import UserManagement from './components/UserManagement';

const theme = createTheme({
    palette: {
        primary: {
            main: '#4A90E2',
            light: '#7BB3F0',
            dark: '#357ABD',
        },
        secondary: {
            main: '#4CAF50',
            light: '#81C784',
            dark: '#388E3C',
        },
        background: {
            default: '#f5f5f5',
        },
    },
    typography: {
        fontFamily: 'Roboto, Arial, sans-serif',
        h4: {
            fontWeight: 600,
        },
        h6: {
            fontWeight: 500,
        },
    },
    components: {
        MuiCard: {
            styleOverrides: {
                root: {
                    borderRadius: 16,
                    boxShadow: '0 4px 20px rgba(0,0,0,0.1)',
                },
            },
        },
        MuiButton: {
            styleOverrides: {
                root: {
                    borderRadius: 12,
                    textTransform: 'none',
                    fontWeight: 500,
                },
            },
        },
    },
});

function App() {
    return (
        <ThemeProvider theme={theme}>
            <CssBaseline />
            <Router>
                <AppBar position="sticky" elevation={0} color="transparent">
                    <Toolbar>
                        <Box sx={{ flexGrow: 1 }} />
                        <RoleSwitcher />
                    </Toolbar>
                </AppBar>
                <Routes>
                    <Route path="/" element={<HomePage />} />
                    <Route path="/room/:id" element={<RoomDetailPage />} />
                    <Route path="/firebase-test" element={<FirebaseTest />} />
                    <Route path="/users" element={<UserManagement />} />
                </Routes>
            </Router>
        </ThemeProvider>
    );
}

export default App;
