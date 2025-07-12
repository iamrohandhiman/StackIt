const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/signup', authController.signup);
router.post('/login/web', authController.loginWeb);
router.post('/login/mobile', authController.loginMobile);
router.post('/logout', authController.logout);

module.exports = router;
