const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
require('dotenv').config(); // Load environment variables

const app = express();
const cors = require('cors');
app.use(cors());

const Product = require('./schema/product');
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
  res.send('Welcome to the Express API! 🚀');
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

// GET USER ACTIVITY LOGS PER USERID
app.get('/api/activity_logs/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Fetch all activities and populate userId to get both userId and fullName
    const activities = await Activity.find({ userId })
      .populate('userId', 'fullName') // ✅ Fetch only fullName from User model
      .sort({ createdAt: -1 });

    // Format response to explicitly include userId
    const formattedActivities = activities.map((activity) => ({
      _id: activity._id,
      userId: activity.userId?._id, // ✅ Explicitly include userId
      fullName: activity.userId?.fullName ?? 'Unknown User', // ✅ Include fullName
      action: activity.action,
      objectCount: activity.objectCount,
      timestamp: activity.createdAt, // ✅ Keep the timestamp
    }));

    res.status(200).json(formattedActivities);
  } catch (error) {
    console.error('❌ Error fetching activity logs per user:', error);
    res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
});

// GET ALL USER ACTIVITY LOGS
app.get('/api/activity_logs/', async (req, res) => {
  try {
    const { userId } = req.params;

    // Fetch all activities and populate userId to get both userId and fullName
    const activities = await Activity.find() // JUST REMOVE THE FILTER TO GET ALL ACTIVITIES
      .populate('userId', 'fullName') // Fetch fullName from User model
      .sort({ createdAt: -1 }); // Sort latest first

    // Format response to explicitly include userId
    const formattedActivities = activities.map((activity) => ({
      _id: activity._id,
      userId: activity.userId?._id, // ✅ Explicitly include userId
      fullName: activity.userId?.fullName ?? 'Unknown User', // ✅ Include fullName
      action: activity.action,
      objectCount: activity.objectCount,
      timestamp: activity.createdAt, // ✅ Keep the timestamp
    }));

    res.status(200).json(formattedActivities);
  } catch (error) {
    console.error('❌ Error fetching all activity logs:', error);

    res
      .status(500)
      .json({ message: 'Internal server error', error: error.message });
  }
});

// app.post('/api/count_objects', async (req, res) => {
//   try {
//     const { userId, objectCount } = req.body;

//     if (!userId || objectCount === undefined) {
//       return res
//         .status(400)
//         .json({ message: 'User ID and object count are required' });
//     }

//     // Log the counting activity
//     await Activity.create({
//       userId: userId,
//       action: 'Counted Objects',
//       objectCount: objectCount,
//     });

//     res.status(200).json({ message: 'Object count logged successfully' });
//   } catch (error) {
//     res
//       .status(500)
//       .json({ message: 'Error logging object count', error: error.message });
//   }
// });

// STORING DATA -------------

// POST API
app.post('/api/add_product', async (req, res) => {
  console.log('DATA FROM FRONTEND', req.body);

  let data = new Product(req.body);

  try {
    let dataToStore = await data.save();
    res.status(200).json({
      message: 'Product added successfully!',
      product: dataToStore,
    });
  } catch (error) {
    res.status(400).json({
      status: error.message,
    });
  }
});

// GET ALL API
app.get('/api/get_product/', async (req, res) => {
  try {
    let data = await Product.find();
    console.log('📦 Retrieved Data:', data);
    res.status(200).json(data);
  } catch (error) {
    console.error('❌ Error Retrieving Data:', error);
    res.status(500).json(error.message);
  }
});

// GET BY ID API
app.get('/api/get_product/:id', async (req, res) => {
  try {
    let data = await Product.findById(req.params.id);
    console.log(`🔍 Data for ID ${req.params.id}:`, data);
    res.status(200).json(data);
  } catch (error) {
    console.error('❌ Error Retrieving Data:', error);
    res.status(500).json(error.message);
  }
});

// UPDATE API - ":id" is the route "parameter"
app.put('/api/update_product/:id', async (req, res) => {
  let id = req.params.id;
  let updatedData = req.body;

  // ✅ Ensure update fields are correct
  if (!updatedData.pname && !updatedData.pprice && !updatedData.pdesc) {
    return res.status(400).json({ error: 'No valid fields to update' });
  }

  try {
    const data = await Product.findByIdAndUpdate(
      id,
      { $set: updatedData }, // 🔥 Use $set to force update
      { new: true } // Return the updated document
    );

    if (!data) {
      return res.status(404).json({ error: 'Product not found' });
    }

    console.log(`🔄 Updated Product (ID: ${id}):`, data);
    res.status(200).json(data);
  } catch (error) {
    console.error('❌ Error Updating Data:', error);
    res.status(500).json({ error: error.message });
  }
});

// DELETE API
app.delete('/api/delete_product/:id', async (req, res) => {
  let id = req.params.id;
  try {
    const data = await Product.findByIdAndDelete(id);

    console.log('DATA:', data);
    res.json({
      status: `Deleted the product ${
        data ? data.pname : 'Unknown'
      } from database`,
    });
  } catch (error) {
    console.error('❌ Error Deleting Data:', error);
    res.send(error.message);
  }
});

const PORT = 2000;
app.listen(PORT, () => {
  console.log(`Connected to server at ${PORT}`);
});
