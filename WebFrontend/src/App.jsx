import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Home from './pages/Home';
import Signup from './pages/Signup';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Question from './pages/Question';
import Profile from './pages/Profile';
import CreateQuestion from './pages/CreateQuestion';
import './App.css'; // ✅ Fixed typo here

function App() {
  return (
    <div >

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/signup" element={<Signup />} />
        <Route path="/login" element={<Login />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/questions/:id" element={<Question />} />
        <Route path="/profile" element={<Profile />} />
        <Route path="/create-question" element={<CreateQuestion />} />
      </Routes>
     
    </div>
  );
}

export default App;
