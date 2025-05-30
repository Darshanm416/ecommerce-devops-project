// src/api.js
import axios from 'axios';

const API = axios.create({
  baseURL: 'http://backend/:5000/api',
});

export const fetchProducts = () => API.get('/products');
