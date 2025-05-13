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

const requireAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader)
    return res.status(401).json({ message: 'Authorization header missing' });

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.SECRET);
    req.user = decoded; // Makes the user's _id available in the request
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

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

// NUMBER OF STOCKS and DETECTIONS DATA -------------

// FETCH INDIVIDUAL STOCK USING ID
app.get('/api/stocks/:id', async (req, res) => {
  try {
    const stock = await Stock.findById(req.params.id);

    if (!stock) {
      return res.status(404).json({ message: 'Stock item not found' });
    }

    res.json({
      _id: stock._id,
      stockName: stock.stockName,
      availableStock: stock.availableStock,
      totalStock: stock.totalStock,
      sold: stock.sold,
      unitPrice: stock.unitPrice,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// SOLD CALCULATION DONE HERE
// GET ALL STOCKS WITH SOLD COUNT AND TOTAL SALES
app.get('/api/stocks', async (req, res) => {
  try {
    const stocks = await Stock.find();

    let grandTotalSold = 0;
    let grandTotalSales = 0;

    const withSold = stocks.map((stock) => {
      const soldCount = stock.totalStock - stock.availableStock;
      const totalSales = soldCount * (stock.unitPrice ?? 0);

      grandTotalSold += soldCount;
      grandTotalSales += totalSales;

      return {
        _id: stock._id,
        stockName: stock.stockName,
        totalStock: stock.totalStock,
        availableStock: stock.availableStock,
        sold: soldCount,
        unitPrice: stock.unitPrice,
        totalSales,
      };
    });

    res.json({
      items: withSold,
      summary: {
        totalSold: grandTotalSold,
        totalEarnings: grandTotalSales,
      },
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// UPDATE UNIT PRICE OF A STOCK
app.post('/api/stocks/update-price', async (req, res) => {
  try {
    const { stockName, unitPrice } = req.body;

    if (!stockName || unitPrice === undefined) {
      return res
        .status(400)
        .json({ message: 'Stock name and unit price are required' });
    }

    const stock = await Stock.findOne({ stockName });

    if (!stock) {
      return res
        .status(404)
        .json({ message: `Stock item '${stockName}' not found` });
    }

    stock.unitPrice = unitPrice;
    await stock.save();

    res.json({
      message: `Successfully updated unit price of ${stockName} to ₱${unitPrice}`,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Save stock for restock
app.post('/api/update/restock', async (req, res) => {
  try {
    for (const stockItem of req.body) {
      await Stock.findOneAndUpdate(
        { stockName: stockItem.stockName },
        {
          $inc: {
            totalStock: stockItem.totalStock,
            availableStock: stockItem.availableStock,
          },
          $set: {
            unitPrice: stockItem.unitPrice, // ✅ update price during restock
          },
        },
        { upsert: true, new: true }
      );
    }
    res.json({ message: 'Stock updated successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// RESTOCK endpoint
app.post('/api/stocks/restock', async (req, res) => {
  try {
    const { stockName, restockAmount } = req.body;

    if (!stockName || restockAmount === undefined) {
      return res
        .status(400)
        .json({ message: 'Stock name and restock amount are required' });
    }

    const stock = await Stock.findOne({ stockName });

    if (!stock) {
      return res
        .status(404)
        .json({ message: `Stock item '${stockName}' not found` });
    }

    stock.totalStock += restockAmount;
    stock.availableStock += restockAmount;

    await stock.save();

    res.json({
      message: `Successfully restocked ${restockAmount} units of ${stockName}`,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Save stock for sold
app.post('/api/update/sold', async (req, res) => {
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

// CALCULATE PRICE OF SOLD ITEMS
app.post('/api/stocks/sell', async (req, res) => {
  try {
    const { stockName, quantitySold } = req.body;

    if (!stockName || quantitySold === undefined) {
      return res
        .status(400)
        .json({ message: 'Stock name and quantity sold are required' });
    }

    const stock = await Stock.findOne({ stockName });

    if (!stock) {
      return res
        .status(404)
        .json({ message: `Stock item '${stockName}' not found` });
    }

    if (stock.availableStock < quantitySold) {
      return res.status(400).json({
        message: `Not enough stock available. Only ${stock.availableStock} left.`,
      });
    }

    stock.sold += quantitySold;
    stock.availableStock -= quantitySold;

    const totalPrice = stock.unitPrice * quantitySold;
    // Detect sold out
    res.json({
      message: `Successfully sold ${quantitySold} units of ${stockName}`,
      soldOut: soldOut,
      totalPrice: totalPrice, // 💰 send back total amount
    });

    await stock.save();

    // await Activity.create({
    //   userId, // (if you want to track which user sold it)
    //   action: `Sold ${quantitySold} units of ${stockName}`,
    //   stockId: stock._id,
    //   countedAmount: quantitySold,
    // });

    res.json({
      message: `Successfully sold ${quantitySold} units of ${stockName}`,
      soldOut: soldOut, //
    });
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

// LOGIN, REGISTRATION, UPDATE USER & CHANGE PASSWORD -------------

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

// REGISTRATION
app.post('/api/register', async (req, res) => {
  try {
    const { email, password, firstName, lastName, contactNumber, birthday } =
      req.body;

    // Validate input
    if (
      !email ||
      !password ||
      !firstName ||
      !lastName ||
      !contactNumber ||
      !birthday
    ) {
      return res.status(400).json({
        message:
          'All fields are required: email, password, firstName, lastName, contactNumber, birthday.',
      });
    }

    // Check if email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email is already in use.' });
    }

    // Hash password
    const saltRounds = 12; // number of rounds for  randomization
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create new user
    const newUser = new User({
      email,
      hashedPassword,
      firstName,
      lastName,
      contactNumber,
      birthday: new Date(birthday), // ensure birthday is stored as Date
    });

    // SAVE THE USER TO THE DATABASE
    await newUser.save();

    // Log registration activity
    await Activity.create({
      userId: newUser._id,
      action: 'Registered',
    });

    // AFTER SAVING: create JWT for remembering sessions
    const token = createToken(newUser._id);

    res.status(201).json({
      message: 'Registration successful!',
      token: token,
      userId: newUser._id.toString(), // 👈 include userId
    });
  } catch (error) {
    console.error('❌ Registration Error:', error); // log the full error to the console
    res.status(500).json({
      message: 'Something went wrong.',
      error: error.message,
    });
  }
});

// CHANGE PASSWORD
app.put('/api/change-password/:userId', async (req, res) => {
  // app.put('/api/change-password/:userId', requireAuth, async (req, res) => {
  try {
    const { userId } = req.params;
    // JWT ROUTE PROTECTION
    // if (userId !== req.userId) {
    //   return res
    //     .status(403)
    //     .json({ message: "Unauthorized to change this user's password." });
    // }
    const { currentPassword, newPassword } = req.body;

    // Validate inputs
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: 'Invalid user ID.' });
    }
    if (!currentPassword || !newPassword) {
      return res
        .status(400)
        .json({ message: 'Current and new passwords are required.' });
    }

    // Find user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // Verify current password
    const isMatch = await bcrypt.compare(currentPassword, user.hashedPassword);
    if (!isMatch) {
      return res.status(401).json({ message: 'Incorrect current password.' });
    }

    // Hash new password
    const saltRounds = 12;
    const hashedPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    user.hashedPassword = hashedPassword;
    await user.save();

    res.json({ message: 'Password updated successfully.' });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
});

// UPDATE PROFILE
app.put('/api/profile/:userId', async (req, res) => {
  try {
    const { userId } = req.params; // Get userId from URL
    const { firstName, lastName, contactNumber, birthday } = req.body;

    // Validate inputs
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ message: 'Invalid user ID.' });
    }
    if (!firstName || !lastName || !contactNumber || !birthday) {
      return res.status(400).json({ message: 'All fields are required.' });
    }

    // Update user
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      {
        firstName,
        lastName,
        contactNumber,
        birthday: new Date(birthday),
      },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.json({ message: 'Profile updated successfully.', user: updatedUser });
  } catch (error) {
    console.error('Update error:', error);
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
});

// GET USER PROFILE
app.get('/api/user/:userId', requireAuth, async (req, res) => {
  try {
    const { userId } = req.params;

    // Fetch the user from the database using the userId
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.status(200).json({
      _id: user._id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      contactNumber: user.contactNumber,
      birthday: user.birthday,
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
});

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
    const stock = await Stock.findOne({
      // stockName: { $regex: new RegExp(`^${stockName}$`, 'i') }, // 'i' = case-insensitive
      stockName: stockName,
    });

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

    // ✅ THIS IS CALLED WHEN THE LABEL ALREADY EXISTS (NOT USING AUTO DETECT ADD MISSING LABEL): subtract `sold` from `availableStock`
    await Stock.updateOne(
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
      countedAmount: sold, // ✅ THIS IS WHATS CAUSING THE ERROR FOR THE COUNTEDAMOUNT TO NOT SHOW IN ACTIVITY LOGS
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
      countedAmount: activity.countedAmount ?? 0, // ✅ Ensure correct field
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
app.get('/api/activity_logs/:userId', requireAuth, async (req, res) => {
  try {
    const { userId } = req.params;

    const activities = await Activity.find({ userId })
      .populate('userId', 'firstName lastName') // Populating firstName and lastName instead of fullName
      .populate('stockId', 'stockName totalStock availableStock sold')
      .sort({ createdAt: -1 });

    const formattedActivities = activities.map((activity) => ({
      _id: activity._id,
      userId: activity.userId?._id,
      fullName: `${activity.userId?.firstName ?? 'Unknown'} ${
        activity.userId?.lastName ?? ''
      }`, // Combine first and last name
      action: activity.action,
      stockName: activity.stockId?.stockName ?? 'N/A',
      countedAmount: activity.countedAmount, // ✅ Ensure correct field
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
      .populate('userId', 'firstName lastName') // Populating firstName and lastName instead of fullName      .sort({ createdAt: -1 })
      .skip((page - 1) * limit) // Pagination
      .limit(Number(limit)); // Convert to number for safety

    const formattedActivities = activities.map((activity) => ({
      _id: activity._id,
      userId: activity.userId?._id,
      fullName: `${activity.userId?.firstName ?? 'Unknown'} ${
        activity.userId?.lastName ?? ''
      }`, // Combine first and last name
      action: activity.action,
      countedAmount: activity.countedAmount ?? 0, // ✅ Ensure correct field
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

const PORT = 2000;
app.listen(PORT, () => {
  console.log(`Connected to server at ${PORT}`);
});
