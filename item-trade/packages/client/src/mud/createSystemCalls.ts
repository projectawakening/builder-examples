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

	const smartObjectId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);
	const itemInId = import.meta.env.VITE_ITEM_IN_ID;
	const itemOutId = import.meta.env.VITE_ITEM_OUT_ID;

	const getERC20Data = async () => {
		const result = useStore.getState().getValue(tables.ItemTradeERC20, {smartObjectId})
		return result;
	};

	const registerERC20Token = async (smartObjectId, tokenAddress, receiver) => {
		await worldContract.write.test__registerERC20Token([
			smartObjectId,
			tokenAddress,
			receiver,
		]);
		return useStore.getState().getValue(tables.ItemTradeERC20, {smartObjectId});
	};

	const updateERC20Receiver = async (smartObjectId, receiver) => {
		await worldContract.write.test__updateERC20Receiver([
			smartObjectId,
			receiver,
		]);
		return useStore.getState().getValue(tables.ItemTradeERC20, {smartObjectId});
	};

	/** ITEM PRICE FUNCTIONS */

	const getItemPriceData = async () => {
		return useStore.getState().getValue(tables.ItemPriceInToken, {smartObjectId, itemOutId})
	};

	const setItemPrice = async (smartObjectId, price) => {
		await worldContract.write.test__setItemPrice([
			smartObjectId,
			itemOutId,
			price,
		]);

		return useStore.getState().getValue(tables.ItemPriceInToken, {smartObjectId, itemOutId})
	};

	/** PURCHASE ITEM FUNCTIONS */

	const getErc20Balance = async(address) => {
		const balance = await erc20Contract.read.balanceOf([address])
		return balance
	}

	const purchaseItem = async (quantity) => {
		const itemPrice = useStore.getState().getValue(tables.ItemPriceInToken, {smartObjectId, itemOutId})
		if (!itemPrice) return console.error("Unable to retrieve item price");
		if (Number(itemPrice.price) == 0) return console.error("Item price not set");

		const itemSellerContractAddress = await worldContract.read.test__getItemTradeContractAddress()
		const approvalAmount = quantity * Number(itemPrice.price);

		// First, approve spend by the contract address
		await erc20Contract.write.approve([
			itemSellerContractAddress,
			BigInt(approvalAmount),
		]);


		// Then, purchase item
		await worldContract.write.test__purchaseItems([
			smartObjectId,
			BigInt(itemOutId),
			BigInt(quantity),
		]);

		return ;
	};

	/** SELL ITEM FUNCTIONS */

	const getItemSellData = async() => {
		const result = useStore.getState().getValue(tables.ItemQuantityMultipleForToken, {smartObjectId, itemInId})
		return result;
	}

	const setSellConfig = async (smartObjectId, stackQty, tokenAmount) => {
		await worldContract.write.test__setEnforcedItemMultiple([
			BigInt(smartObjectId),
			BigInt(itemInId),
			BigInt(stackQty),
			BigInt(tokenAmount)
		])

		return useStore.getState().getValue(tables.ItemQuantityMultipleForToken, {smartObjectId})
	}

	const sellItem = async (smartObjectId, quantity) => {
		await worldContract.write.test__sellItems([
			BigInt(smartObjectId),
			BigInt(itemInId),
			BigInt(quantity),
		]);


		return;
	};


	const collectTokens = async (smartObjectId, address) => {
		// await worldContract.write.test__collectTokens([smartObjectId]);
		return await getErc20Balance(address)
	};

	return {
		registerERC20Token,
		updateERC20Receiver,
		setItemPrice,
		purchaseItem,
		collectTokens,
		getItemPriceData,
		getERC20Data,
		getErc20Balance,
		getItemSellData,
		setSellConfig,
		sellItem,
	};
}
