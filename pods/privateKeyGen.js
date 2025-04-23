const { randomBytes } = require('crypto');
const { deriveSignerPublicKey } = require('@pcd/pod');

const key = randomBytes(32);

//Convert the key to a hex string
const privateSigningKey = key.toString('hex');
console.log("Generated Private Key:")
console.log(privateSigningKey);

//Output Signer Public Key
const publicSigningKey = deriveSignerPublicKey(privateSigningKey);
console.log("\nGenerated Signer Public Key:")
console.log(publicSigningKey)