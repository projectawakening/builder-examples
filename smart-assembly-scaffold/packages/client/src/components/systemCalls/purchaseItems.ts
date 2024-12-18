import { getSchemaPrimitives } from "@latticexyz/protocol-parser/internal";

export const purchaseItems = async ({
	itemPrice,
	quantity,
	worldContract,
    erc20Contract
}: {
	itemPrice?: getSchemaPrimitives<{
        readonly smartObjectId: {
            readonly type: "uint256";
            readonly internalType: "uint256";
        };
        readonly itemOutId: {
            readonly type: "uint256";
            readonly internalType: "uint256";
        };
        readonly isSet: {
            readonly type: "bool";
            readonly internalType: "bool";
        };
        readonly price: {
            readonly type: "uint256";
            readonly internalType: "uint256";
        };
    }>;
	quantity: number;
	worldContract: any;
	erc20Contract: any;
}): Promise<string | undefined> => {
	if (!itemPrice) throw "Unable to retrieve item price";
	if (Number(itemPrice.price) == 0) throw "Item price not set";

	const itemSellerContractAddress =
		await worldContract.read.itemtrade__getItemTradeContractAddress();
	const approvalAmount = quantity * Number(itemPrice.price);

	// First, approve spend by the contract address
	await erc20Contract.write.approve([
		itemSellerContractAddress,
		BigInt(approvalAmount)
	]);

	// Then, purchase item
	const txHash = await worldContract.write.itemtrade__purchaseItems([
		itemPrice.smartObjectId,
		itemPrice.itemOutId,
		BigInt(quantity),
	]);

	return txHash
};
