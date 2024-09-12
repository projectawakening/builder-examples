import { useMUD } from "../MUDContext";
import React, { useRef, useState } from "react";
import { EveButton, TextEdit } from "@eveworld/ui-components";

const ManageItem = React.memo(function ManageItem({
	smartAssemblyId,
}: {
	smartAssemblyId: bigint;
}) {
	const [itemPriceWei, setItemPriceWei] = useState<number | undefined>();
	const [itemQuantity, setItemQuantity] = useState<number | undefined>();

	const inventoryItemId = import.meta.env.VITE_INVENTORY_ITEM_ID

	const {
		systemCalls: {
			setItemPrice,
			unsetItemPrice,
			getItemPriceData,
			purchaseItem,
		},
	} = useMUD();

	const fetchItemPriceData = async () => {
		const itemPriceData = await getItemPriceData(
			smartAssemblyId,
			inventoryItemId
		);
		setItemPriceWei(Number(itemPriceData?.price))
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
						{itemPriceWei ? `${itemPriceWei?.toString()} wei` : "Click fetch to get item price"}
					</span>
				</div>

				<div className="mt-4">STEP 2.2: Set item price in wei</div>
				<div className="flex items-center gap-3">
					<TextEdit
						isMultiline={false}
						defaultValue={itemPriceWei?.toString()}
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
									Number(itemPriceWeiValueRef.current)
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
				<div></div>
				<div className="flex items-center gap-3">
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
						</EveButton>
					</div>
				</div>
			</div>
		</>
	);
});

export default ManageItem;
