import { useMUD } from "../MUDContext";
import React, { useRef, useState } from "react";
import { EveButton, TextEdit } from "@eveworld/ui-components";
import { formatEther, parseEther } from "viem";

const ManageItem = React.memo(function ManageItem({
	smartAssemblyId,
}: {
	smartAssemblyId: bigint;
}) {
	const [itemPriceWei, setItemPriceWei] = useState<number | undefined>();
	const [itemQuantity, setItemQuantity] = useState<number | undefined>();
	const [erc20Balance, setErc20Balance] = useState<number | undefined>();

	const inventoryItemId = import.meta.env.VITE_INVENTORY_ITEM_ID

	const {
		network: { walletClient },
		systemCalls: {
			setItemPrice,
			unsetItemPrice,
			getItemPriceData,
			purchaseItem,
			getErc20Balance
		},
	} = useMUD();

	const fetchItemPriceData = async () => {
		const itemPriceData = await getItemPriceData(
			smartAssemblyId,
			inventoryItemId
		);
		setItemPriceWei(Number(itemPriceData?.price ?? 0))
	}

	const itemPriceWeiValueRef = useRef("");

	const handleEdit = (
		refString: React.MutableRefObject<string>,
		eventString: string
	): void => {
		refString.current = eventString;
	};

	return (
		<>
			<div className="Quantum-Container my-4">
				<div>STEP 2: Manage inventory item ID: {inventoryItemId}</div>
				<div className="text-xs">
				You can change this inventory item ID in the .env file
				</div>

				<div className="mt-4">STEP 2.1: Get item price</div>
				<div className="flex items-center">
					<EveButton
						className="mr-2"
						typeClass="tertiary"
						onClick={async (event) => {
							event.preventDefault();
							fetchItemPriceData()
						}}
					>
						Fetch
					</EveButton>
					<span className="text-xs">
						{itemPriceWei ? `${formatEther(BigInt(itemPriceWei))} ether units` : "Click fetch to get item price"}
					</span>
				</div>

				<div className="mt-4">STEP 2.2: Set item price in ether units</div>
				<div className="flex flex-col items-start gap-3">
					<TextEdit
						isMultiline={false}
						defaultValue={`${itemPriceWei} wei`}
						fieldType={"item price"}
						onChange={(str) => handleEdit(itemPriceWeiValueRef, str)}
					></TextEdit>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await setItemPrice(
									smartAssemblyId,
									inventoryItemId,
									parseEther(itemPriceWeiValueRef.current)
								);
								fetchItemPriceData()
							}}
						>
							Set Item Price
						</EveButton>
					</div>
				</div>

				<div className="mt-4">STEP 2.3: Unset item price</div>
				<EveButton
					typeClass="tertiary"
					onClick={async (event) => {
						event.preventDefault();
						console.log(
							"new item price:",
							await unsetItemPrice(smartAssemblyId, inventoryItemId)
						);
					}}
				>
					Unset item price
				</EveButton>
			</div>

			<div className="Quantum-Container my-4">
				<div>STEP 3: Purchase Item</div>
				<div className="flex items-center">
					<EveButton
						className="mr-2"
						typeClass="tertiary"
						onClick={async (event) => {
							event.preventDefault();
							const balance = await getErc20Balance(walletClient.account?.address)
							setErc20Balance(Number(balance ?? 0))
						}}
					>
						Get balance
					</EveButton>
					<span className="text-xs">
						{erc20Balance ? `${formatEther(BigInt(erc20Balance))} ether units` : "Click fetch to get buyer ERC-20 balance"}
					</span>
				</div>
				<div className="flex items-start flex-col gap-3">
					<TextEdit
						isMultiline={false}
						defaultValue={itemQuantity}
						fieldType={"item quantity"}
						onChange={(str) => setItemQuantity(Number(str))}
					></TextEdit>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await purchaseItem(
									smartAssemblyId,
									inventoryItemId,
									itemQuantity								)
							}}
						>
							Purchase items
						</EveButton></div>
				</div>
			</div>
		</>
	);
});

export default ManageItem;
