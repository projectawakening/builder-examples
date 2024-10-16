//Import packages
import { useMUD } from "./MUDContext";
import React, { useEffect, useState, useContext, useRef } from "react";

//Import EVE Frontier Packages
import { EveButton, EveInput, EveScroll } from "@eveworld/ui-components";
import { Actions, Severity, State } from "@eveworld/types";
import IWorldAbi from "../../contracts/out/IWorld.sol/IWorld.abi.json";

import { TurretWhitelistContext } from "./components/TurretContext";
import {
	AbiItem,
	BaseError,
	ContractFunctionRevertedError,
	encodeFunctionData,
	getAbiItem,
  } from "viem";

//Import CSS
import "./styles.css";
import "./styles-ui.css";

//Import components
import WhitelistEntry from './components/WhitelistEntry'
import AppContainer from './components/AppContainer'
import Title from './components/Title'
import ContentContainer from './components/ContentContainer'
import Section from './components/Section'

import { SYSTEM_IDS, getDappUrl, getSystemId, isOwner } from "@eveworld/utils";


import {
	useNotification,
	useConnection,
	useWorld,
	useSmartObject,
  } from "@eveworld/contexts";
  import {
	EveConnectWallet,
	EveFeralCodeGen,
	ErrorNotice,
	ErrorNoticeTypes,
	EveLayout,
	EveAlert,
  } from "@eveworld/ui-components";

export const App = () => {
	const {
		systemCalls: {
			getWhitelist,
			addToWhitelist,
			removeFromWhitelist
		},
	} = useMUD();

	
	const {
		connectedProvider,
		publicClient,
		walletClient,
		isCurrentChain,
		handleConnect,
		handleDisconnect,
		availableWallets,
		defaultNetwork,
	  } = useConnection();

	const characterIDRef = useRef(0);
    const { smartAssembly } = useSmartObject();
	const { handleSendTx, notify } = useNotification();

	console.log("ASSEMBLY:", smartAssembly);

	//Pre-populate the UI list 
	const [whitelist, setWhitelist] = useState(<WhitelistEntry id={"LOADING...."}></WhitelistEntry>);
	const [addErrorVar, setAddErrorVar] = useState("");

	//Edit character name
	const handleEdit = (
		refString: React.MutableRefObject<number>,
		eventString: number
	): void => {
		refString.current = eventString;
	};

	//Auto reload whitelist
	useEffect(() => {
		//fetchWhitelist();
	});

	//Remove from the whitelist
	const remove = async (id) => {
		const whitelist = await removeFromWhitelist(id);

		loadWhitelist(whitelist);
	}

	//Fetch the whitelist data
	async function fetchWhitelist(){		
		console.log("FETCHING");
		const whitelist = await getWhitelist();
		loadWhitelist(whitelist);
	}	

	//Load the whitelist UI
	async function loadWhitelist(result){
		if(result == null) return;
		
		var newArray = result.whitelist.map((value) => <WhitelistEntry id={value.toString()} handleClick={remove}>{value}</WhitelistEntry>)
		setWhitelist(newArray);
	}

	const {TurretWhitelistContract} = useContext(TurretWhitelistContext)		

	async function addToWhitelistButton3 (){
		if (!world || !smartAssembly || !walletClient?.account || !publicClient)
			return;

			const systemId = getSystemId(
			defaultNetwork.systemIds,
			SYSTEM_IDS.UPDATE_METADATA,
			);
			if (!systemId) return;

		//Fetch the world API data
		const response = await fetch(`https://blockchain-gateway-nova.nursery.reitnorf.com/smartcharacters`);
		const data = await response.json();			

		var address = null;

		//Check to see if the address exists
		for(var i = 0; i < data.length; i++){
			if(data[i].name == characterIDRef.current){
				address = data[i].address;
			}
		}

		//If an address wasn't found, exit
		if(address == null){
			setAddErrorVar("- CHARACTER NOT FOUND");
			return;
		}

		try {
		const setMetadataAbiItem: AbiItem | undefined = getAbiItem({
			abi: IWorldAbi,
			name: "dapp_dev2__addToWhitelist",
		});

		const callData = encodeFunctionData({
			abi: [setMetadataAbiItem],
			functionName: "dapp_dev2__addToWhitelist",
			args: [
			smartAssembly.id,
			address
			],
		});

		console.log("SYSTEM: ", defaultNetwork);
		console.log("SYSTEM_ID: ", systemId);

		handleSendTx({
			encodedFunctionData: callData,
			systemId,
			onClose: () => {},
		});
		} catch (e) {
		notify({
			type: Severity.Error,
			message: "Transaction failed to execute",
		});
		console.error(e);
		}
	}

	async function addToWhitelistButton2 (){
		if (!world || !smartAssembly || !walletClient?.account || !publicClient)
			return;
	
		//Fetch the world API data
		const response = await fetch(`https://blockchain-gateway-nova.nursery.reitnorf.com/smartcharacters`);
		const data = await response.json();			

		var address = null;

		//Check to see if the address exists
		for(var i = 0; i < data.length; i++){
			if(data[i].name == characterIDRef.current){
				address = data[i].address;
			}
		}

		//If an address wasn't found, exit
		if(address == null){
			setAddErrorVar("- CHARACTER NOT FOUND");
			return;
		}

		try {	
		const systemId = getSystemId(
			defaultNetwork.systemIds,
			SYSTEM_IDS.LINK_GATE,
		);
		if (!systemId) return;

		const setMetadataAbiItem: AbiItem | undefined = getAbiItem({
			abi: IWorldAbi,
			name: "dapp_dev2__addToWhitelist",
		});

		console.log("ABI2", setMetadataAbiItem);

		const callData = encodeFunctionData({
			abi: [setMetadataAbiItem],
			functionName: "dapp_dev2__addToWhitelist",
			args: [
			BigInt(smartAssembly.id),
			address
			],
		});

		console.log("SYSTEM: ", defaultNetwork);
		console.log("SYSTEM_ID: ", systemId);
		console.log("CALL DATA: ", callData);

		handleSendTx({
			encodedFunctionData: callData,
			systemId,
			onClose: () => {},
		});
		} catch (e) {
		notify({
			type: Severity.Error,
			message: "Transaction failed to execute",
		});
		console.error(e);
		}
	}

	//Add to the whitelist
	async function addToWhitelistButton (){
		if(characterIDRef.current == ""){			
			setAddErrorVar("- NO INPUT");
			return;
		}

		//Fetch the world API data
		const response = await fetch(`https://blockchain-gateway-nova.nursery.reitnorf.com/smartcharacters`);
		const data = await response.json();			

		var address = null;

		//Check to see if the address exists
		for(var i = 0; i < data.length; i++){
			if(data[i].name == characterIDRef.current){
				address = data[i].address;
			}
		}

		//If an address wasn't found, exit
		if(address == null){
			setAddErrorVar("- CHARACTER NOT FOUND");
			return;
		}

		//Clear the error message
		setAddErrorVar("");

		//Add to whitelist
		const whitelist = await addToWhitelist(address);

		//Load whitelist if not null
		if(whitelist != null) loadWhitelist(whitelist);
	}

	const { connected } = connectedProvider;
    const { world } = useWorld();

	console.log("Connected", connected);
	console.log("Public Client", publicClient);
	console.log("Wallet Client", walletClient);
	console.log("World", world);

	if (!connected || !publicClient || !walletClient) {
		return (
		<div className="h-full w-full bg-crude-5 -z-10">
			<EveConnectWallet
			handleConnect={handleConnect}
			availableWallets={availableWallets}
			/>
			<GenerateEveFeralCodeGen style="top-12" />
			<GenerateEveFeralCodeGen style="bottom-12" />
		</div>
		);
	}

	return (
		<AppContainer>
			<Title>
				SMART TURRET WHITELISTING
			</Title>
			<ContentContainer>
				<Section>				
					<div className="grid grid-cols-1 rows-2 gap-1">
						<EveInput
							inputType="string"
							defaultValue=""
							fieldName={`Character Name ${addErrorVar}`}
							onChange={(str) => handleEdit(characterIDRef, str as number)}
						/>
						<EveButton 
							typeClass="primary"
							onClick={addToWhitelistButton2}
							className="primary-sm">
								Add to Whitelist					
						</EveButton>						
					</div>
				</Section>
				<Section>			
					<EveButton 
						typeClass="primary"
						onClick={fetchWhitelist}
						className="primary-sm">
						Fetch Whitelist						
					</EveButton>
				</Section>				
				<Section>				
					<div className="w-full items-center py-1">
						Whitelist				
					</div>

					<EveScroll
						maxHeight="200px"
						classStyles="h-full"
					>					
						{whitelist}
					</EveScroll>
				</Section>		
			</ContentContainer>
		</AppContainer>
	);
};

const GenerateEveFeralCodeGen = ({
	style,
	count = 5,
  }: {
	style?: string;
	count?: number;
  }) => {
	const codes = Array.from({ length: count }, (_, i) => i);
	return (
	  <div
		className={`absolute flex justify-between px-10 justify-items-center w-full text-xs ${style}`}
	  >
		{codes.map((index) => (
		  <EveFeralCodeGen key={index} />
		))}{" "}
	  </div>
	);
  };
  