import React from 'react';
import {
    Box,
    Typography,
    Paper,
} from '@mui/material';

export default function UserManagement() {
    return (
        <Box p={3}>
            <Typography variant="h4" component="h1" sx={{ mb: 3 }}>
                Quản lý người dùng
            </Typography>

            <Paper elevation={2} sx={{ p: 3 }}>
                <Typography variant="body1" color="text.secondary">
                    Tính năng quản lý người dùng sẽ được triển khai sau khi hệ thống cơ bản hoạt động ổn định.
                </Typography>
            </Paper>
        </Box>
    );
}
