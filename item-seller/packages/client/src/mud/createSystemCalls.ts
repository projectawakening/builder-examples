/*
 * Create the system calls that the client can use to ask
 * for changes in the World state (using the System contracts).
 */

import { getComponentValue } from "@latticexyz/recs";
import { ClientComponents } from "./createClientComponents";
import { SetupNetworkResult } from "./setupNetwork";
import { encodeEntity } from "@latticexyz/store-sync/recs";
import mudConfig from "item-seller-contracts/mud.config";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  /*
   * The parameter list informs TypeScript that:
   *
   * - The first parameter is expected to be a
   *   SetupNetworkResult, as defined in setupNetwork.ts
   *
   *   Out of this parameter, we only care about two fields:
   *   - worldContract (which comes from getContract, see
   *     https://github.com/latticexyz/mud/blob/main/templates/react/packages/client/src/mud/setupNetwork.ts#L63-L69).
   *
   *   - waitForTransaction (which comes from syncToRecs, see
   *     https://github.com/latticexyz/mud/blob/main/templates/react/packages/client/src/mud/setupNetwork.ts#L77-L83).
   *
   * - From the second parameter, which is a ClientComponent,
   *   we only care about Counter. This parameter comes to use
   *   through createClientComponents.ts, but it originates in
   *   syncToRecs
   *   (https://github.com/latticexyz/mud/blob/main/templates/react/packages/client/src/mud/setupNetwork.ts#L77-L83).
   */
  { worldContract, waitForTransaction }: SetupNetworkResult,
  { Balances, FunctionSelectors, Hooks, ItemPrice, ItemSellerERC20, Systems, StoreHooks }: ClientComponents
) {
    /*
     * This function is retrieved from the codegen function in contracts/src/godegen/world/IITemSeller.sol
     * And must be used with the test2__ prefix due to namespacing
     */

  const entity = encodeEntity(mudConfig.tables.ItemSellerERC20.keySchema, {smartObjectId: import.meta.env.VITE_SMARTASSEMBLY_ID})

  const getERC20Data = async (smartObjectId) => {
    const tx = await worldContract.write.test2__getERC20Data([smartObjectId]);
    await waitForTransaction(tx);
    const result = getComponentValue(ItemSellerERC20, entity)
    return result;
  }

  const registerERC20Token = async (smartObjectId, tokenAddress, receiver) => {
    const tx = await worldContract.write.test2__registerERC20Token([smartObjectId, tokenAddress, receiver]);
    await waitForTransaction(tx);
    return getComponentValue(ItemSellerERC20, entity);
  }

  const updateERC20Receiver = async (smartObjectId, receiver) => {
    const tx = await worldContract.write.test2__updateERC20Receiver([smartObjectId, receiver]);
    await waitForTransaction(tx);
    return getComponentValue(ItemSellerERC20, entity);
  }

  /** ITEM PRICE FUNCTIONS */

  const setItemPrice = async (smartObjectId, inventoryItemId, price) => {
    const tx = await worldContract.write.test2__setItemPrice([smartObjectId, inventoryItemId, price]);
    await waitForTransaction(tx);
    return getComponentValue(ItemPrice, singletonEntity);
  }

  const unsetItemPrice = async (smartObjectId, inventoryItemId) => {
    const tx = await worldContract.write.test2__unsetItemPrice([smartObjectId, inventoryItemId]);
    await waitForTransaction(tx);
    return getComponentValue(ItemPrice, singletonEntity);
  }

  const purchaseItem = async (smartObjectId, inventoryItemId, quantity) => {
    const tx = await worldContract.write.test2__purchaseItem([smartObjectId, inventoryItemId, quantity]);
    await waitForTransaction(tx);
    return getComponentValue(ItemPrice, singletonEntity);
  }
  const collectTokens = async (smartObjectId) => {
    const tx = await worldContract.write.test2__collectTokens([smartObjectId]);
    await waitForTransaction(tx);
    return getComponentValue(ItemPrice, singletonEntity);
  }

  const getItemPriceData = async (smartObjectId, inventoryItemId) => {
    const tx = await worldContract.write.test2__getItemPriceData([smartObjectId, inventoryItemId]);
    await waitForTransaction(tx);
    return getComponentValue(ItemPrice, singletonEntity);
  }

  return {
    registerERC20Token,
    updateERC20Receiver,
    setItemPrice,
    unsetItemPrice,
    purchaseItem,
    collectTokens,
    getItemPriceData,
    getERC20Data,
  };
}
