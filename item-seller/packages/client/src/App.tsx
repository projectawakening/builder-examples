import { useMUD } from "./MUDContext";
import ManageErc20Token from "./components/manageErc20Token"
import ManageItem from "./components/manageItem"
import React, { useEffect, useState } from "react";
import { EveButton, Header } from "@eveworld/ui-components";
import { abbreviateAddress } from "@eveworld/utils";
import { SmartCharacter } from "@eveworld/types";
import "./styles.css";

export const App = () => {
	const [smartCharacter, setSmartCharacter] = useState<SmartCharacter>({
		address: `0x`,
		id: "",
		name: "",
		isSmartCharacter: false,
		eveBalanceWei: 0,
		gasBalanceWei: 0,
		image: "",
		smartDeployables: [],
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
			smartDeployables: [],
		};
		setSmartCharacter(smartCharacter);
	}, [walletClient.account?.address]);

	const smartAssemblyId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);

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

					<ManageItem smartAssemblyId={smartAssemblyId} />

					<div className="Quantum-Container my-4">
						<div>STEP 4: Collect Tokens</div>
						<EveButton
							typeClass="primary"
							onClick={async (event) => {
								event.preventDefault();
								console.log(
									"tokens collected:",
									await collectTokens(smartAssemblyId)
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
