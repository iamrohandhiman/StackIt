const authService = require('../services/authService');

exports.signup = async (req, res, next) => {
  try {
    const result = await authService.signup(req.body);
    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

exports.loginWeb = async (req, res, next) => {
  try {
    const { token } = await authService.login(req.body);
    res.cookie('token', token, { httpOnly: true, secure: false });
    res.json({ message: 'Login successful' });
  } catch (err) {
    next(err);
  }
};

exports.loginMobile = async (req, res, next) => {
  try {
    const { token } = await authService.login(req.body);
    res.json({ token });
  } catch (err) {
    next(err);
  }
};

exports.logout = (req, res) => {
  res.clearCookie('token');
  res.json({ message: 'Logged out' });
};


exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.userId).select('-__v'); // exclude __v field
    if (!user) return res.status(404).json({ message: 'User not found' });

    res.json(user);
  } catch (err) {
    next(err);
  }
};
