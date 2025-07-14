#!/usr/bin/env node

import { fileURLToPath } from 'url';
import { dirname, join, resolve } from 'path';
import { loadPlugins } from './plugins.mjs';
import chalk from 'chalk';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function findProjectRoot(startPath) {
  let currentPath = startPath;
  
  let maxSearches = 6;
  
  while (currentPath !== '/' && maxSearches > 0) {
    if (currentPath.endsWith('/packages/contracts')) {
      return dirname(dirname(currentPath));
    }
    
    const potentialContractsDir = join(currentPath, 'packages/contracts');
    try {
      if (fs.existsSync(potentialContractsDir)) {
        return currentPath;
      }
    } catch (err) {
    }
    
    currentPath = dirname(currentPath);
    maxSearches--;
  }
  
  return startPath;
}

const rootDir = findProjectRoot(process.cwd());
const contractsDir = join(rootDir, 'packages/contracts');
const clientDir = join(rootDir, 'packages/client');

const scriptDir = __dirname;

export const paths = {
  root: rootDir,
  script: scriptDir,
  contracts: contractsDir,
  client: clientDir
};

process.on('uncaughtException', (error) => {
  if (error instanceof Error && error.name === 'ExitPromptError') {
    console.log("");
    console.log(chalk.yellow('[INFO]'), 'Cancelled tool execution');
    process.exit(0);
  }
});

async function errorMessage(plugins){  
  console.error('Available plugins:', Object.keys(plugins).join(', '));
  console.error(`\nMore information about this tool can be found at: ${chalk.yellowBright('https://github.com/CCP-Red-Dragon/eve-frontier-builder-tools')}\n`);
}

async function main() {
  try {
    const plugins = await loadPlugins();
    
    let pluginName;
    let additionalArg = '';
    const args = process.argv.slice(2);

    if (args[0] === '--plugin' || args[0] === '-p') {
      pluginName = args[1];
      additionalArg = args[2];
    } else {
      pluginName = args[0];
      additionalArg = args[1];
    }

    if (!pluginName) {
      console.error('\nPlease specify a plugin name');
      console.error('Usage: frontier <plugin-name>');
      console.error('   or: frontier --plugin <plugin-name>');
      errorMessage(plugins);
      process.exit(1);
    }

    const plugin = plugins[pluginName];
    if (!plugin) {
      console.error(`\nPlugin "${pluginName}" not found`);
      errorMessage(plugins);
      process.exit(1);
    }

    await plugin.execute(paths, additionalArg);
  } catch (error) {
    if (error.name === 'ExitPromptError') {
      console.log("\n" + chalk.yellow('[INFO]'), 'Cancelled command execution');
      process.exit(0);
    }
    console.error(chalk.red('[ERROR]'), error.message);
    process.exit(1);
  }
}

main();