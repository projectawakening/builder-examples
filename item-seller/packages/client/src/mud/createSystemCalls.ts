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
	{ worldContract, erc20Contract, waitForTransaction }: SetupNetworkResult,
	{ ItemPrice, ItemSellerERC20 }: ClientComponents
) {
	/*
	 * This function is retrieved from the codegen function in contracts/src/codegen/world/IItemSeller.sol
	 * And must be used with the test2__ prefix due to namespacing
	 */

	const smartObjectId = import.meta.env.VITE_SMARTASSEMBLY_ID;
	const itemId = import.meta.env.VITE_INVENTORY_ITEM_ID;

	const entity = encodeEntity(mudConfig.tables.ItemSellerERC20.keySchema, {
		smartObjectId,
	});
	const item = encodeEntity(mudConfig.tables.ItemPrice.keySchema, {
		smartObjectId,
		itemId,
	});

	const getERC20Data = async (smartObjectId) => {
		await worldContract.write.test2__getERC20Data([smartObjectId]);
		const result = getComponentValue(ItemSellerERC20, entity);
		return result;
	};

	const registerERC20Token = async (smartObjectId, tokenAddress, receiver) => {
		await worldContract.write.test2__registerERC20Token([
			smartObjectId,
			tokenAddress,
			receiver,
		]);
		return getComponentValue(ItemSellerERC20, entity);
	};

	const updateERC20Receiver = async (smartObjectId, receiver) => {
		await worldContract.write.test2__updateERC20Receiver([
			smartObjectId,
			receiver,
		]);
		return getComponentValue(ItemSellerERC20, entity);
	};

	/** ITEM PRICE FUNCTIONS */

	const getItemPriceData = async (smartObjectId, inventoryItemId) => {
		await worldContract.write.test2__getItemPriceData([
			smartObjectId,
			inventoryItemId,
		]);
		return getComponentValue(ItemPrice, item);
	};

	const setItemPrice = async (smartObjectId, inventoryItemId, price) => {
		await worldContract.write.test2__setItemPrice([
			smartObjectId,
			inventoryItemId,
			price,
		]);

		return getComponentValue(ItemPrice, item);
	};

	const unsetItemPrice = async (smartObjectId, inventoryItemId) => {
		await worldContract.write.test2__unsetItemPrice([
			smartObjectId,
			inventoryItemId,
		]);
		return getComponentValue(ItemPrice, item);
	};

	/** PURCHASE ITEM FUNCTIONS */
	const purchaseItem = async (smartObjectId, inventoryItemId, quantity) => {
		const itemPrice = getComponentValue(ItemPrice, item);
		if (!itemPrice) return console.error("Unable to retrieve item price");
		if (Number(itemPrice.price) == 0) return console.error("Item price not set");

		const itemSellerContractAddress = await worldContract.read.test2__getContractAddress()
		const approvalAmount = quantity * Number(itemPrice.price);

		// First, approve spend by the contract address
		//TODO: Fix stack underflow error
		await erc20Contract.write.approve([
			itemSellerContractAddress,
			BigInt(approvalAmount),
		]);

		// Then, purchase item
		await worldContract.write.test2__purchaseItem([
			BigInt(smartObjectId),
			BigInt(inventoryItemId),
			BigInt(quantity),
		]);

		return;
	};
	const collectTokens = async (smartObjectId) => {
		await worldContract.write.test2__collectTokens([smartObjectId]);

		return getComponentValue(ItemPrice, item);
	};

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
