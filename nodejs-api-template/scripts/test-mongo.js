const mongoose = require('mongoose');

const uri = 'mongodb://node:Node%40123@localhost:27017/nodejs_api';

mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB connected successfully'))
  .catch(err => console.error('MongoDB connection test failed with error:', err));
