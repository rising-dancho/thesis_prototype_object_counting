const mongoose = require('mongoose');

const stockSchema = new mongoose.Schema({
  stockName: String,
  totalStock: Number,
  availableStock: { type: Number, default: 0 },
  availableStock: { type: Number, default: 0 },
});

module.exports = mongoose.model('Stock', stockSchema);
