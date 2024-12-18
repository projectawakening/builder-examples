import { Severity, SmartAssemblyType } from "@eveworld/types";
import { ERRORS, findOwnerByAddress, TYPEIDS } from "@eveworld/utils";

const getSaltQuantity = async ({
	smartAssembly,
	walletAddress,
}: {
	smartAssembly: SmartAssemblyType<"SmartStorageUnit">;
	walletAddress: string;
}) => {
	// TODO: Fix smart assembly ws refreshing
	const playerInventory = smartAssembly.inventory.ephemeralInventoryList.find(
		(x) => findOwnerByAddress(x.ownerId, walletAddress)
	);

	return playerInventory?.ephemeralInventoryItems.find(
		(x) => x.typeId == TYPEIDS.SALT
	);
};

export const sellItems = async ({
	worldContract,
	smartAssembly,
	stackQty,
	stackSize,
	walletAddress,
	notify,
}: {
	worldContract: any;
	smartAssembly: SmartAssemblyType<"SmartStorageUnit">;
	stackQty: number;
	stackSize: number;
	walletAddress: string;
	notify: (notification: {
		type: Severity;
		txHash?: string;
		message?: string;
		errorCode?: number;
	}) => void;
}) => {
	const sellItems = async (quantity: number): Promise<string | void> => {
		if (!worldContract) return console.error("Unable to get world contract");
		return await worldContract.write.itemtrade__sellItems([
			BigInt(smartAssembly.id),
			BigInt(import.meta.env.VITE_SELL_ITEM_ID),
			BigInt(quantity),
		]);
	};

	try {
		/**
		 * If account does not have enough salt, inform user
		 */
		const playerSalt = await getSaltQuantity({ smartAssembly, walletAddress });

		if (!playerSalt?.quantity || playerSalt.quantity < stackQty * stackSize) {
			return notify({
				type: Severity.Error,
				errorCode: ERRORS.INSUFFICIENT_EVE.code,
				message: "You don't have enough salt",
			});
		}

		sellItems(stackQty * stackSize);
		return;
	} catch (e) {
		console.error(e);
	}
};
