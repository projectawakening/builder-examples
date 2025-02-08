import worldAbi from "contracts/out/IWorld.sol/IWorld.abi.json";

import {IWorldAbi} from "@eveworld/contracts"

export const chainId = parseInt(import.meta.env.VITE_CHAIN_ID) || 31337;
export const url = new URL(window.location.href);

const abi = worldAbi.concat(IWorldAbi.abi)

console.log(abi)

export { abi as worldAbi };