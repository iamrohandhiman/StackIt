import React, { useState } from 'react';
import { signup } from '../api/api';

function Signup() {
  const [form, setForm] = useState({ name: '', email: '', password: '' });

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const res = await signup(form);
      console.log(res.data);
      alert('Signup successful');
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.message || 'Error');
    }
  };

  return (
    <div>
      <h2>Signup</h2>
      <form onSubmit={handleSubmit}>
        <input placeholder="Name" onChange={e => setForm({ ...form, name: e.target.value })} /><br/>
        <input placeholder="Email" onChange={e => setForm({ ...form, email: e.target.value })} /><br/>
        <input type="password" placeholder="Password" onChange={e => setForm({ ...form, password: e.target.value })} /><br/>
        <button type="submit">Signup</button>
      </form>
    </div>
  );
}

export default Signup;
