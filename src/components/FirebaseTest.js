import React from 'react';
import { Box, Typography, Paper } from '@mui/material';

export default function FirebaseTest() {
    return (
        <Box p={3}>
            <Typography variant="h4" component="h1" sx={{ mb: 3 }}>
                Firebase Test
            </Typography>

            <Paper elevation={2} sx={{ p: 3 }}>
                <Typography variant="body1" color="text.secondary">
                    Tính năng Firebase sẽ được triển khai sau khi hệ thống cơ bản hoạt động ổn định.
                </Typography>
            </Paper>
        </Box>
    );
}
