const express = require('express');
const cors = require('cors');
const { MongoClient, ServerApiVersion } = require('mongodb');
require('dotenv').config(); // For environment variables

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const uri = process.env.MONGO_URI; // Load from .env file
const client = new MongoClient(uri, {
  serverApi: ServerApiVersion.v1,
});

async function connectDB() {
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error);
  }
}
connectDB();

const db = client.db('tectags'); // Replace with your actual database name
const productsCollection = db.collection('products');

// WELCOME ROUTE "/"
app.get('/', (req, res) => {
  res.send('Welcome to the Express API! 🚀');
});

// POST API - Add Product
app.post('/api/add_product', async (req, res) => {
  try {
    const entry = {
      pname: req.body.pname,
      pprice: req.body.pprice,
      pdesc: req.body.pdesc,
    };

    const result = await productsCollection.insertOne(entry);
    res.status(200).send({
      status_code: 200,
      message: 'Product added successfully!',
      product: result.ops[0],
    });
  } catch (error) {
    res.status(500).send({ message: 'Error adding product', error });
  }
});

// GET API - Fetch All Products
app.get('/api/get_product', async (req, res) => {
  try {
    const products = await productsCollection.find().toArray();
    res.status(200).send({
      status_code: 200,
      products,
    });
  } catch (error) {
    res.status(500).send({ message: 'Error fetching products', error });
  }
});

// UPDATE API
app.put('/api/update_product/:id', async (req, res) => {
  const id = req.params.id;

  try {
    const updatedProduct = await productsCollection.findOneAndUpdate(
      { _id: new require('mongodb').ObjectId(id) },
      { $set: req.body },
      { returnDocument: 'after' }
    );

    if (!updatedProduct.value) {
      return res.status(404).send({ message: 'Product not found!' });
    }

    res.status(200).send({
      status_code: 200,
      message: 'Product updated successfully!',
      product: updatedProduct.value,
    });
  } catch (error) {
    res.status(500).send({ message: 'Error updating product', error });
  }
});

// DELETE API
app.delete('/api/delete_product/:id', async (req, res) => {
  const id = req.params.id;

  try {
    const result = await productsCollection.deleteOne({
      _id: new require('mongodb').ObjectId(id),
    });

    if (result.deletedCount === 0) {
      return res.status(404).send({ message: 'Product not found!' });
    }

    res.status(204).send({ message: 'Product deleted successfully!' });
  } catch (error) {
    res.status(500).send({ message: 'Error deleting product', error });
  }
});

// Start Server
app.listen(2000, () => {
  console.log('🚀 Server running on port 2000');
});
