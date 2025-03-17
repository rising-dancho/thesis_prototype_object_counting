const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
require('dotenv').config(); // Load environment variables

const app = express();
const cors = require('cors');
app.use(cors());

const Product = require('./schema/product');
const User = require('./schema/user');
const user = require('./schema/user');

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
app.get('/protected', (req, res) => {
  res.send(
    'AAAND HIS NAME IS JOHN CENA!! ten tenen ten!! YOU CANT SEE ME!!?! ten tenen ten !! (unless you are logged in)'
  );
});

// REGISTRATION
app.post('/api/register', async (req, res) => {
  try {
    const { password, username, fullName } = req.body;

    // Validate input
    if (!username || !password || !fullName) {
      return res
        .status(400)
        .json({ message: 'Username, password, and full name are required.' });
    }

    // Check if username already exists
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: 'Username is already taken.' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 12);

    let newUser = new User({
      username: username,
      hashedPassword: hashedPassword,
      fullName: fullName,
    });

    await newUser.save();
    res.status(201).json({
      message: 'Registration successful!',
    });
  } catch (error) {
    res.status(500).json({
      message: 'Something went wrong.',
      error: error.message,
    });
  }
});

// LOGIN
app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;

  const existingUser = await User.findOne({ username: username });

  // if user does not exist throw an error
  if (!existingUser) {
    return res.status(400).json({ message: 'Incorrect username or password.' });
  }

  // compare the incoming password against the password in the database
  const validPassword = await bcrypt.compare(password, existingUser.hashedPassword);

  // if password does not match throw an error
  if (!validPassword) {
    return res.status(400).json({ message: 'Incorrect username or password.' });
  }

  if (validPassword) {
    return res.status(200).send({ message: 'Login Successful!' });
  }
});

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
