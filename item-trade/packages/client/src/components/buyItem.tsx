import { useMUD } from "../MUDContext";
import React, { useRef, useState } from "react";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { formatEther, parseEther } from "viem";

const BuyItem = React.memo(function BuyItem({
	smartAssemblyId,
	itemOutId
}: {
	smartAssemblyId: bigint;
	itemOutId: string
}) {
	const [itemPriceWei, setItemPriceWei] = useState<number | undefined>();
	const [itemQuantity, setItemQuantity] = useState<number | undefined>();
	const [erc20Balance, setErc20Balance] = useState<number | undefined>();

	const {
		network: { walletClient },
		systemCalls: {
			setItemPrice,
			getItemPriceData,
			purchaseItem,
			getErc20Balance
		},
	} = useMUD();

	const fetchItemPriceData = async () => {
		const itemPriceData = await getItemPriceData();
		setItemPriceWei(Number(itemPriceData?.price ?? 0))
	}

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
				<div>STEP 2: User buys inventory item ID: {itemOutId}</div>
				<div className="text-xs">
				You can change this inventory item ID in the .env file
				</div>

				<div className="mt-4">STEP 2.1: Get item buy price</div>
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
						{itemPriceWei ? `${formatEther(BigInt(itemPriceWei))} ether units` : "No item price set"}
					</span>
				</div>

				<div className="mt-4">STEP 2.2: Set item price in ether units</div>
				<div className="flex flex-col items-start gap-3">
					<EveInput
						inputType="numerical"
						defaultValue={undefined}
						fieldName={"Item price"}
						onChange={(str) => handleEdit(itemPriceWeiValueRef, str as number)}
					></EveInput>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await setItemPrice(
									smartAssemblyId,
									parseEther(itemPriceWeiValueRef.current.toString())
								);
								fetchItemPriceData()
							}}
						>
							Set Item Price
						</EveButton>
					</div>
				</div>
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
					<EveInput
						inputType="numerical"
						defaultValue={itemQuantity}
						fieldName={"item quantity"}
						onChange={(str) => setItemQuantity(Number(str))}
					></EveInput>
					<div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								await purchaseItem(
									smartAssemblyId,
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

export default BuyItem;
