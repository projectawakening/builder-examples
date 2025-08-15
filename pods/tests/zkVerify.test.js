const { execSync } = require('child_process');
const path = require('path');

test('zkVerify.ts should output expected verification messages', () => {
  // Run the zkVerify.ts script
  const output = execSync('npx tsx zkVerify.ts', { 
    cwd: path.join(__dirname, '..'),
    encoding: 'utf8' 
  });

  // Check that all expected verification messages are present
  expect(output).toContain('Proof is valid');
  expect(output).toContain('Correct POD Type');
  expect(output).toContain('Verified security badge for character');
  expect(output).toContain('0x6d11ac8f376b6284a7e5d62a340f71869b3063ae');
});

test('zkVerify.ts should complete successfully without errors', () => {
  // Run the zkVerify.ts script and ensure it doesn't throw
  expect(() => {
    execSync('npx tsx zkVerify.ts', { 
      cwd: path.join(__dirname, '..'),
      encoding: 'utf8' 
    });
  }).not.toThrow();
});