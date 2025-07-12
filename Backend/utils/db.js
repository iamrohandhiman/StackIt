const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const dbUri = `${process.env.MONGO_URI_BASE}/${process.env.DB_NAME}`;
    await mongoose.connect(dbUri);
    console.log(`MongoDB Connected to ${process.env.DB_NAME}`);
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
