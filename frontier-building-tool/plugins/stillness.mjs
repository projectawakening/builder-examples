import chalk from 'chalk';
import { validateInput, updateFiles } from '../utils.mjs';
import { join } from 'path';
import axios from 'axios';

const fallbackStillnessEnv = {
  WORLD_ADDRESS: "0x7fe660995b0c59b6975d5d59973e2668af6bb9c5",
  CHAIN_ID: "17069",
  RPC_URL: "https://rpc.stillness.xyz",
  SERVER: "Stillness"
}

export async function execute({ contracts, params }) {
  console.log("");

  const stillness = await axios.get('https://world-api-stillness.live.tech.evefrontier.com/config');
  const stillnessResponse = stillness.data;

  let stillnessEnv = fallbackStillnessEnv;

  if(stillnessResponse && stillnessResponse.length > 0) {
    let config = stillnessResponse[0];
    stillnessEnv = {
      WORLD_ADDRESS: config.contracts.world.address,
      CHAIN_ID: config.chainId,
      RPC_URL: config.rpcUrls.default.http,
      SERVER: "Stillness"
    }
  } 

  const updates = [
    {
      path: join(contracts, '.env'),
      pattern: /^WORLD_ADDRESS=.*/m,
      replacement: `WORLD_ADDRESS=${stillnessEnv.WORLD_ADDRESS}`,
      message: `WORLD_ADDRESS`
    },
    {
      path: join(contracts, '.env'),
      pattern: /^CHAIN_ID=.*/m,
      replacement: `CHAIN_ID=${stillnessEnv.CHAIN_ID}`,
      message: `CHAIN_ID`
    },
    {
      path: join(contracts, '.env'),
      pattern: /^RPC_URL=.*/m,
      replacement: `RPC_URL=${stillnessEnv.RPC_URL} #${stillnessEnv.SERVER} RPC URL`,
      message: `RPC_URL`
    },    
  ];

  updateFiles(updates);
} 