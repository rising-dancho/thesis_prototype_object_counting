const mongoose = require('mongoose');

const ActivitySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  action: { type: String, required: true },
  objectCount: { type: Number, default: 0 }, // Store counted objects if applicable
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Activity', ActivitySchema);
