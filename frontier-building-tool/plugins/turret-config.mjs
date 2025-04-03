import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';

const contractsPath = '../../packages/contracts/';

export async function execute() {
  console.log(chalk.yellow('[INFO]'), 'This script will update the config for the smart gate example.\n');

  const turretId = await validateInput('Please enter the turret ID: ', 1, 10);
  const allowedCorpId = await validateInput('Please enter the allowed corp ID: ', 1, 30);

  console.log("");

  const updates = [
    {
      path: contractsPath + '.env',
      pattern: /^TURRET_ID=.*/m,
      replacement: `TURRET_ID=${turretId}`
    },
    {
      path: contractsPath + '.env',
      pattern: /^ALLOWED_CORP_ID=.*/m,
      replacement: `ALLOWED_CORP_ID=${allowedCorpId}`
    }   
  ];

  updateFiles(updates);
} 