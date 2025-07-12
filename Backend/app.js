require('dotenv').config();
const express = require('express');
const cookieParser = require('cookie-parser');
const morgan = require('morgan'); 

const connectDB = require('./utils/db');
const authRoutes = require('./routes/authRoutes');
const errorHandler = require('./middleware/errorHandler');
const questionRoutes = require('./routes/questionRoutes');


const app = express();
connectDB();


app.use(morgan('dev')); 
app.use(express.json());
app.use(cookieParser());

app.use('/api/v1/auth', authRoutes);

app.use('/api/v1', questionRoutes);


app.get('/health',(req,res)=>{
  res.send("okay")
})

app.use('/api/v1', questionRoutes);


app.use(errorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
