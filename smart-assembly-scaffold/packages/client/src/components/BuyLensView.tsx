/* eslint-disable @typescript-eslint/no-unused-vars */
import { FormControlLabel, RadioGroup } from "@mui/material";
import { useEffect, useState } from "react";
import { formatEther } from "viem";

import { useNotification } from "@eveworld/contexts";
import { Severity, SmartAssemblyType } from "@eveworld/types";
import { abbreviateAddress } from "@eveworld/utils";

import BoxWithCorners from "./BoxWithCorners";
import LensImage from "../assets/lens-image.webp";
import { useRecord } from "../mud/useRecord";

import { stash } from "../mud/stash";
import mudConfig from "contracts/mud.config";
import { useWorldContract } from "../mud/useWorldContract";
import { purchaseItems } from "./systemCalls/purchaseItems";

export default function BuyLensView({
	smartAssembly,
}: {
	smartAssembly: SmartAssemblyType<"SmartStorageUnit">;
}) {
	const [quantity, setQuantity] = useState<number>(0);
	const [pricePerLens, setPricePerLens] = useState<number>(25);

	const [priceList, setPriceList] = useState<
		Record<number, bigint> | undefined
	>(undefined);
	const [purchaseAmount, setPurchaseAmount] = useState<number>(0);

	const { notify } = useNotification();
	const { worldContract, erc20Contract } = useWorldContract();

	const lensPurchasePrice = useRecord({
		stash,
		table: mudConfig.namespaces.example.tables.ToggleTable,
		key: {
			smartObjectId: BigInt(smartAssembly.id)
		},
	});

	useEffect(() => {
		// Get configured EVE price per lens
		const getLensPrice = async () => {
			setPricePerLens(
				Number(formatEther(lensPurchasePrice?.price || BigInt(0)))
			);
		};

		getLensPrice();
	}, [lensPurchasePrice]);

	useEffect(() => {
		// When user sets new quantity,
		// Update total price
		if (priceList) {
			const purchaseAmountFromPriceList = Number(
				formatEther(priceList[quantity], "wei")
			);
			setPurchaseAmount(purchaseAmountFromPriceList ?? 0);
		} else {
			setPurchaseAmount(quantity * pricePerLens);
		}
	}, [priceList, pricePerLens, quantity]);

	const renderDiscountForQty = (quantity: number) => {
		if (!priceList) return;
		const price = formatEther(priceList[quantity]);
		if (!price) return;

		// Discounts calculated against 1:5 ratio.
		const pricePerItem = Number(price) / (quantity * 5);
		const discount = 100 - pricePerItem * 100;

		if (discount === 0) return;
		return (
			<div className="text-right text-grayneutral text-sm font-semibold uppercase tracking-wide">
				{discount.toFixed(0)}% off
			</div>
		);
	};

	if (!pricePerLens)
		notify({ type: Severity.Warning, message: "Lens price not set" });

	return (
		<div className="grid grid-cols-12 gap-4 mobile:grid-cols-1 mobile:col-span-1 mx-7">
			<section className="col-span-6 mobile:row-start-2 flex-col justify-start items-start gap-2 inline-flex">
				<div className="text-grayneutral text-lg font-semibold leading-snug mt-[4.5rem] mobile:mt-10">
					{smartAssembly?.name
						? smartAssembly?.name
						: abbreviateAddress(smartAssembly?.id, 7)}
				</div>
				<div className="text-5xl font-semibold mobile:whitespace-nowrap">
					Lens
				</div>
				<div className="empty" />
				<div className="text-grayneutral text-lg leading-snug">
					Exclusive to the Venture, the extractor Lens is distributed under
					restricted licensing conditions due to the ever-evolving landscape of
					Crude Matter extraction regulations. Provided by Allegrite.
				</div>
				<div className="text-lg font-semibold leading-snug">
					For use with Crude Extractors only. One Lens lasts 3 extraction
					cycles.
				</div>
				<div className="h-10 empty" />

				<section className="w-full pr-6 flex-col justify-start items-start gap-14 inline-flex">
					<BoxWithCorners style="pb-6">
						<div className="self-stretch flex-col justify-start items-start flex">
							<RadioGroup
								className="grid grid-cols-3 tabletsm:grid-cols-2 w-full justify-start items-start"
								aria-labelledby="lens-radio-buttons-group"
								name="lens-radio-buttons-group"
								id="lens-radio-buttons-group"
								value={quantity}
							>
								{/* If Pricelist has been configured, use pricelist values. If not, pick in increments of 1 */}
								{(priceList
									? Object.keys(priceList)
									: Array.from(Array(6), (e, i) => i + 1)
								).map((value, index) => (
									<FormControlLabel
										key={index}
										value={value}
										onClick={() => {
											if (quantity === +value) {
												setQuantity(0);
											} else {
												setQuantity(+value);
											}
										}}
										control={
											<div
												className={`select ${quantity === +value && "active"}`}
											>
												<div className="justify-end items-center gap-1 inline-flex text-2xl leading-[28.80px]">
													<span className="font-semibold">{value}</span>
													lens{+value > 1 && "es"}
												</div>
												{renderDiscountForQty(+value)}
											</div>
										}
										label=""
									/>
								))}
							</RadioGroup>
						</div>

						<div className="self-stretch px-6 justify-between items-start inline-flex tabletsm:flex-col tabletsm:gap-4">
							<div className="flex-col justify-start items-start gap-1 flex">
								<div className="text-grayneutral text-sm font-semibold uppercase tracking-wide">
									Total
								</div>
								<div className="justify-start items-center gap-1.5 inline-flex text-[32px] leading-[38.40px]">
									- <span className="font-semibold">{purchaseAmount}</span> EVE
								</div>
							</div>
							<div className="relative justify-start items-center flex tabletsm:w-full">
								<button
									onClick={async () => {
										const txHash = await purchaseItems({
											itemPrice: lensPurchasePrice,
											quantity,
											worldContract,
											erc20Contract,
										});
										notify({
											type: txHash ? Severity.Success : Severity.Error,
											txHash,
										});
									}}
									className="primary w-full col-span-2"
									disabled={quantity === 0}
								>
									Buy lenses
								</button>
							</div>
						</div>
					</BoxWithCorners>
				</section>
			</section>
			<div className="col-start-7 col-span-6 mobile:row-start-1 mobile:col-span-1 mobile:col-start-1">
				<img src={LensImage} className="w-full" />
			</div>
		</div>
	);
}
