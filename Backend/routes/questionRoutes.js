const express = require('express');
const router = express.Router();
const questionController = require('../controllers/questionController');
const authMiddleware = require('../middleware/authMiddleware');

// Create a question
router.post('/questions', questionController.createQuestion);

// Add an answer to a question
router.post('/questions/:questionId/answers', questionController.addAnswer);

// Upvote an answer
router.post('/answers/:answerId/upvote', questionController.upvoteAnswer);

// Downvote an answer
router.post('/answers/:answerId/downvote', questionController.downvoteAnswer);

// Get all questions (populated)
router.get('/questions', questionController.getAllQuestions);

// Search questions
router.get('/questions/search', questionController.searchQuestions);

// Get single question by ID (populated)
router.get('/questions/:questionId', questionController.getQuestionById);

// Get paginated questions with sorting (dashboard)
router.get('/dashboard/questions', questionController.getQuestionsPaginated);



module.exports = router;
