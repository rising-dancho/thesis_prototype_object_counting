const mongoose = require('mongoose');

const stockSchema = new mongoose.Schema({
  stockName: String,
  totalStock: Number,
  sold:  Number,
  unitPrice: Number,
  availableStock: { type: Number, default: 0 },
});

module.exports = mongoose.model('Stock', stockSchema);
