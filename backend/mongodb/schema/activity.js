const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    action: { type: String, required: true },
    stockId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Stock',
      required: function () {
        return this.action !== 'Logged In';
      }, // Only require stockId for stock-related actions
    },
    countedAmount: { type: Number, default: 0 }, 
  },
  { timestamps: true }
);

module.exports = mongoose.model('Activity', activitySchema);
