// src/api.js
import axios from 'axios';

const API = axios.create({
  baseURL: 'http://<EC2-PUBLIC-IP>:5000/api',
});

export const fetchProducts = () => API.get('/products');
