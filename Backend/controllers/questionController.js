const questionService = require('../services/questionService');

exports.createQuestion = async (req, res, next) => {
  try {
    const { body, tags } = req.body;
    const question = await questionService.createQuestion({ body, tags });
    res.status(201).json(question);
  } catch (err) {
    next(err);
  }
};

exports.addAnswer = async (req, res, next) => {
  try {
    const { questionId } = req.params;
    const { userId, userName, body, mentions } = req.body;
    const answer = await questionService.addAnswer({
      questionId,
      userId,
      userName,
      body,
      mentions
    });
    res.status(201).json(answer);
  } catch (err) {
    next(err);
  }
};

exports.upvoteAnswer = async (req, res, next) => {
  try {
    const { answerId } = req.params;
    const answer = await questionService.upvoteAnswer(answerId);
    res.json(answer);
  } catch (err) {
    next(err);
  }
};

exports.downvoteAnswer = async (req, res, next) => {
  try {
    const { answerId } = req.params;
    const answer = await questionService.downvoteAnswer(answerId);
    res.json(answer);
  } catch (err) {
    next(err);
  }
};

exports.getAllQuestions = async (req, res, next) => {
  try {
    const questions = await questionService.getAllQuestions();
    res.json(questions);
  } catch (err) {
    next(err);
  }
};

exports.getQuestionById = async (req, res, next) => {
  try {
    const { questionId } = req.params;
    const question = await questionService.getQuestionById(questionId);
    res.json(question);
  } catch (err) {
    next(err);
  }
};

exports.getQuestionsPaginated = async (req, res, next) => {
  try {
    const { page, limit, sortBy } = req.query;
    const questions = await questionService.getQuestionsPaginated({
      page: parseInt(page) || 1,
      limit: parseInt(limit) || 10,
      sortBy
    });
    res.json(questions);
  } catch (err) {
    next(err);
  }
};

exports.searchQuestions = async (req, res, next) => {
  try {
    const { query, page, limit } = req.query;
    if (!query) {
      return res.status(400).json({ message: 'Query parameter is required' });
    }
    const questions = await questionService.searchQuestions(
      query,
      parseInt(page) || 1,
      parseInt(limit) || 10
    );
    res.json(questions);
  } catch (err) {
    next(err);
  }
};
