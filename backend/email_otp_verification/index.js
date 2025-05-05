const express = require('express');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use('/api', require('./routes/app.routes'));

const PORT = process.env.PORT || 5000;
app.listen(5000, function () {
  console.log('Server Started');
});
