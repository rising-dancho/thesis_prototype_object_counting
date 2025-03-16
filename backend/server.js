const express = require('express');

const app = express();

const cors = require('cors');
app.use(cors());

app.use(express.json());

app.use(
  express.urlencoded({
    extended: true,
  })
);

const productData = [];

// WELCOME ROUTE "/"
app.get('/', (req, res) => {
  res.send('Welcome to the Express API! 🚀');
});

// POST API
app.post('/api/add_product', (req, res) => {
  console.log('DATA FROM FRONTEND', req.body);

  // "entry" means a single product data : an object containing this product's information
  const entry = {
    id: productData.length + 1,
    pname: req.body.pname,
    pprice: req.body.pprice,
    pdesc: req.body.pdesc,
  };

  productData.push(entry);
  console.log('PROCESSED DATA', entry);

  res.status(200).send({
    status_code: 200,
    message: 'Product added successfully!',
    product: entry,
  });
});

// GET API
app.get('/api/get_product', (req, res) => {
  if (productData.length > 0) {
    res.status(200).send({
      status_code: 200,
      products: productData,
    });
  } else {
    res.status(200).send({
      status: 'SUCCESS!',
      message: 'Product updated successfully!',
    });
  }
});

// UPDATE API - ":id" is the route "parameter"
app.put('/api/update_product/:id', (req, res) => {
  let id = req.params.id * 1; // Convert to integer
  let productToUpdate = productData.find((product) => product.id === id);
  let index = productData.indexOf(productToUpdate);

  if (!productToUpdate) {
    return res.status(404).send({ message: 'Product not found!' });
  }

  console.log(`\n🔄 Updating Product ID: ${id}`);
  console.log('📌 Before Update:', productToUpdate);

  // Log changes
  console.log('✅ Changes:');
  for (let key in req.body) {
    if (productToUpdate[key] !== req.body[key]) {
      console.log(
        `   - ${key}: "${productToUpdate[key]}" ➝ "${req.body[key]}"`
      );
    }
  }

  // Replace the data in the array with the new data
  productData[index] = req.body;

  console.log('📌 After Update:', productData[index]);

  res.status(200).send({
    status_code: 200,
    message: 'Product updated successfully!',
    product: productData[index],
  });
});

app.listen(2000, () => {
  console.log('Connected to server at 2000');
});
