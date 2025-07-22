import worldAbiImport from "contracts/out/IWorld.sol/IWorld.abi.json";

export const chainId = parseInt(import.meta.env.VITE_CHAIN_ID) || 31337;
export const url = new URL(window.location.href);

const getAbis = async () => {
  const abiResponse = await fetch(
    "https://world-api-stillness.live.tech.evefrontier.com/abis/config"
  );

  const abi = await abiResponse.json();

  return abi.cfg;
};

/**
 * Finds the configuration object with name="IWorld" from the cfg array
 * @param cfgArray The configuration array to search through
 * @returns The object with name="IWorld" or undefined if not found
 */
const findIWorldConfig = (cfgArray: any[]) => {
  return cfgArray.find((item) => item.name === "IWorld");
};

let worldAbi = [...worldAbiImport];

// Fetch and process the ABI asynchronously
(async () => {
  try {
    const cfgArray = await getAbis();
    const iWorldConfig = findIWorldConfig(cfgArray);

    if (iWorldConfig) {
      worldAbi = worldAbi.concat(iWorldConfig.abi);
    } else {
      console.warn("IWorld configuration not found in the cfg array");
    }
  } catch (error) {
    console.error("Error fetching or processing ABI:", error);
  }
})();

export { worldAbi };
