import { useMUD } from "../MUDContext";
import React, { useRef, useState } from "react";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { formatEther, parseEther } from "viem";

const SellItem = React.memo(function SellItem({
	smartAssemblyId,
	itemInId
}: {
	smartAssemblyId: bigint;
	itemInId: string;
}) {
	const [itemStackMultiple, setItemStackMultiple] = useState<
		number | undefined
	>();
	const [itemPriceWei, setItemPriceWei] = useState<number | undefined>();
	const [sellQuantity, setSellQuantity] = useState<number | undefined>();

	const {
		systemCalls: { setSellConfig, sellItem, getItemSellData },
	} = useMUD();

	const fetchItemSellData = async () => {
		const sellPriceData = await getItemSellData();
		setItemStackMultiple(Number(sellPriceData?.enforcedItemMultiple ?? 0));
		setItemPriceWei(Number(sellPriceData?.tokenAmount ?? 0));
	};

	const itemMultipleValueRef = useRef(0);
	const itemPriceWeiValueRef = useRef(0);

	const handleEdit = (
		refString: React.MutableRefObject<number>,
		eventString: number
	): void => {
		refString.current = eventString;
	};

	return (
		<>
			<div className="Quantum-Container my-4">
				<div>STEP 4: Player sells inventory item ID: {itemInId}</div>
				<div className="text-xs">
					You can change this inventory item ID in the .env file
				</div>

				<div className="mt-4">
					STEP 4.1: Get item sell price and config data
				</div>
				<div className="flex items-center">
					<EveButton
						className="mr-2"
						typeClass="tertiary"
						onClick={async (event) => {
							event.preventDefault();
							fetchItemSellData();
						}}
					>
						Fetch
					</EveButton>
					<div className="flex flex-col">
						<span className="text-xs">
							{itemPriceWei && itemStackMultiple
								? `Every ${itemStackMultiple} units of item ${itemInId} can be sold for ${formatEther(BigInt(itemPriceWei))} EVE`
								: "No sell config set"}
						</span>
					</div>
				</div>

				<div className="mt-4">STEP 4.2: Set item price in ether units</div>
				<div className="text-xs">
				For this step, you must be connected as the <b>smart assembly owner</b>.
				</div>
				<div className="flex flex-col items-start gap-3">
					<EveInput
						inputType="numerical"
						defaultValue={undefined}
						fieldName={"Item multiple"}
						onChange={(str) => handleEdit(itemMultipleValueRef, str as number)}
					></EveInput>

					<EveInput
						inputType="numerical"
						defaultValue={undefined}
						fieldName={"Stack price"}
						onChange={(str) => handleEdit(itemPriceWeiValueRef, str as number)}
					></EveInput>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await setSellConfig(
									smartAssemblyId,
									itemMultipleValueRef.current,
									parseEther(itemPriceWeiValueRef.current.toString())
								);
								fetchItemSellData();
							}}
						>
							Set Item Price
						</EveButton>
					</div>
				</div>
			</div>

˛			<div className="Quantum-Container my-4">
			<div className="text-xs">
				For this step, you must be connected as the <b>player</b>.
				</div>
				<div>STEP 5: Sell Item</div>
				<div className="flex items-start flex-col gap-3">
					<EveInput
						inputType="numerical"
						defaultValue={sellQuantity}
						fieldName={"item quantity"}
						onChange={(str) => setSellQuantity(Number(str))}
					></EveInput>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await sellItem(smartAssemblyId, sellQuantity);
							}}
						>
							Sell items
						</EveButton>
					</div>
				</div>
			</div>
		</>
	);
});

export default SellItem;
