// seed/productSeeder.js
const mongoose = require('mongoose');
const connectDB = require('../db/connect');
const Product = require('../models/Product');

const seedProducts = async () => {
  await connectDB();

  await Product.deleteMany(); // optional: clear existing

  const products = [
    {
      name: 'Apple iPhone 14',
      price: 999,
      description: 'Latest Apple iPhone',
      stock: 50,
    },
    {
      name: 'Samsung Galaxy S23',
      price: 899,
      description: 'Flagship Samsung phone',
      stock: 30,
    },
  ];

  await Product.insertMany(products);
  console.log('Sample products inserted');
  process.exit();
};

seedProducts();