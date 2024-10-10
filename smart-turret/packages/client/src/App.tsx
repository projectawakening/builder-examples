import { useMUD } from "./MUDContext";
import React, { useEffect, useState, useRef } from "react";
import { EveButton, EveInput, Header } from "@eveworld/ui-components";
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

		setInterval(function(){
			fetchWhitelist();
		}, 1000);
	}, [walletClient.account?.address]);

	var arrayData = <WhitelistEntry id="LOADING...."></WhitelistEntry>;

	const remove = async (id) => {
		console.log("Removing: " + id);

		const whitelist = await removeFromWhitelist(
			id
		);

		loadWhitelist(whitelist);
	}

	async function fetchWhitelist(){		
		const whitelist = await getWhitelist();
		loadWhitelist(whitelist);
	}	

	async function loadWhitelist(result){
		arrayData = result.whitelist.map((value) => <WhitelistEntry id={value.toString()} handleClick={remove}>{value}</WhitelistEntry>)
		handleListChange(arrayData);
	}

	return (
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
								
								const whitelist = await addToWhitelist(
									characterIDRef.current
								);

								console.log("DATA", whitelist);

								loadWhitelist(whitelist);
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
								fetchWhitelist();
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
	);
};
