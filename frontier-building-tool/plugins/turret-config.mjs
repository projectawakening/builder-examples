import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';

const contractsPath = '../../packages/contracts/';

export async function execute() {
  console.log(chalk.yellow('[INFO]'), 'This script will update the config for the smart turret example.\n');

  const turretId = await validateInput('Please enter the turret ID: ', 1, 10);
  const allowedTribeId = await validateInput('Please enter the allowed tribe ID: ', 1, 30);

  console.log("");

  const updates = [
    {
      path: contractsPath + '.env',
      pattern: /^TURRET_ID=.*/m,
      replacement: `TURRET_ID=${turretId}`
    },
    {
      path: contractsPath + '.env',
      pattern: /^ALLOWED_TRIBE_ID=.*/m,
      replacement: `ALLOWED_TRIBE_ID=${allowedTribeId}`
    }   
  ];

  updateFiles(updates);
} 