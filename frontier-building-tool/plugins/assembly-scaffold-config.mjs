import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';

const contractsPath = '../../packages/contracts/';
const clientPath = '../../packages/client/';

export async function execute() {
  console.log(chalk.yellow('[INFO]'), 'This script will update the config for the smart storage unit example.\n');

  const ssuId = await validateInput('Please enter the Smart Storage Unit ID: ', 10, 100);

  console.log("");

  const updates = [
    {
      path: contractsPath + '.env',
      pattern: /^SSU_ID=.*/m,
      replacement: `SSU_ID=${ssuId}`
    },
    {
      path: clientPath + '.env',
      pattern: /^VITE_SMARTASSEMBLY_ID=.*/m,
      replacement: `VITE_SMARTASSEMBLY_ID=${ssuId}`
    }
  ];

  updateFiles(updates);
} 