const express = require('express');
const mongoose = require('mongoose');
require('dotenv').config(); // Load environment variables

const app = express();
const cors = require('cors');
app.use(cors());

const Product = require('./schema/product');

app.use(express.json());
app.use(
  express.urlencoded({
    extended: true,
  })
);

const productData = [];

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

app.listen(2000, () => {
  console.log('Connected to server at 2000');
});
