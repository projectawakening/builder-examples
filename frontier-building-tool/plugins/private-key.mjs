import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';
import { join } from 'path';

export async function execute({ contracts, params }) {
  console.log(chalk.yellow('[INFO]'), 'This script will update the private key.\n');

  const privateKey = await validateInput('Please type your private key: ', 10, 100);

  console.log("");

  const updates = [
    {
      path: join(contracts, '.env'),
      pattern: /^PRIVATE_KEY=.*/m,
      replacement: `PRIVATE_KEY=${privateKey}`
    }
  ];

  updateFiles(updates);
} 