// mongo-init.js
db = db.getSiblingDB('nodejs_api');
db.createUser({
  user: 'node',
  pwd: 'Node@123',
  roles: [{ role: 'readWrite', db: 'nodejs_api' }]
});
