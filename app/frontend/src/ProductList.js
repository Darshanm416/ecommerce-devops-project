// src/components/ProductList.js
import React, { useEffect, useState } from 'react';
import { fetchProducts } from '../api';

const ProductList = () => {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    fetchProducts().then(res => {
      setProducts(res.data);
    }).catch(err => {
      console.error("Failed to fetch products", err);
    });
  }, []);

  return (
    <div>
      <h2>Products</h2>
      {products.map(product => (
        <div key={product._id}>
          <h4>{product.name}</h4>
          <p>{product.description}</p>
          <p>₹{product.price}</p>
        </div>
      ))}
    </div>
  );
};

export default ProductList;
