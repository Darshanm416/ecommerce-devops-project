// src/api.js
import axios from 'axios';

const API = axios.create({
  baseURL: 'http://54.234.255.123/:5000/api',
});

export const fetchProducts = () => API.get('/products');
