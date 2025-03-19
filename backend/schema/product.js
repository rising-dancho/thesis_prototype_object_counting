const mongoose = require('mongoose');

// SCHEMA
let productSchema = new mongoose.Schema({
  pname: {
    type: String,
    required: true,
  },
  pprice: {
    type: String,
    required: true,
  },
  pdesc: {
    type: String,
    required: true,
  },
});

module.exports = mongoose.model('Product', productSchema);
