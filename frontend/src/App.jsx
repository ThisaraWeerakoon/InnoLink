import React, { useState, useEffect } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import Layout from "./components/layout/Layout";
import HomePage from "./pages/HomePage";
import LoginPage from "./pages/auth/LoginPage";
import SignUpPage from "./pages/auth/SignUpPage";
import toast, { Toaster } from "react-hot-toast";
import NotificationsPage from "./pages/NotificationsPage";
import NetworkPage from "./pages/NetworkPage";
import PostPage from "./pages/PostPage";
import ProfilePage from "./pages/ProfilePage";

function App() {
	//set to null
    const [authUser, setAuthUser] = useState(null);

    // Assuming a user logs in, you set `authUser` and store the JWT:
    const handleLogin = (userData, token) => {
        setAuthUser(userData);
        localStorage.setItem("jwt", token);
    };

    const handleLogout = () => {
        setAuthUser(null);
        localStorage.removeItem("jwt");
    };

    return (
        <Layout>
            <Routes>
                <Route path='/' element={authUser ? <HomePage /> : <Navigate to="/login" />} />
                <Route path='/signup' element={!authUser ? <SignUpPage /> : <Navigate to="/" />} />
                <Route path='/login' element={!authUser ? <LoginPage onLogin={handleLogin} /> : <Navigate to="/" />} />
                <Route path='/notifications' element={authUser ? <NotificationsPage /> : <Navigate to="/login" />} />
                <Route path='/network' element={authUser ? <NetworkPage /> : <Navigate to="/login" />} />
                <Route path='/post/:postId' element={authUser ? <PostPage /> : <Navigate to="/login" />} />
                <Route path='/profile/:username' element={authUser ? <ProfilePage /> : <Navigate to="/login" />} />
            </Routes>
            <Toaster />
        </Layout>
    );
}

export default App;
