const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId, // ✅ This stores a reference (ObjectId) to the User model
      ref: 'User', // ✅ This tells Mongoose that `userId` is linked to the 'User' collection
      required: true,
    },
    action: { type: String, required: true },
    objectCount: { type: Number, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Activity', activitySchema);