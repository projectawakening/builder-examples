const { randomBytes } = require('crypto');

const key = randomBytes(32);

const hexKey = key.toString('hex');
console.log('New Generated Key:', hexKey);