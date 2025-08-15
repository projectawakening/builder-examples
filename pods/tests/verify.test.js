const { execSync } = require('child_process');
const path = require('path');

test('verify.ts should output expected verification messages', () => {
  // Run the verify.ts script
  const output = execSync('npx tsx verify.ts', { 
    cwd: path.join(__dirname, '..'),
    encoding: 'utf8' 
  });

  // Check that all expected verification messages are present
  expect(output).toContain('Verified POD');
  expect(output).toContain('Verified Official Signer');
  expect(output).toContain('Verified Official Pod Type');
  expect(output).toContain('Level:');
  expect(output).toContain('4n');
});

test('verify.ts should complete successfully without errors', () => {
  // Run the verify.ts script and ensure it doesn't throw
  expect(() => {
    execSync('npx tsx verify.ts', { 
      cwd: path.join(__dirname, '..'),
      encoding: 'utf8' 
    });
  }).not.toThrow();
});