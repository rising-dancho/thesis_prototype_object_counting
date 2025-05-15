const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
  },
  hashedPassword: {
    type: String,
    required: true,
  },
  firstName: {
    type: String,
    required: true,
  },
  middleName: { type: String }, // 👈 optional
  lastName: {
    type: String,
    required: true,
  },
  contactNumber: {
    type: String,
    required: true,
  },
  birthday: {
    type: Date,
    required: true,
  },

  // ROLE BASED ACCESS CONTROL
  role: {
    type: String,
    enum: ['employee', 'manager'],
    default: 'employee',
  },
});

module.exports = mongoose.model('User', userSchema);
