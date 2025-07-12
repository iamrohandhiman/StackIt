const express = require('express');
const router = express.Router();
const questionController = require('../controllers/questionController');
const authMiddleware = require('../middleware/authMiddleware');

//  Only authenticated users can create questions
router.post('/questions', authMiddleware, questionController.createQuestion);

// Only authenticated users can add answers
router.post('/questions/:questionId/answers', authMiddleware, questionController.addAnswer);

// Only authenticated users can upvote answers
router.post('/answers/:answerId/upvote', authMiddleware, questionController.upvoteAnswer);

//  Only authenticated users can downvote answers
router.post('/answers/:answerId/downvote', authMiddleware, questionController.downvoteAnswer);



// Get all questions (populated)
router.get('/questions', questionController.getAllQuestions);

// Search questions
router.get('/questions/search', questionController.searchQuestions);

// Get single question by ID (populated)
router.get('/questions/:questionId', questionController.getQuestionById);

// Get paginated questions with sorting (dashboard)
router.get('/dashboard/questions', questionController.getQuestionsPaginated);

module.exports = router;
