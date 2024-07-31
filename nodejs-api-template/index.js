'use strict';

// Load environment variables from .env file
require('dotenv').config();

// Check if environment variables are set
const requiredEnvVars = ['DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DATABASE', 'PORT', 'MONGO_URI', 'MONGO_USER', 'MONGO_PASSWORD', 'POOL_SIZE', 'REDIS_HOST', 'REDIS_PORT'];
const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingEnvVars.length) {
  console.error('Environment variables not found. Please set them in the .env file:', missingEnvVars.join(', '));
  process.exit(1);
}

// Set node environment
if (!process.env.NODE_ENV) process.env.NODE_ENV = 'development';

// Required modules
const express = require('express');
const compression = require('compression');
const helmet = require('helmet');
const cors = require('cors');
const responseTime = require('response-time');
const requestIp = require('request-ip');
const reqlib = require('app-root-path').require;
const logger = reqlib('/helpers/logger');
const SequelizeConn = reqlib('/db/sequelize/sequelize');
const RedisDB = reqlib('/db/redis/redis');
const MongoDB = reqlib('/db/mongo/mongo');
const getMessage = reqlib('/constants/messages');
const { rateLimiter } = reqlib('/middlewares/rateLimiter');

// Initialize express app
const app = express();

// Middleware setup
app.use(cors({ exposedHeaders: ['X-Auth-Token', 'X-Refresh-Token'] }));
app.use(express.urlencoded({ extended: false }));
app.use(express.json({ limit: '1mb' }));
app.use(responseTime());
app.use(helmet());
app.use(compression());
app.use(requestIp.mw({ attributeName: '_clientIpAddress' }));
app.use('/uploads', express.static('uploads'));
app.use('*', (req, res, next) => {
  res.locals._TMP = {
    skipToLastMiddleware: false,
    response: { error: false, errorCode: 0, message: '', data: {} },
    statusCode: 200
  };
  next();
});
app.use(rateLimiter);
app.use((err, req, res, next) => {
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).send({ error: true, message: getMessage['BAD_REQUEST'] });
  }
  next();
});
app.use('/api/v1', reqlib('/routes/v1/index'));
app.use((req, res, next) => {
  res.status(404);
  if (req.accepts('json')) {
    res.send({ error: true, message: getMessage['NOT_FOUND'] });
    return;
  }
  res.type('txt').send(getMessage['NOT_FOUND']);
});

// Exit process with logging message
const exitProcess = (errorMsg, errorObj = null) => {
  console.error(`Date: ${Date.now()}, ${errorMsg}: ${errorObj}`);
  logger.error(`Error msg = ${errorMsg}`, errorObj);
  process.exit(1);
};

// Connect to MySQL
const connectMySQL = async () => {
  try {
    const sequelizeConnObj = new SequelizeConn();
    const connectionStatus = await sequelizeConnObj.connectDB({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DATABASE
    });
    if (!connectionStatus) {
      exitProcess('Unable to connect to MySQL DB');
    }
    console.log('Successfully connected to MySQL DB!');
  } catch (e) {
    exitProcess('Unable to connect to MySQL DB', e);
  }
};

// Connect to Redis
const connectRedis = async () => {
  try {
    const redisDB = new RedisDB();
    const connectionStatus = await redisDB.connectDB();
    if (!connectionStatus) {
      exitProcess('Unable to connect to Redis DB');
    }
    console.log('Successfully connected to Redis DB!');
  } catch (e) {
    exitProcess('Unable to connect to Redis DB', e);
  }
};

// Connect to MongoDB
const connectMongoDB = async () => {
  try {
    const mongoDbObj = new MongoDB();
    const connectionStatus = await mongoDbObj.connectDB();
    if (!connectionStatus) {
      exitProcess('Unable to connect to Mongo DB');
    }
    console.log('Successfully connected to MongoDB!');
  } catch (e) {
    exitProcess('Unable to connect to Mongo DB', e);
  }
};

// Start server
const startServer = async () => {
  await connectMySQL();
  await connectRedis();
  await connectMongoDB();

  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => {
    logger.info(`App listening on port ${PORT}!`);
  });
};

// Handle unhandled rejection
process.on('unhandledRejection', (reason, promise) => {
  console.error('Date ==> ', Date.now(), ', Unhandled Rejection Promise ==> ', promise);
  logger.error('Unhandled Rejection reason : ', reason);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  exitProcess('Uncaught Exception', err);
});

// Call startServer function
startServer();
