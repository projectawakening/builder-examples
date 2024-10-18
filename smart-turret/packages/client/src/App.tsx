//Import packages
import { useMUD } from "./MUDContext";
import React, { useEffect, useState, useRef } from "react";

//Import EVE Frontier Packages
import { EveButton, EveInput, EveScroll } from "@eveworld/ui-components";

//Import CSS
import "./styles.css";
import "./styles-ui.css";

//Import components
import WhitelistEntry from './components/WhitelistEntry'
import AppContainer from './components/AppContainer'
import Title from './components/Title'
import ContentContainer from './components/ContentContainer'
import Section from './components/Section'

import ToggleButton from '@mui/material/ToggleButton';
import ToggleButtonGroup from '@mui/material/ToggleButtonGroup';

export const App = () => {
	const {
		systemCalls: {
			getWhitelist,
			addToWhitelist,
			removeFromWhitelist
		},
	} = useMUD();

	//Character name input value
	const characterNameInputRef = useRef(0);

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

	//Initial load
	useEffect(() => {
		setTimeout(function(){
			fetchWhitelist(null);
		}, 1000)
	}, [])

	//Remove from the whitelist
	const remove = async (id) => {
		const whitelist = await removeFromWhitelist(id);
		loadWhitelist(whitelist);
	}

	//Fetch the whitelist data
	async function fetchWhitelist(event){
		if(event) event.preventDefault();		
		const whitelist = await getWhitelist();
		loadWhitelist(whitelist);
	}	

	//Load the whitelist UI
	async function loadWhitelist(result){
		if(result == null) return;
		
		var newArray = result.whitelist.map((value) => <WhitelistEntry key={value.toString()} id={value.toString()} handleClick={remove}>{value}</WhitelistEntry>)
		setWhitelist(newArray);
	}

	//Add to the whitelist
	async function addToWhitelistButton (){
		//Check there is a name
		if(characterNameInputRef.current == ""){			
			setAddErrorVar("- NO INPUT");
			return;
		}

		//Fetch the world API data
		const response = await fetch(`https://blockchain-gateway-nova.nursery.reitnorf.com/smartcharacters`);
		const data = await response.json();			

		var address = null;

		//Check to see if the address exists
		for(var i = 0; i < data.length; i++){
			if(data[i].name == characterNameInputRef.current){
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

	return (
		<AppContainer>
			<Title>
				SMART TURRET WHITELISTING
			</Title>
			<ContentContainer>
				<Section>		
				<ToggleButtonGroup
					value={"TEST"}
					exclusive
					onChange={() => {}}
					>
					<ToggleButton className="Eve-Button primary" value="list" aria-label="list">
						Name
					</ToggleButton>
					<ToggleButton className="Eve-Button primary" value="module" aria-label="module">
						ID
					</ToggleButton>
					<ToggleButton className="Eve-Button primary" value="quilt" aria-label="quilt">
						Address
					</ToggleButton>
				</ToggleButtonGroup>		
					<div className="grid grid-cols-1 rows-2 gap-1">
						<EveInput
							inputType="string"
							defaultValue=""
							fieldName={`Character Name ${addErrorVar}`}
							onChange={(str) => handleEdit(characterNameInputRef, str as number)}
						/>
						<EveButton 
							typeClass="primary"
							onClick={addToWhitelistButton}
							className="primary-sm">
								Add to Whitelist					
						</EveButton>						
					</div>
				</Section>
				<Section>			
					<EveButton 
						typeClass="primary"
						onClick={(event) => fetchWhitelist(event)}
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