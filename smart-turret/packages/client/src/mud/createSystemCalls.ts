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
  { worldContract, useStore, tables, waitForTransaction }: SetupNetworkResult
) {
  const getWhitelist = async () => {
    var id = import.meta.env.VITE_SMART_TURRET_ID
		const result = useStore.getState().getValue(tables.TurretWhitelist, {id})
		return result;
	};

  const addToWhitelist = async (char) => {
    var id = import.meta.env.VITE_SMART_TURRET_ID
		const transaction = await worldContract.write.dapp_dev2__addToWhitelist([
			id,
      char
		]);		

    await waitForTransaction(transaction);

    return useStore.getState().getValue(tables.TurretWhitelist, {id});
	};
  
  const removeFromWhitelist = async (char) => {
    var id = import.meta.env.VITE_SMART_TURRET_ID
		const transaction = await worldContract.write.dapp_dev2__removeFromWhitelist([
			id,
      char
		]);		
    
    await waitForTransaction(transaction);

    return useStore.getState().getValue(tables.TurretWhitelist, {id});
	};

	return {
    getWhitelist,
    addToWhitelist,
    removeFromWhitelist
	};
}
