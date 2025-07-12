const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'UserCredential', required: true }
});

module.exports = mongoose.model('User', userSchema);
