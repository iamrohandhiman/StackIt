const mongoose = require('mongoose');

const questionSchema = new mongoose.Schema({
  body: { type: String, required: true },
  tags: [{ type: String }],
  answers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Answer' }]
}, { timestamps: true });

module.exports = mongoose.model('Question', questionSchema);
