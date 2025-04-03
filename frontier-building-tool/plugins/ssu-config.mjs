import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';

const contractsPath = '../../packages/contracts/';

export async function execute() {
  console.log(chalk.yellow('[INFO]'), 'This script will update the config for the smart storage unit example.\n');

  const ssuId = await validateInput('Please enter the Smart Storage Unit ID: ', 10, 20);
  const itemId = await validateInput('Please enter the item in (item bought) ID: ', 6, 30);
  const itemOutId = await validateInput('Please enter the item out (item sold) ID: ', 6, 30);
  const inRatio = await validateInput('Please enter the in ratio: ', 6, 30);
  const outRatio = await validateInput('Please enter the out ratio: ', 6, 30);

  console.log("");

  const updates = [
    {
      path: contractsPath + '.env',
      pattern: /^SSU_ID=.*/m,
      replacement: `SSU_ID=${ssuId};`
    },
    {
      path: contractsPath + '.env',
      pattern: /^ITEM_ID=.*/m,
      replacement: `ITEM_ID=${itemId}`
    },
    {
      path: contractsPath + '.env',
      pattern: /^ITEM_OUT_ID=.*/m,
      replacement: `ITEM_OUT_ID=${itemOutId}`
    },
    {
      path: contractsPath + '.env',
      pattern: /^IN_RATIO=.*/m,
      replacement: `IN_RATIO=${inRatio}`
    },
    {
      path: contractsPath + '.env',
      pattern: /^OUT_RATIO=.*/m,
      replacement: `OUT_RATIO=${outRatio}`
    }
  ];

  updateFiles(updates);
} 