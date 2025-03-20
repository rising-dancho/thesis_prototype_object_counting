const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    action: { type: String, required: true },
    objectCount: { type: Number, default: null },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Activity', activitySchema);
