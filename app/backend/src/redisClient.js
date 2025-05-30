const redis = require('redis');

const redisClient = redis.createClient({
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379,
});
redisClient.on('error', (err) => {
  console.error('Redis Client Error', err);
}
);
redisClient.on('connect', () => {
  console.log('Connected to Redis');
});
redisClient.on('ready', () => {
  console.log('Redis is ready');
});
redisClient.on('end', () => {
  console.log('Redis connection closed');
});
redisClient.connect().catch((err) => {
  console.error('Failed to connect to Redis', err);
}
);
module.exports = redisClient;
// This module exports a configured Redis client instance.
// It handles connection events and errors, ensuring that the client is ready for use in the application.