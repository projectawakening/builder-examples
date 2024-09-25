import { useMUD } from "./MUDContext";
import ManageErc20Token from "./components/manageErc20Token"
import React, { useEffect, useState } from "react";
import { EveButton, Header } from "@eveworld/ui-components";
import { abbreviateAddress } from "@eveworld/utils";
import { SmartCharacter } from "@eveworld/types";
import "./styles.css";
import BuyItem from "./components/buyItem"
import SellItem from "./components/sellItem";

export const App = () => {
	const [smartCharacter, setSmartCharacter] = useState<SmartCharacter>({
		address: `0x`,
		id: "",
		name: "",
		isSmartCharacter: false,
		eveBalanceWei: 0,
		gasBalanceWei: 0,
		image: "",
		smartAssemblies: []
	});

	const {
		network: { walletClient },
		systemCalls: {
			collectTokens,
		},
	} = useMUD();

	/**
	 * Initializes a SmartCharacter object with default values and sets it using the useState hook.
	 * @returns void
	 */
	useEffect(() => {
		const smartCharacter: SmartCharacter = {
			address: walletClient.account?.address as `0x${string}`,
			id: "",
			name: "",
			isSmartCharacter: false,
			eveBalanceWei: 0,
			gasBalanceWei: 0,
			image: "",
			smartAssemblies: [],
		};
		setSmartCharacter(smartCharacter);
	}, [walletClient.account?.address]);

	const smartAssemblyId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);
	const itemOutId = import.meta.env.VITE_ITEM_OUT_ID;
	const itemInId = import.meta.env.VITE_ITEM_IN_ID;

	return (
		<div className="bg-crude-5 w-screen min-h-screen">
			<div className="flex flex-col align-center max-w-[560px] mx-auto pb-6 min-h-screen h-full">
				<Header
					connected={walletClient ? true : false}
					// eslint-disable-next-line @typescript-eslint/no-empty-function
					handleDisconnect={() => {}}
					walletClient={walletClient}
					smartCharacter={smartCharacter}
				/>

				<div className="grid">
					<div className="text-xl font-bold">
						Configuring information for{" "}
						{abbreviateAddress(smartAssemblyId.toString())}
					</div>

					<ManageErc20Token smartAssemblyId={smartAssemblyId} />

					<BuyItem smartAssemblyId={smartAssemblyId} itemOutId={itemOutId} />

					<SellItem smartAssemblyId={smartAssemblyId} itemInId={itemInId} />

					<div className="Quantum-Container my-4">
						<div>STEP 4: Collect Tokens</div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								console.log(
									"tokens collected:",
									await collectTokens(smartAssemblyId, walletClient?.account?.address)
								);
							}}
						>
							Collect Tokens
						</EveButton>
					</div>
				</div>
			</div>
		</div>
	);
};
