const { verifyToken } = require('../services/jwtService');

module.exports = (req, res, next) => {
  // ✅ Use the correct cookie key "jwt"
  const token = req.cookies.jwt || req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Unauthorized' });
  }

  try {
    const decoded = verifyToken(token);
    console.log(decoded)
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ message: 'Invalid token' });
  }
};
