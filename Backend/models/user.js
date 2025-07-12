const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'UserCredential', required: true },

  mentions: [{
    questionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Question', required: true },
    viewed: { type: Boolean, default: false }
  }]
});

module.exports = mongoose.model('User', userSchema);
