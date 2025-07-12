require('dotenv').config();
const express = require('express');
const cookieParser = require('cookie-parser');
const morgan = require('morgan');
const cors = require('cors'); // 🆕 import cors

const connectDB = require('./utils/db');
const authRoutes = require('./routes/authRoutes');
const errorHandler = require('./middleware/errorHandler');
const questionRoutes = require('./routes/questionRoutes');

const app = express();
connectDB();

// 🔐 CORS configuration
const allowedOrigins = [
  'http://localhost:5173', 
  'http://localhost:3000', 
  'http://127.0.0.1:5173', 
  'http://localhost:8081', 
  'http://localhost:8080', 
  'http://localhost:5000',
  'http://192.168.0.106:5000'
];

app.use(cors({
  origin: allowedOrigins,
  credentials: true, 
}));

app.use(morgan('dev')); 
app.use(express.json());
app.use(cookieParser());

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1', questionRoutes);

app.get('/health', (req, res) => {
  res.send("okay");
});

app.use(errorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
