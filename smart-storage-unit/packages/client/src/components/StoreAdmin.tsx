import React, {useState, useEffect} from "react";
import { useWorldContract } from "../mud/useWorldContract";
import { Severity } from "@eveworld/types";
import { EveButton, EveInput, EveScroll } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";

//System Calls
import setRatio from "./systemCalls/handleSetRatio";
import setInputItem from "./systemCalls/handleSetInputItem";
import setOutputItem from "./systemCalls/handleSetOutputItem";

//Data Types
import SSUConfigData from "./dataTypes";

//Custom Components
import ItemSearchResult from "./ItemSearchResult";

import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly, useEphemeralInventory } from "../hooks/useSmartAssembly";

//Item Data Interface for search
interface ItemMetadata{
  name: string,
  image: string,
  smartObjectId: string
}

const StoreAdmin = React.memo(
  ({
    ssuConfig,
    typesCache
  }: {
    ssuConfig: SSUConfigData,
    typesCache: any
  }) => {
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly } = useSmartAssembly();
  const { worldContract } = useWorldContract();
  const { notify } = useNotification();

  const [ adminAccess, setAdminAccess ] = useState<boolean>(false);

  const [ ratioInputIn, setRatioInputIn ] = useState<string>("");
  const [ ratioInputOut, setRatioInputOut ] = useState<string>("");

  const [ itemInputIn, setItemInputIn ] = useState<string>("");

  const [ itemInputInPreviews, setItemInputInPreviews ] = useState<ItemMetadata[]>([]);  
  const [ itemInputOutPreviews, setItemInputOutPreviews ] = useState<ItemMetadata[]>([]);

  const [ itemInputOut, setItemInputOut ] = useState<string>("");

  //Check if the user owns the smart assembly used with the DApp
  useEffect(() => {
    if(smartCharacter == null || smartAssembly == null) return;      

    if(smartAssembly.ownerId == smartCharacter.address){
      setAdminAccess(true);
    } else{
      setAdminAccess(false);
    }
    
  }, [smartCharacter])

  //Set the input item
  const handleSetInputItem = async (id:string) => {
    if(id == null || id == ""){
      id = itemInputIn
    }
    try{
      const txHash = await setInputItem({worldContract, 
        currentConfig: ssuConfig, 
        inputItem: id
      });

      if(txHash){      
        notify({ type: Severity.Info, message: "Successfully Set Input Item" });
      }
    }    
    catch(err){
      notify({ type: Severity.Error, message: "Could Not Set Input Item" });
      throw err;
    }
  }

  //Set the output item
  const handleSetOutputItem = async (id:string) => {    
    if(id == null || id == ""){
      id = itemInputOut
    }

    try{
      const txHash = await setOutputItem({worldContract, 
        currentConfig: ssuConfig, 
        outputItem: id
      });

      if(txHash){      
        notify({ type: Severity.Info, message: "Successfully Set Output Item" });
      }
    }
    catch(err){
      notify({ type: Severity.Error, message: "Could Not Set Output Item" });
      throw err;
    }
  }

  const getItemMetadataArrayFromName = async (name:string) => {
    name = name.toLowerCase();

    const filteredTypes = Object.keys(typesCache).filter((type) => typesCache[type].name.toLowerCase().includes(name));

    let foundData = []

    for(var key in filteredTypes){
      var type = typesCache[filteredTypes[key]]

      if(type != null){
        var data : ItemMetadata = {
          name: type.name,
          image: "",
          smartObjectId: type.smartItemId
        }

        foundData.push(data)
      }
    }    

    return foundData;
  }

  const handleSearchItemIn = async (str:string) => {
    let foundData = await getItemMetadataArrayFromName(str);

    setItemInputInPreviews(foundData);
  }

  const handleSearchItemOut = async (str:string) => {
    let foundData = await getItemMetadataArrayFromName(str);

    setItemInputOutPreviews(foundData);
  }

  const handleSetRatio = async () => {
    var itemsIn = Number(ratioInputIn);
    var itemsOut = Number(ratioInputOut);

    if(itemsIn == 0 || itemsOut == 0) return;

    const txHash = await setRatio({worldContract, 
      inputRatio: itemsIn, 
      outputRatio: itemsOut,
      itemIDIn: ssuConfig.itemIn.toString(),
      itemIDOut: ssuConfig.itemOut.toString()
    });

    try{
      if(txHash){      
        notify({ type: Severity.Info, message: "Successfully Set Ratio" });
      }
    }    
    catch(err){
      notify({ type: Severity.Error, message: "Could Not Set Ratio" });
      throw err;
    }
  };

  if(adminAccess == false){
    return (
      <>        
        <div>Admin Settings</div>
        <div className="text-center">   
          Admin Access not permited ❌<br />(You are not the owner)
        </div>
      </>
    )
  }

  if(ssuConfig == null){
    return (
      <div>
        LOADING
      </div>
    )
  }

  return (
    <>    
      <div>Admin Settings (Only you can see this)</div>
      
      <div>Ratio</div>
      <div className="grid grid-cols-2">
        <EveInput
          inputType="numerical"
          placeholder={ssuConfig.ratioIn.toString()}
          onChange={(str) => setRatioInputIn(str)}
          fieldName="Ratio In"
        />
        <EveInput
          inputType="numerical"
          defaultValue={ssuConfig.ratioOut.toString()}
          onChange={(str) => setRatioInputOut(str)}
          fieldName="Ratio Out"
        />
      </div>

      <EveButton typeClass="primary" onClick={() => handleSetRatio()} disabled={false}>
        Set Ratio
      </EveButton>

      <div>Items</div>
      <EveInput
          inputType="string"
          placeholder={"Item Name"}
          onChange={(str) => handleSearchItemIn(str)}
          fieldName="Search Input Item By Name"
        />

      <div className="grid border border-brightquantum bg-crude">
        <EveScroll
          maxHeight="200px"
        >          
        {itemInputInPreviews.map((item:ItemMetadata) => {
          return <ItemSearchResult 
            key={item.smartObjectId}
            item={item}
            selectFunction={() => handleSetInputItem(item.smartObjectId)}
          />
        })}
        </EveScroll>
      </div>

      <EveInput
        inputType="string"
        defaultValue={ssuConfig.itemIn.toString()}
        onChange={(str) => setItemInputIn(str)}
        fieldName="Set Input Item By Smart ID"
      />

      <EveButton typeClass="primary" onClick={() => handleSetInputItem(null)} disabled={false}>
        Set Input Item
      </EveButton>
      
      <EveInput
          inputType="string"
          placeholder={"Item Name"}
          onChange={(str) => handleSearchItemOut(str)}
          fieldName="Search Output Item By Name"
      />
      
      <div className="grid border border-brightquantum bg-crude">
        <EveScroll
          maxHeight="200px"
        >          
        {itemInputOutPreviews.map((item:ItemMetadata) => {
          return <ItemSearchResult 
            key={item.smartObjectId}
            item={item}
            selectFunction={() => handleSetOutputItem(item.smartObjectId)}
          />
        })}
        </EveScroll>
      </div>

      <EveInput
        inputType="string"
        defaultValue={ssuConfig.itemOut.toString()}
        onChange={(str) => setItemInputOut(str)}
        fieldName="Set Output Item By Smart ID"
      />

      <EveButton typeClass="primary" onClick={() => handleSetOutputItem(null)} disabled={false}>
        Set Output Item
      </EveButton>
    </>
  );
});

export default React.memo(StoreAdmin);