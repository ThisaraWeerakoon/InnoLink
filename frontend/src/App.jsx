import React, { useRef , useState, useEffect } from "react";
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
import { useNavigate } from "react-router-dom";

function App() {
	//set to null
    const authUser = useRef(null);
    const setAuthUser = (newValue) => {
        authUser.current = newValue;
    };
    const navigate = useNavigate();

    // Assuming a user logs in, you set `authUser` and store the JWT:
    const handleLogin = (userData, token) => {
	
        setAuthUser(userData);
	
        localStorage.setItem("jwt", token);
        localStorage.setItem("userData",userData);
		console.log("authUser :", authUser.current);
        navigate("/");
    };
	
    const handleLogout = () => {
        setAuthUser(null);
        localStorage.removeItem("jwt");
        navigate("/");
    };
    

    return (
        <Layout onLogout={handleLogout}>
            <Routes>
                <Route path='/' element={authUser.current ? <HomePage authUser={authUser} /> : <Navigate to="/login" />} />
                <Route path='/signup' element={!authUser.current ? <SignUpPage /> : <Navigate to="/" />} />
                <Route path='/login' element={!authUser.current ? <LoginPage onLogin={handleLogin}/> : <Navigate to="/" />} />
                <Route path='/notifications' element={authUser.current ? <NotificationsPage /> : <Navigate to="/login" />} />
                <Route path='/network' element={authUser.current ? <NetworkPage /> : <Navigate to="/login" />} />
                <Route path='/post/:postId' element={authUser.current ? <PostPage /> : <Navigate to="/login" />} />
                <Route path='/profile/:username' element={authUser.current ? <ProfilePage /> : <Navigate to="/login" />} />
            </Routes>
            <Toaster />
        </Layout>
    );
}

export default App;
