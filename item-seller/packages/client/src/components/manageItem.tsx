import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "../MUDContext";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import React, { useRef, useState } from "react";
import { EveButton, TextEdit } from "@eveworld/ui-components";

const ManageItem = React.memo(function ManageItem({
	smartAssemblyId,
}: {
	smartAssemblyId: bigint;
}) {
	const [render, setRender] = useState(false); // State to trigger a re-render
	const [itemQuantity, setItemQuantity] = useState<number | undefined>();

	const inventoryItemId = import.meta.env.VITE_INVENTORY_ITEM_ID

	const {
		components: { ItemPrice },
		systemCalls: {
			setItemPrice,
			unsetItemPrice,
			getItemPriceData,
			purchaseItem,
		},
	} = useMUD();

	const itemPriceWei = useComponentValue(ItemPrice, singletonEntity);
	const itemPriceWeiValueRef = useRef((itemPriceWei?.price.toString()) ?? "");

	const handleEdit = (
		refString: React.MutableRefObject<string>,
		eventString: string
	): void => {
		refString.current = eventString;
	};

	return (
		<>
			<div className="Quantum-Container my-4">
				<div>STEP 2: Manage inventory item</div>
				<div className="text-sm">
				Managing for item inventory item ID: {inventoryItemId}
				</div>
				<div className="text-sm">
				You can change this inventory item ID in the .env file
				</div>

				<div className="mt-4">STEP 2.1: Get item price</div>
				<div className="flex items-center">
					<EveButton
						className="mr-2"
						typeClass="tertiary"
						onClick={async (event) => {
							event.preventDefault();
							const itemPriceData = await getItemPriceData(
								smartAssemblyId,
								inventoryItemId
							);
							if (itemPriceData) {
								itemPriceWeiValueRef.current = itemPriceData.price.toString()
								setRender((prev) => !prev);	
							}
						}}
					>
						Fetch
					</EveButton>
					<span className="text-xs">
						{ itemPriceWeiValueRef.current ? itemPriceWeiValueRef.current : "No item price set"}
					</span>
				</div>

				<div className="mt-4">STEP 2.2: Set item price in wei</div>
				<div className="flex items-center gap-3">
					<TextEdit
						isMultiline={false}
						defaultValue={itemPriceWei?.price.toString()}
						fieldType={"item price"}
						onChange={(str) => handleEdit(itemPriceWeiValueRef, str)}
					></TextEdit>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();

								const itemPriceData = await setItemPrice(
									smartAssemblyId,
									inventoryItemId,
									Number(itemPriceWeiValueRef.current)
								);
								if (itemPriceData) {
									itemPriceWeiValueRef.current = itemPriceData.price.toString()
									setRender((prev) => !prev);	
								}
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
								console.log(
									"items purchased:",
									await purchaseItem(
										smartAssemblyId,
										inventoryItemId,
										itemQuantity
									)
								);
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
