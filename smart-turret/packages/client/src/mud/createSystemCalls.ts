/*
 * Create the system calls that the client can use to ask
 * for changes in the World state (using the System contracts).
 */

import { SetupNetworkResult } from "./setupNetwork";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  /*
   * The parameter list informs TypeScript that:
   *
   * - The first parameter is expected to be a
   *   SetupNetworkResult, as defined in setupNetwork.ts
   *
   *   Out of this parameter, we care about the following fields:
   *   - worldContract (which comes from getContract, see
   *     https://github.com/latticexyz/mud/blob/main/templates/react/packages/client/src/mud/setupNetwork.ts#L63-L69).
   *   
   *   - erc20Contract 
   *   - useStore
   *   - tables
   */
  { worldContract, erc20Contract, useStore, tables }: SetupNetworkResult
) {
	/*
	 * This function is retrieved from the codegen function in contracts/src/codegen/world/IItemTradeSystem.sol
	 * And must be used with the test__ prefix due to namespacing
	 */

  const getWhitelist = async () => {
    var id = import.meta.env.VITE_SMART_TURRET_ID
    console.log("GET:", id);
		const result = useStore.getState().getValue(tables.TurretWhitelist, {id})
    console.log(result);
		return result;
	};

  const addToWhitelist = async (char) => {
    var id = import.meta.env.VITE_SMART_TURRET_ID
		const result = await worldContract.write.dapp_dev__addToWhitelist([
			id,
      char
		]);		

    return await useStore.getState().getValue(tables.TurretWhitelist, {id});
	};
  
  const removeFromWhitelist = async (char) => {
    var id = import.meta.env.VITE_SMART_TURRET_ID
		const result = await worldContract.write.dapp_dev__removeFromWhitelist([
			id,
      char
		]);		

    console.log("RESULT: ", result);

    return await useStore.getState().getValue(tables.TurretWhitelist, {id});
	};

	return {
    getWhitelist,
    addToWhitelist,
    removeFromWhitelist
	};
}
