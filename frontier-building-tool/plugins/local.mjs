import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';
import { join } from 'path';

const localEnv = {
  WORLD_ADDRESS: "0x0165878a594ca255338adfa4d48449f69242eb8f",
  CHAIN_ID: "31337",
  RPC_URL: "http://127.0.0.1:8545",
  SERVER: "Local"
}

export async function execute({ contracts, params }) {
  console.log("");

  const updates = [
    {
      path: join(contracts, '.env'),
      pattern: /^WORLD_ADDRESS=.*/m,
      replacement: `WORLD_ADDRESS=${localEnv.WORLD_ADDRESS}`,
      message: `WORLD_ADDRESS`
    },
    {
      path: join(contracts, '.env'),
      pattern: /^CHAIN_ID=.*/m,
      replacement: `CHAIN_ID=${localEnv.CHAIN_ID}`,
      message: `CHAIN_ID`
    },
    {
      path: join(contracts, '.env'),
      pattern: /^RPC_URL=.*/m,
      replacement: `RPC_URL=${localEnv.RPC_URL} #${localEnv.SERVER} RPC URL`,
      message: `RPC_URL`
    },    
  ];

  updateFiles(updates);
} 