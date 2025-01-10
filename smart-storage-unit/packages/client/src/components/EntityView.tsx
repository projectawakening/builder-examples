import { useState, useEffect } from "react";
import { useSmartObject, useNotification } from "@eveworld/contexts";
import { Severity } from "@eveworld/types";

import mudConfig from "contracts/mud.config";
import { stash } from "../mud/stash";
import { useRecord } from "../mud/useRecord";

import {
  ErrorNotice,
  ErrorNoticeTypes
} from "@eveworld/ui-components";
import { useAccount } from "wagmi";

//Data Types
import SSUConfigData from "./dataTypes";

//Custom Components
import StoreUser from "./StoreUser";
import StoreAdmin from "./StoreAdmin";

export default function EntityView() {
  const { smartAssembly, smartCharacter, loading } = useSmartObject();
  const { notify, handleClose } = useNotification();
  const { chain } = useAccount();

  const [ ssuConfig, setSSUConfig ] = useState<SSUConfigData>(null);

  const [ typesCache, setTypesCache ] = useState<any>();  

  //Loading runtime
  useEffect(() => {
    if (loading) {
      notify({ type: Severity.Info, message: "Loading..." });
    } else {
      handleClose();
    }
  }, [loading]);  

  //Cache all item type information for use within the DApp
  const CacheTypes = async () => {
    const response = await fetch(`https://blockchain-gateway-stillness.live.tech.evefrontier.com/types`)
      
    if(!response.ok) {
      throw response;
    }

    const result = await response.json();
    setTypesCache(result);
  }

  //Cache the types from the World API
  useEffect(() => {   
    CacheTypes(); 
  }, [])
  
  function setup(){
    //Get the DApp Config. This is used to see what item in should be promoted on the DApp
    let dAppConfig = useRecord({
      stash,
      table: mudConfig.namespaces.example2.tables.DAppConfig,    
      key: {
        smartObjectId: BigInt(smartAssembly?.id || 0),
      },
    });

    if(dAppConfig == null) return;

    //Get the SSU Config, using the promoted input item ID
    let foundSSUConfig = useRecord({
      stash,
      table: mudConfig.namespaces.example2.tables.RatioConfig,    
      key: {
        smartObjectId: BigInt(smartAssembly?.id || 0),
        itemIn: BigInt(dAppConfig.promotedItem)
      },
    });

    if(foundSSUConfig != null && foundSSUConfig != ssuConfig){
      setSSUConfig(foundSSUConfig)
    }
  }

  //Fetch the config
  setup();

  if ((!loading && !smartAssembly) || smartAssembly == null) {
    return <ErrorNotice type={ErrorNoticeTypes.SMART_ASSEMBLY} />;
  }

  //Still loading
  if (ssuConfig == null){  
    return <ErrorNotice type={ErrorNoticeTypes.MESSAGE} errorMessage={"Loading Config"} />;
  }

  return (
    <div className="grid gap-4 grid-cols-1 mobile:px-5">      
      <div>{smartAssembly.name ? smartAssembly.name: "SSU Store"}</div>
      <div className="grid grid-cols-2">
        <div>
          <div>{smartAssembly?.description || "No description set"}</div>
        </div>
      </div>
      
      <br />
      <StoreUser ssuConfig={ssuConfig} typesCache={typesCache} />

      <br />
      <StoreAdmin ssuConfig={ssuConfig} typesCache={typesCache} className="item-name-container" />
    </div>
  );
}