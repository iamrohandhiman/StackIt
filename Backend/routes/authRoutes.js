const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController.js');
const authMiddleware = require('../middleware/authMiddleware.js');


router.post('/signup', authController.signup);
router.post('/login/web', authController.loginWeb);
router.post('/login/mobile', authController.loginMobile);
router.post('/logout', authController.logout);
router.get('/me', authMiddleware, authController.getMe);

module.exports = router;
