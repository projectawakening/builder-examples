import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';
import { join } from 'path';

export async function execute({ contracts, params }, additionalArg) {
  console.log(chalk.yellow('[INFO]'), 'This script will update the namespace for your contract deployment.\n');

  const namespace = additionalArg || await validateInput('Please type your namespace: ', 2, 14);

  console.log("");

  const updates = [
    {
      path: join(contracts, 'src/systems/constants.sol'),
      pattern: /^bytes14 constant DEPLOYMENT_NAMESPACE.*/m,
      replacement: `bytes14 constant DEPLOYMENT_NAMESPACE = "${namespace}";`
    },
    {
      path: join(contracts, 'mud.config.ts'),
      pattern: /^  namespace.*/m,
      replacement: `  namespace: "${namespace}",`
    }
  ];

  updateFiles(updates);
} 