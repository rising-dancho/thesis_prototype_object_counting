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
        const action = this.action || '';
        return !(
          action === 'Logged In' ||
          action === 'Registered' ||
          action.startsWith('Updated role of user') ||
          action.startsWith('Deleted user')
        );
      },
    },
    countedAmount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Activity', activitySchema);
