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
  let id = parseInt(req.params.id, 10); // Convert to base 10 integer

  if (isNaN(id)) {
    return res.status(400).send({ message: 'Invalid product ID!' });
  }

  let index = productData.findIndex((product) => product.id === id);

  if (index === -1) {
    return res.status(404).send({ message: 'Product not found!' });
  }

  console.log(`\n🔄 Updating Product ID: ${id}`);
  console.log('📌 Before Update:', productData[index]);

  // Log changes
  console.log('✅ Changes:');
  for (let key in req.body) {
    if (productData[index][key] !== req.body[key]) {
      console.log(
        `   - ${key}: "${productData[index][key]}" ➝ "${req.body[key]}"`
      );
    }
  }

  // Preserve original ID while updating
  productData[index] = { ...productData[index], ...req.body };

  console.log('📌 After Update:', productData[index]);

  res.status(200).send({
    status_code: 200,
    message: 'Product updated successfully!',
    product: productData[index],
  });
});

// DELETE API
app.delete('/api/delete_product/:id', (req, res) => {
  let id = parseInt(req.params.id, 10); // Convert to integer (base 10)

  if (isNaN(id)) {
    return res.status(400).send({ message: 'Invalid product ID!' });
  }

  let index = productData.findIndex((product) => product.id === id);

  // Prevents deleting the wrong product by checking index !== -1 before calling splice.
  if (index === -1) {
    return res.status(404).send({ message: 'Product not found!' });
  }

  console.log(`🗑️ Deleting Product ID: ${id}`);
  console.log('📌 Product Data Before Deletion:', productData);

  let deletedProduct = productData.splice(index, 1)[0]; // Remove the product and store it

  console.log('✅ Deleted Product:', deletedProduct);
  console.log('📌 Product Data After Deletion:', productData);

  res.status(204).send({
    status_code: 204,
    message: 'Product deleted successfully!',
    deleted_product: deletedProduct, // Return deleted product for reference
  });
});

app.listen(2000, () => {
  console.log('Connected to server at 2000');
});
