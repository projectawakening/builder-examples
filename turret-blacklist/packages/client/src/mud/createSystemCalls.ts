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
  { worldContract, useStore, tables }: SetupNetworkResult
) {
	/*
	 * This function is retrieved from the codegen function in contracts/src/codegen/world/IItemTradeSystem.sol
	 * And must be used with the test__ prefix due to namespacing
	 */

  const getBlacklistKeyword = async (smartObjectId) => {
    const keyword = await worldContract.read.murderous__getBlacklistKeyword([
			smartObjectId,
		]);
    return keyword
	};

  const getBlacklistKeywordFromStore = async (smartObjectId) => {
    const result = useStore.getState().getValue(tables.TurretBlacklist, {smartObjectId})
		return result;
	};

  const setBlacklistKeyword = async (smartObjectId, keyword) => {
    
		await worldContract.write.murderous__setBlacklistKeyword([
			BigInt(smartObjectId),
      keyword
		]);		
	};
  
  const setBlacklistStatus = async (smartObjectId, isTrue) => {
		await worldContract.write.murderous__setBlacklistStatus([
			smartObjectId,
      isTrue
		]);		
	};

	return {
    getBlacklistKeywordFromStore,
    setBlacklistKeyword,
    setBlacklistStatus,
    getBlacklistKeyword
	};
}
