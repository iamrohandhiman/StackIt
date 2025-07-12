const jwt = require('jsonwebtoken');

exports.generateToken = (credentialsId) => {
  console.log(credentialsId)
  return jwt.sign(
    { userId: credentialsId.userId }, 
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

exports.verifyToken = (token) => {
  return jwt.verify(token, process.env.JWT_SECRET);
};
