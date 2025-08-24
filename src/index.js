import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { AuthProvider } from './context/AuthContext';
import { RoomsProvider } from './context/RoomsContext';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <React.StrictMode>
        <AuthProvider>
            <RoomsProvider>
                <App />
            </RoomsProvider>
        </AuthProvider>
    </React.StrictMode>
);
