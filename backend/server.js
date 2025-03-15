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
      status_code: 200,
      products: [],
    });
  }
});

app.listen(2000, () => {
  console.log('Connected to server at 2000');
});
