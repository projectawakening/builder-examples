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
	const [itemPriceData, setItemPriceData] = useState<number | undefined>();
	const [inventoryItemId, setInventoryItemId] = useState<number | undefined>();
	const [itemQuantity, setItemQuantity] = useState<number | undefined>();

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
				<TextEdit
					isMultiline={false}
					defaultValue={inventoryItemId}
					fieldType={"inventory item ID - this is not your item typeid"}
					onChange={(str) => setInventoryItemId(Number(str))}
				></TextEdit>

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
							console.log(itemPriceData);
							setItemPriceData(Number(itemPriceData?.price));
						}}
						disabled={inventoryItemId == undefined}
					>
						Fetch
					</EveButton>
					<span className="text-xs">
						{itemPriceData ?? "No item price set"}
					</span>
				</div>

				<div className="mt-4">STEP 2.2: Set item price</div>
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
								console.log(
									"new item price:",
									await setItemPrice(
										smartAssemblyId,
										inventoryItemId,
										Number(itemPriceWeiValueRef.current)
									)
								);
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
