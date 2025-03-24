const mongoose = require('mongoose');

const stockSchema = new mongoose.Schema({
  item: String,
  expectedCount: Number,
  detectedCount: { type: Number, default: 0 },
});

module.exports = mongoose.model('Stock', stockSchema);
