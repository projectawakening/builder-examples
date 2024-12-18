import worldAbi from "contracts/out/IWorld.sol/IWorld.abi.json";

export const chainId = parseInt(import.meta.env.VITE_CHAIN_ID) || 31337;
export const url = new URL(window.location.href);

export { worldAbi };
