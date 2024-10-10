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
			removeFromWhitelist
		},
	} = useMUD();

	const characterIDRef = useRef(0);

	const [listVar, setListVar] = useState(<WhitelistEntry id={"LOADING...."}></WhitelistEntry>);
	
	const handleEdit = (
		refString: React.MutableRefObject<number>,
		eventString: number
	): void => {
		refString.current = eventString;
	};

	const handleListChange = (newValue) => {
		setListVar(newValue);
	}

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

		setTimeout(function(){
			loadWhitelist();
		}, 1000);
	}, [walletClient.account?.address]);

	/*
	if (!connected || !publicClient || !walletClient) {
		return (
			<>
			<div>
			<div className="h-full w-full bg-crude-5 -z-10">
				<EveConnectWallet
				handleConnect={handleConnect}
				availableWallets={availableWallets}
				/>
				<GenerateEveFeralCodeGen style="top-12" />
				<GenerateEveFeralCodeGen style="bottom-12" />
			</div>
			</div>
		</>
		);
	}
		*/

	var arrayData = <WhitelistEntry id="LOADING...."></WhitelistEntry>;

	const click = () => {
		console.log("CLICK");
	}

	async function loadWhitelist(){
		const result = await getWhitelist(
			"42286255167959065515159482724089294794766243679345523240407516329986919866605"
		);
		for(var i = 0; i < result.whitelist.length; i++){
			console.log(result.whitelist[i]);
		}
		arrayData = result.whitelist.map((value) => <WhitelistEntry id={value.toString()} onclick={click}>{value}</WhitelistEntry>)

		handleListChange(arrayData);
		console.log("ARRAY DATA: ", arrayData);
	}

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
								"42286255167959065515159482724089294794766243679345523240407516329986919866605",
								characterIDRef.current
							);
							
							console.log("BALANCE: " + characterIDRef.current);``

							loadWhitelist();
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
							loadWhitelist();
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
				<div>
				{listVar}
				</div>
				</div>				
				</div>
				</div>
				</div>
			</div>
		</div>
    </div>
	);
};
