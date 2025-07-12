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
