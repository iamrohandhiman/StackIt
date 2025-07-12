const Question = require('../models/question');
const Answer = require('../models/answer');
const User = require('../models/user');

exports.createQuestion = async ({ title, body, tags }) => {
  const question = new Question({
    title,
    body,
    tags
  });
  await question.save();
  return question;
};


exports.addAnswer = async ({ questionId, userId, userName, body, mentions }) => {
  const answer = await Answer.create({
    questionId,
    userId,
    userName,
    body,
    mentions
  });

  await Question.findByIdAndUpdate(
    questionId,
    { $push: { answers: answer._id } }
  );

  // Update mentioned users' mentions array
  await User.updateMany(
    { _id: { $in: mentions } },
    { $push: { mentions: questionId } }
  );

  return answer;
};

exports.upvoteAnswer = async (answerId) => {
  const answer = await Answer.findByIdAndUpdate(
    answerId,
    { $inc: { upvotes: 1 } },
    { new: true }
  );
  return answer;
};

exports.downvoteAnswer = async (answerId) => {
  const answer = await Answer.findByIdAndUpdate(
    answerId,
    { $inc: { downvotes: 1 } },
    { new: true }
  );
  return answer;
};

exports.getAllQuestions = async () => {
  return await Question.find()
    .populate({
      path: 'answers',
      populate: {
        path: 'userId',
        select: 'name' 
      }
    })
    .exec();
};


exports.getQuestionById = async (questionId) => {
  return await Question.findById(questionId)
    .populate({
      path: 'answers',
      populate: {
        path: 'userId',
        select: 'name'
      }
    })
    .exec();
};

exports.getQuestionsPaginated = async ({ page = 1, limit = 10, sortBy = 'new' }) => {
  const skip = (page - 1) * limit;

  let sortCriteria = { createdAt: -1 }; // default to new

  switch (sortBy) {
    case 'oldest':
      sortCriteria = { createdAt: 1 };
      break;
    case 'mostAnswered':
      // Sort by answers array length
      sortCriteria = { answersCount: -1 };
      break;
    case 'trending':
      // Will join with answers collection to count upvotes
      const trendingQuestions = await Question.aggregate([
        {
          $lookup: {
            from: 'answers',
            localField: 'answers',
            foreignField: '_id',
            as: 'answersData'
          }
        },
        {
          $addFields: {
            totalUpvotes: { $sum: '$answersData.upvotes' }
          }
        },
        { $sort: { totalUpvotes: -1 } },
        { $skip: skip },
        { $limit: limit }
      ]);
      return trendingQuestions;
    case 'unanswered':
      return await Question.find({ answers: { $size: 0 } })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .exec();
  }

  // For new, oldest, mostAnswered

  if (sortBy === 'mostAnswered') {
    // Requires aggregation to count answers
    const questions = await Question.aggregate([
      {
        $addFields: {
          answersCount: { $size: '$answers' }
        }
      },
      { $sort: sortCriteria },
      { $skip: skip },
      { $limit: limit }
    ]);
    return questions;
  } else {
    // new or oldest
    return await Question.find()
      .sort(sortCriteria)
      .skip(skip)
      .limit(limit)
      .exec();
  }
};

exports.searchQuestions = async (query, page = 1, limit = 10) => {
  const skip = (page - 1) * limit;

  const questions = await Question.find({
    body: { $regex: query, $options: 'i' } // case-insensitive search in question body
  })
    .skip(skip)
    .limit(limit)
    .exec();

  return questions;
};
