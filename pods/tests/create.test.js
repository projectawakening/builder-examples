const { execSync } = require('child_process');
const path = require('path');

const expected_pod_object = {
    entries: {
      expiry_date: { date: '2026-04-10T00:00:00.000Z' },
      holder_smart_character_address: '0x6d11ac8f376b6284a7e5d62a340f71869b3063ae',
      issued_date: { date: '2025-04-10T00:00:00.000Z' },
      pod_type: 'corpName.security_badge',
      security_level: 4
    },
    signature: 'GfpAbL4XJzSVZUg2XmnPLlIl0Yt1e0JCG+CKNfNQi5FFT3P7L2aCxnmNmSoDGXahvaqhOcXtjGybD1ZH39ZXAQ',
    signerPublicKey: '3iREOe5OdCEZ0KaF4pOfFc5nMvG6iZbY7GeaMy2P3xw'
}

test('create.ts output should match expected POD structure', () => {
  // Run the create.ts script
  const output = execSync('npx tsx create.ts', { 
    cwd: path.join(__dirname, '..'),
    encoding: 'utf8' 
  });

  const lines = output.split('\n');
  const stringifiedLine = lines.find(line => 
    line.trim().startsWith('{"entries":') && 
    line.includes('"security_level":4') &&
    line.includes('"holder_smart_character_address":"0x6d11ac8f376b6284a7e5d62a340f71869b3063ae"')
  );
  
  if (!stringifiedLine) {
    throw new Error('Could not find stringified JSON output in create.ts');
  }

  const actualPodData = JSON.parse(stringifiedLine);

  expect(actualPodData).toEqual(expected_pod_object);
});