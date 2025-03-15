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

// Root Route - Show a message when visiting "/"
app.get('/', (req, res) => {
  res.send('Welcome to the Express API! 🚀');
});

// POST REQUEST
app.post('/api/add_product', (req, res) => {
  console.log('RESULT', req.body);

  // "pdata" means product data : an object containing product information
  const pdata = {
    id: productData.length + 1,
    pname: req.body.pname,
    pprice: req.body.pprice,
    pdesc: req.body.pdesc,
  };

  productData.push(pdata);
  console.log('PRODUCT DATA', pdata);

  res.status(200).send({
    status_code: 200,
    message: 'Product added successfully!',
    product: pdata,
  });
});

app.listen(2000, () => {
  console.log('Connected to server at 2000');
});
