import React, { useState } from 'react';
import { loginWeb } from '../api/api';

function Login() {
  const [form, setForm] = useState({ email: '', password: '' });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await loginWeb(form);
      console.log(res.data);
      alert('Login successful');
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.message || 'Error');
    }
  };

  return (
    <div>
      <h2>Login</h2>
      <form onSubmit={handleSubmit}>
        <input placeholder="Email" onChange={e => setForm({ ...form, email: e.target.value })} /><br/>
        <input type="password" placeholder="Password" onChange={e => setForm({ ...form, password: e.target.value })} /><br/>
        <button type="submit">Login</button>
      </form>
    </div>
  );
}

export default Login;
