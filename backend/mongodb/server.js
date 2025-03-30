const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config(); // Load environment variables

const app = express();
const cors = require('cors');
app.use(cors());

const Stock = require('./schema/stock');
const User = require('./schema/user');
const Activity = require('./schema/activity');

const createToken = (id) => {
  return jwt.sign({ _id: id }, process.env.SECRET, { expiresIn: '14d' });
};

// Middleware TO PARSE JSON body
app.use(express.json());
// URLENCODED WOULD ALLOW US TO GET ACCESS TO : req.body
app.use(
  express.urlencoded({
    extended: true,
  })
);

// 🛢️ Connect to MongoDB using Mongoose
mongoose.set('strictQuery', true);
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('✅ Connected to MongoDB via Mongoose'))
  .catch((err) => console.error('❌ MongoDB connection failed:', err));

// WELCOME ROUTE "/"
app.get('/', (req, res) => {
  res.send('FIXING BACKEND LOGIC! 🚀');
});

// LOGIN & REGISTRATION -------------

// REGISTRATION
app.post('/api/register', async (req, res) => {
  try {
    const { password, email, fullName } = req.body;

    // Validate input
    if (!email || !password || !fullName) {
      return res
        .status(400)
        .json({ message: 'Email, password, and full name are required.' });
    }

    // Check if email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email is already in use.' });
    }

    // Hash password
    const saltRounds = 12; // number of rounds for  randomization
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // THIS IS WHAT WILL BE SAVED TO MONGODB
    let newUser = new User({
      email: email,
      hashedPassword: hashedPassword,
      fullName: fullName,
    });

    // SAVE THE USER TO THE DATABASE
    await newUser.save();

    // AFTER SAVING: create JWT for remembering sessions
    const token = createToken(newUser._id);

    res.status(201).json({
      message: 'Registration successful!',
      token: token,
    });
  } catch (error) {
    res.status(500).json({
      message: 'Something went wrong.',
      error: error.message,
    });
  }
});

// LOGIN + ACTIVITY LOGGING
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    const existingUser = await User.findOne({ email: email });

    // if user does not exist throw an error
    if (!existingUser) {
      return res.status(400).json({ message: 'Incorrect email or password.' });
    }

    // compare the incoming password against the password in the database
    const validPassword = await bcrypt.compare(
      password,
      existingUser.hashedPassword
    );

    // if password does not match throw an error
    if (!validPassword) {
      return res.status(400).json({ message: 'Incorrect email or password.' });
    }

    // IF LOGIN IS SUCCESSFUL: CREATE A TOKEN
    if (validPassword) {
      const token = createToken(existingUser._id);

      // Log the login activity
      await Activity.create({
        userId: existingUser._id,
        action: 'Logged In',
      });

      return res.status(200).json({
        message: 'Login Successful!',
        token: token,
        userId: existingUser._id,
      });
    }
  } catch (error) {
    console.error('❌ Login error:', error);
    return res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
});

// NUMBER OF STOCKS and DETECTIONS DATA -------------

// CREATES A COUNT LOG FOR THE ACTIVITY LOGS WIDGET
app.post('/api/count_objects', async (req, res) => {
  try {
    // Extract values from request body
    const { userId, stockName, sold } = req.body;

    // Ensure required values are present
    if (!userId || !stockName || sold === undefined) {
      return res
        .status(400)
        .json({ message: 'User ID, stockName, and sold are required' });
    }

    // Find the stock item
    const stock = await Stock.findOne({ stockName: stockName });
    if (!stock) {
      return res
        .status(404)
        .json({ message: `Stock item '${stockName}' not found` });
    }

    // 🛑 Ensure availableStock never goes negative
    if (stock.availableStock < sold) {
      return res.status(400).json({
        message: `Not enough stock available. Only ${stock.availableStock} left.`,
      });
    }

    // ✅ Update stock: subtract `sold` from `availableStock`
    const updatedStock = await Stock.updateOne(
      { stockName: stockName },
      {
        $inc: {
          availableStock: -sold, // Subtract sold from available stock
          sold: sold, // Increase sold count
        },
      }
    );

    // ✅ Log the activity
    await Activity.create({
      userId,
      action: `Updated count for ${stockName}`,
      stockId: stock._id,
      countedAmount: sold,
    });

    res.status(200).json({
      message: 'Object count logged and stock updated successfully',
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error logging object count',
      error: error.message,
    });
  }
});

// GET COUNTED OBJECT BY SPECIFIC USER
app.get('/api/activity/:activityId', async (req, res) => {
  try {
    const { activityId } = req.params;
    const activity = await Activity.findById(activityId).populate(
      'stockId',
      'stockName'
    );

    if (!activity) {
      return res.status(404).json({ message: 'Activity not found' });
    }

    res.status(200).json({
      _id: activity._id,
      userId: activity.userId,
      action: activity.action,
      stockName: activity.stockId?.stockName ?? 'N/A',
      countedAmount: activity.sold ?? 0, // ✅ Ensure correct field
      timestamp: activity.createdAt,
    });
  } catch (error) {
    res.status(500).json({
      message: 'Error fetching activity details',
      error: error.message,
    });
  }
});

// GET [ALL] USER ACTIVITY LOGS PER USERID
app.get('/api/activity_logs/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const activities = await Activity.find({ userId })
      .populate('userId', 'fullName')
      .populate('stockId', 'stockName totalStock availableStock sold')
      .sort({ createdAt: -1 });

    const formattedActivities = activities.map((activity) => ({
      _id: activity._id,
      userId: activity.userId?._id,
      fullName: activity.userId?.fullName ?? 'Unknown User',
      action: activity.action,
      stockName: activity.stockId?.stockName ?? 'N/A',
      countedAmount: activity.sold ?? 0, // ✅ Ensure correct field
      totalStock: activity.stockId?.totalStock ?? 0,
      availableStock: activity.stockId?.availableStock ?? 0, // ✅ Now included
      timestamp: activity.createdAt,
    }));

    res.status(200).json(formattedActivities);
  } catch (error) {
    console.error('❌ Error fetching activity logs per user:', error);
    res
      .status(500)
      .json({ message: 'Error fetching activity logs', error: error.message });
  }
});

// GET ALL USER ACTIVITY LOGS
app.get('/api/activity_logs/', async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query; // Default: 50 results per page

    const activities = await Activity.find()
      .populate('userId', 'fullName')
      .sort({ createdAt: -1 })
      .skip((page - 1) * limit) // Pagination
      .limit(Number(limit)); // Convert to number for safety

    const formattedActivities = activities.map((activity) => ({
      _id: activity._id,
      userId: activity.userId?._id,
      fullName: activity.userId?.fullName ?? 'Unknown User',
      action: activity.action,
      countedAmount: activity.sold ?? 0, // ✅ Ensure correct field
      timestamp: activity.createdAt,
    }));

    res.status(200).json(formattedActivities);
  } catch (error) {
    console.error('❌ Error fetching all activity logs:', error);
    res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
  // EXPLANATION ON ABOUT ACTIVITY LOGS PER USERID AND ALL ACTIVITY LOGS PER USER: https://chatgpt.com/share/67e6097f-8c94-8000-940d-5ecd8c54bb09
});

// Get all stock
app.get('/api/stocks', async (req, res) => {
  const stocks = await Stock.find();
  res.json(stocks);
});

// Save stock categories
app.post('/api/stocks', async (req, res) => {
  try {
    for (const stockItem of req.body) {
      await Stock.findOneAndUpdate(
        { stockName: stockItem.stockName }, // Ensure correct search query
        {
          totalStock: stockItem.totalStock,
          availableStock: stockItem.totalStock - (stockItem.sold ?? 0), // Ensure availableStock updates
        },
        { upsert: true, new: true }
      );
    }
    res.json({ message: 'Stock updated successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.delete('/api/stocks/:stockName', async (req, res) => {
  try {
    const stockName = req.params.stockName;
    await Stock.deleteOne({ stockName: stockName }); // ✅ Fix field name
    res.json({ message: `Deleted ${stockName} successfully` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});


const PORT = 2000;
app.listen(PORT, () => {
  console.log(`Connected to server at ${PORT}`);
});
