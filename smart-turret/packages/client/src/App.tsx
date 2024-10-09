import { useMUD } from "./MUDContext";
import React, { useEffect, useState, useRef } from "react";
import { EveButton, EveInput, Header } from "@eveworld/ui-components";
import { abbreviateAddress } from "@eveworld/utils";
import { SmartCharacter } from "@eveworld/types";
import "./styles.css";
import "./styles-ui.css";

import WhitelistEntry from './components/WhitelistEntry'

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
			getWhitelist,
			addToWhitelist,
		},
	} = useMUD();

	const characterIDRef = useRef(0);
	
	const handleEdit = (
		refString: React.MutableRefObject<number>,
		eventString: number
	): void => {
		refString.current = eventString;
	};

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

	return (
		<div id="root">
		<div className="bg-crude-5 w-screen min-h-screen">
			<div className="flex flex-col align-center max-w-[560px] mx-auto pb-6 min-h-screen h-full">
				<div className="Quantum-Container my-4">
				<header className="w-full items-center py-6 Custom-Title" id="header">
					SMART TURRET WHITELISTING
				</header>
				</div>
				<div className="relative">
				<div className="grid border border-brightquantum bg-crude">
				<div className="flex flex-col align-center border border-brightquantum">
				<div className="Quantum-Container font-semibold ">				
					<div className="grid grid-cols-1 rows-2 gap-1">
						<EveInput
							inputType="string"
							defaultValue=""
							fieldName={"Character ID"}
							onChange={(str) => handleEdit(characterIDRef, str as number)}
						/>
						<div></div>
						<EveButton typeClass="primary"
						onClick={async (event) => {
							event.preventDefault();
							
							const balance = await addToWhitelist(
								characterIDRef.current
							);
							
							console.log("BALANCE: " + characterIDRef.current);``
						}}
						className="primary-sm">
							Add to Whitelist					
						</EveButton>
						
					</div>
				</div>
				<div className="Quantum-Container font-semibold">				
					<div>
						<EveButton typeClass="primary"
						onClick={async (event) => {
							event.preventDefault();
							const balance = await getWhitelist(
								"42286255167959065515159482724089294794766243679345523240407516329986919866605"
							);
							console.log("BALANCE: " + balance);
						}}
						className="primary-sm">
							Fetch Whitelist						
						</EveButton>
					</div>
				</div>
				
				<div className="Quantum-Container font-semibold">				
				<div className="w-full items-center py-1" id="header">
					Whitelist
				
				</div>
				<WhitelistEntry id="100"></WhitelistEntry>
				<WhitelistEntry id="200"></WhitelistEntry>
				<WhitelistEntry id="350"></WhitelistEntry>
				</div>

				

				
				</div>
				</div>
				</div>
			</div>
		</div>
    </div>
	);
};
