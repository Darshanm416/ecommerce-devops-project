const express = require('express');
const mongoose = require('mongoose');
const productRoutes = require('./routes/product');
require('dotenv').config();

const app = express();
app.use(express.json());

mongoose.connect('mongodb://mongo:27017/ecomdb')
  .then(() => console.log('MongoDB connected'))
  .catch(err => console.error(err));

app.use('/api/products', productRoutes);

app.listen(5000, () => {
  console.log('Backend running on port 5000');
});
