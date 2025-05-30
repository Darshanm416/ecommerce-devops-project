const express = require('express');
const router = express.Router();
const Product = require('../models/Product');
const redisClient = require('../redisClient');

// Get all products (with caching)
router.get('/', async (req, res) => {
  const cached = await redisClient.get('products');

  if (cached) {
    return res.json(JSON.parse(cached));
  }

  const products = await Product.find();
  await redisClient.set('products', JSON.stringify(products), { EX: 60 });
  res.json(products);
});

module.exports = router;