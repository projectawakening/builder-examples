const { execSync } = require('child_process');
const path = require('path');

const expected_proof_object = { "proof": { "pi_a": ["19422264465599120829413134707921120792898747441591092480110226800152887771632", "76668257518837011009133165568118868082109118870224914950059612658819936337", "1"], "pi_b": [["4751652970105025117938707035093134573565924324166271307597793324099305626945", "13000436457844789009451957634837948759190753576765008061726979029295173565072"], ["19679450527765739065612224512657260314485025347050953832111182431691642962423", "21674794968335730448278634775576330173189820174499301537884436703007112889680"], ["1", "0"]], "pi_c": ["3895276841122257935955558819701669544891619058280315081667699610724664954703", "21825778419765792265241267634764374651144907315174272222386073015015838587194", "1"], "protocol": "groth16", "curve": "bn128" }, "boundConfig": { "circuitIdentifier": "proto-pod-gpc_1o-12e-5md-4nv-0ei-1x5l-0x0t-0ov3-1ov4", "pods": { "security_badge": { "entries": { "expiry_date": { "isRevealed": false, "inRange": { "min": 1746835200000, "max": 1902009600000 } }, "holder_smart_character_address": { "isRevealed": true }, "issued_date": { "isRevealed": false, "inRange": { "min": 0, "max": 1746835200000 } }, "pod_type": { "isRevealed": true }, "security_level": { "isRevealed": false, "inRange": { "min": 3, "max": 10 } } } } } }, "revealedClaims": { "pods": { "security_badge": { "entries": { "holder_smart_character_address": "0x6d11ac8f376b6284a7e5d62a340f71869b3063ae", "pod_type": "corpName.security_badge" }, "signerPublicKey": "3iREOe5OdCEZ0KaF4pOfFc5nMvG6iZbY7GeaMy2P3xw" } } } }

test('zkCreate.ts output should match expected Proof structure', () => {
  // Run the create.ts script
  const output = execSync('npx tsx zkCreate.ts', {
    cwd: path.join(__dirname, '..'),
    encoding: 'utf8',
    timeout: 10000
  });

  const lines = output.split('\n');
  const stringifiedLine = lines.find(line =>
    line.trim().startsWith('{"proof":') &&
    line.includes('"protocol":"groth16"') &&
    line.includes('"curve":"bn128"')
  );

  if (!stringifiedLine) {
    throw new Error('Could not find stringified JSON output in create.ts');
  }

  const actualProofData = JSON.parse(stringifiedLine);

  expect(actualProofData.revealedClaims).toEqual(expected_proof_object.revealedClaims);
  expect(actualProofData.boundConfig).toEqual(expected_proof_object.boundConfig);
});

test('zkCreate.ts should complete successfully without errors', () => {
  // Run the zkCreate.ts script and ensure it doesn't throw
  expect(() => {
    execSync('npx tsx zkCreate.ts', {
      cwd: path.join(__dirname, '..'),
      encoding: 'utf8'
    });
  }).not.toThrow();
});