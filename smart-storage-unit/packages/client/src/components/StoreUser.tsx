import React, {useState, useEffect, useRef } from "react";
import { EveButton } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";
import { Severity } from "@eveworld/types";
import { useWorldContract } from "../mud/useWorldContract";

import {
  findOwnerByAddress,
} from "@eveworld/utils";

//System Calls
import execute from "./systemCalls/handleExecute";
import calculateOutput from "./systemCalls/handleCalculateOutput";

//Data Types
import SSUConfigData from "./dataTypes";

import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly, useEphemeralInventory } from "../hooks/useSmartAssembly";

//Item Data Interface for displaying
interface ItemMetadata{
  name: string,
  image: string
}

const StoreUser = React.memo(
  ({
    ssuConfig,
    typesCache
  }: {
    ssuConfig: SSUConfigData,
    typesCache: any
  }) => {
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly } = useSmartAssembly();
  const { ephemeralInventories } = useEphemeralInventory();

  const { worldContract } = useWorldContract();
  const { notify } = useNotification();

  const [ canTrade, setCanTrade ] = useState<boolean>(false);
  const [ itemsIn, setItemsIn ] = useState<number>(0);
  const [ calculatedItemsIn, setCalculatedItemsIn ] = useState<number>(0);
  const selectedItemsIn = useRef<number>(15);
  const [ selectedItemsIn2, setSelectedItemsIn2 ] = useState<number>(0);
  const [ selectedItemsIn3, setSelectedItemsIn3 ] = useState<number>(0);
  const [ calculatedItemsOut, setCalculatedItemsOut ] = useState<number>(0);

  const [ itemInMetadata, setItemInMetadata ] = useState<ItemMetadata>("");
  const [ itemOutMetadata, setItemOutMetadata ] = useState<ItemMetadata>("");

  const [ itemInTypeID, setItemInTypeID ] = useState<number>(0);
  const [ itemOutTypeID, setItemOutTypeID ] = useState<number>(0);

  useEffect(() => {
    if(itemsIn != selectedItemsIn) selectedItemsIn.current = itemsIn
  }, [itemsIn])

  useEffect(() => {
    GetTypes();
    
    if(smartCharacter == null || ephemeralInventories == null || ephemeralInventories.length == 0){        
      if(itemsIn != 0) setItemsIn(0);
      return;
    }

    let playerInventory = ephemeralInventories.find((x) =>
      x.ephemeralInvOwner == smartCharacter.address,
    );

    if(playerInventory == null){      
      if(itemsIn != 0) setItemsIn(0);
      return;
    }

    var playerItems = playerInventory.items.filter((item:any) => item.typeID.toString() == ssuConfig.itemIn.toString()); 
        
    if(playerItems.length == 0){
      if(itemsIn != 0) setItemsIn(0);
      return;
    }

    if(itemsIn != Number(playerItems[0].quantity)){      
      setItemsIn(Number(playerItems[0].quantity));
    }
  }, [smartCharacter])

  const FindTypeFromSmartID = async (smartItemID:string) => {
    if(typesCache == null) return;
    for(var key in typesCache){
      if(typesCache[key].smartItemId == smartItemID) return key;
    }

    return ""
  }

  //Get the input and output item type ID's
  async function GetTypes(){ 
    if(typesCache != null){
      setItemInTypeID(await FindTypeFromSmartID(ssuConfig.itemIn.toString()));
      setItemOutTypeID(await FindTypeFromSmartID(ssuConfig.itemOut.toString()));
      
      return;
    }    
  }
  
  //Calculate the output through the smart contract
  const getOutput = async () => {
    const txHash = await calculateOutput({
      worldContract,
      inputAmount: selectedItemsIn.current,
      itemID: ssuConfig.itemIn.toString()
    });
    if (txHash) {
      return txHash;
    } else{
      return null;
    }
  };

  const asyncGetOutput = async () => {
    console.log("GET")
    if(itemsIn == 0 || selectedItemsIn.current == 0) return;

    var results = await getOutput();

    console.log("selectedItemsIn.current type:", selectedItemsIn.current);
    if(results == null) return;

    var calcOut = Number(results[0]);

    var calcIn = selectedItemsIn.current - Number(results[1])

    if(calcOut != calculatedItemsOut) setCalculatedItemsOut(calcOut);
    if(calcIn != calculatedItemsIn) setCalculatedItemsIn(calcIn)

    if(calcOut == 0 && canTrade != false){
      setCanTrade(false);
    } else if (calcOut != 0 && canTrade != true){
      setCanTrade(true);
    }
  }

  //Get the calculated output / items given when changes happen and on a interval
  useEffect(() => {
    if (worldContract != null) {
      asyncGetOutput();
    }
  }, [smartAssembly])

  //Get a image of a item
  const getItemImage = async(id:string) => {
    try{
      const response = await fetch(`https://blockchain-gateway-stillness.live.tech.evefrontier.com/types/${id}`)    
      if(!response.ok) return null;

      const result = await response.json();
      return result.metadata
    } 
    catch(err) {
      return null;
    }
  }

  //Get the item images
  useEffect(() => {
    const fetchImageIn = async (id:string) => {
      var metadata = await getItemImage(id)

      if(metadata != null && metadata.name != ""){
        const info : ItemMetadata = {
          name: metadata.name,
          image: metadata.image
        }

        setItemInMetadata(info);
      }
    }

    const fetchImageOut = async (id:string) => {
      var metadata = await getItemImage(id)

      if(metadata != null && metadata.name != ""){
        const info : ItemMetadata = {
          name: metadata.name,
          image: metadata.image
        }

        setItemOutMetadata(info);
      }
    }

    fetchImageIn(itemInTypeID);
    fetchImageOut(itemOutTypeID);
  }, [itemInTypeID, itemOutTypeID])

  //Trade function
  const handleExecute = async () => {
    try{
      const txHash = await execute({worldContract, 
        currentConfig: ssuConfig, 
        quantity: calculatedItemsIn
      });

      if(txHash){      
        notify({ type: Severity.Info, message: "Successfully Traded Items" });
      } else{        
        notify({ type: Severity.Error, message: "Could Not Trade Items" });
      }
    }    
    catch(err){
      notify({ type: Severity.Error, message: "Could Not Trade Items" });
      throw err;
    }
  }

  //Slider for items in
  const handleSetWantedItemInput = (val:any) => {
    if(Number(val.target.value) != selectedItemsIn2){
      console.log(val.target.value)
      selectedItemsIn.current = Number(val.target.value);
    }
  }
    
  return (
    <>
      <div className="justify-center">   
        <div className="grid grid-cols-3">
          <div className="flex items-center justify-center">
            <img className={"item-image"} src={itemInMetadata != "" ? itemInMetadata.image: "https://mainnet-game-ipfs-gateway.nursery.reitnorf.com/ipfs/QmcQzTvz9Z4koU8pvBJL94HxHtLoPoB9wDnuRE278AdbmA"}></img>
          </div>
          <div></div>
          <div className="flex items-center justify-center">
            <img className={"item-image"} src={itemOutMetadata != "" ? itemOutMetadata.image: "https://mainnet-game-ipfs-gateway.nursery.reitnorf.com/ipfs/QmcQzTvz9Z4koU8pvBJL94HxHtLoPoB9wDnuRE278AdbmA"}></img>
          </div>
        </div>

        <br />
        
        <div className="grid grid-cols-3">
          <div className="item-name-container">
            <div className="flex items-center justify-center">
              {itemInMetadata.name}
            </div>
          </div>
          
          <div className="flex items-center justify-center">
            <svg width="44" height="44" viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg">
              <g clipPath="url(#clip0_1_7)">
                <path className={"item-arrow-2"} d="M26.6941 34.9447L39.6387 22.0002L26.6941 9.05566L22.805 12.9448L31.8605 22.0002L22.805 31.0557L26.6941 34.9447Z" fill="white"/>
                <path className={"item-arrow-1"} d="M10.1941 34.9447L23.1387 22.0002L10.1941 9.05566L6.30504 12.9447L15.3605 22.0002L6.30504 31.0557L10.1941 34.9447Z" fill="white"/>
              </g>
              <defs>
                <clipPath id="clip0_1_7">
                <rect width="44" height="44" fill="white"/>
                </clipPath>
              </defs>
            </svg>
          </div>
        
          <div className="item-name-container">
            <div className="flex items-center justify-center">
              {itemOutMetadata.name}
            </div>
          </div>
        </div>

        <br />

        <div className="grid grid-cols-3">
          <div className="flex items-center justify-center">Items in: {calculatedItemsIn}</div>
          <div></div>
          <div className="flex items-center justify-center">Items out: {calculatedItemsOut}</div>
        </div>
      </div>     

      <input type="range" id="item-scroll" name="items" min="0" max={itemsIn} value={selectedItemsIn.current} onChange={(val) => handleSetWantedItemInput(val)} />
      
      <EveButton typeClass="primary" onClick={() => handleExecute()} disabled={!canTrade}>
        Trade Items {canTrade == false && '(Not Enough Items In)'}
      </EveButton>
    </>
  );
});

export default React.memo(StoreUser);