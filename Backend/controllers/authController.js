const authService = require('../services/authService.js');
const { generateToken } = require('../services/jwtService.js');
const User = require("../models/user.js")


/**
 * Signup controller
 * - Calls authService.signup which creates user and credentials
 * - Generates JWT token
 * - Sends token as cookie + json message
 */
exports.signup = async (req, res, next) => {
  try {
    const user = await authService.signup(req.body);

    // Generate token after signup
    const token = generateToken({ userId: user.userId })

    // Set as cookie (for web apps)
    res.cookie("jwt", token, {
      httpOnly: true,
      sameSite: "lax", // adjust for frontend/backend domains
      secure: false, // true if using HTTPS
      maxAge: 24 * 60 * 60 * 1000, // 1 day
    });

    res.status(201).json({ message: "Signup successful", user });
  } catch (err) {
    next(err);
  }
};

/**
 * Login for web (cookie-based)
 */
exports.loginWeb = async (req, res, next) => {
  try {
    const user = await authService.login(req.body); // returns user after password check
    console.log(user)
    const token = generateToken({ userId: user.userId });

    res.cookie("jwt", token, {
      httpOnly: true,
      sameSite: "lax",
      secure: false,
      maxAge: 24 * 60 * 60 * 1000,
    });

    res.json({ message: "Login successful" });
  } catch (err) {
    next(err);
  }
};

/**
 * Login for mobile (Bearer token response)
 */
exports.loginMobile = async (req, res, next) => {
  try {
    const user = await authService.login(req.body);

    const token = generateToken({ userId: user._id });

    res.json({ message: "Login successful", token });
  } catch (err) {
    next(err);
  }
};

/**
 * Logout (clear cookie)
 */
exports.logout = (req, res) => {
  res.clearCookie('jwt');
  res.json({ message: 'Logged out' });
};

/**
 * Get current user info
 */
exports.getMe = async (req, res, next) => {
  try {
    console.log()
    // Instead of findById, use findOne where userId matches
   
   const user = await User.findOne({ userId: req.user.userId }).select('-__v');

   console.log(user)

    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json(user);
  } catch (err) {
    next(err);
  }
};


