const mongoose = require('mongoose');

const activitySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId, // ✅ This stores a reference (ObjectId) to the User model
      ref: 'User', // ✅ This tells Mongoose that `userId` is linked to the 'User' collection  
      required: true,
    },
    action: { type: String, required: true },
    stockId: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: 'Stock', 
      default: null 
    }, // Reference the stock item
    countedAmount: { type: Number, default: null }, // Optional: Store the counted amount
  },
  { timestamps: true }
);

module.exports = mongoose.model('Activity', activitySchema);
