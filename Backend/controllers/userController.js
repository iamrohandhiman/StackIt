const User = require('../models/user');

exports.markAllMentionsViewed = async (req, res, next) => {
  try {
    await User.updateOne(
      { _id: req.user.userId },
      { $set: { 'mentions.$[].viewed': true } }
    );
    res.json({ message: 'All mentions marked as viewed' });
  } catch (err) {
    next(err);
  }
};
