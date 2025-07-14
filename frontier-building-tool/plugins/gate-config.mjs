import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';

const contractsPath = '../../packages/contracts/';

export async function execute() {
  console.log(chalk.yellow('[INFO]'), 'This script will update the config for the smart gate example.\n');

  const sourceGateId = await validateInput('Please enter the source gate ID: ', 1, 10);
  const destinationGateId = await validateInput('Please enter the destination gate ID: ', 1, 10);
  const allowedTribeId = await validateInput('Please enter the allowed tribe ID: ', 1, 30);

  console.log("");

  const updates = [
    {
      path: contractsPath + '.env',
      pattern: /^SOURCE_GATE_ID=.*/m,
      replacement: `SOURCE_GATE_ID=${sourceGateId}`
    },
    {
      path: contractsPath + '.env',
      pattern: /^DESTINATION_GATE_ID=.*/m,
      replacement: `DESTINATION_GATE_ID=${destinationGateId}`
    },
    {
      path: contractsPath + '.env',
      pattern: /^ALLOWED_TRIBE_ID=.*/m,
      replacement: `ALLOWED_TRIBE_ID=${allowedTribeId}`
    }   
  ];

  updateFiles(updates);
} 