import React, {useState, useEffect} from "react";
import mudConfig from "contracts/mud.config";
import { stash } from "../mud/stash";
import { useRecord } from "../mud/useRecord";
import { useWorldContract } from "../mud/useWorldContract";
import { Severity } from "@eveworld/types";
import setAllowedCorp from "./systemCalls/handleSetAllowedCorp";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";

const AllowedAccess = React.memo(function AllowedAccess() {
  const { smartAssembly, smartCharacter } = useSmartObject();
  const { worldContract } = useWorldContract();
  const { notify } = useNotification();

  const allowedCorpValue = useRecord({
    stash,
    table: mudConfig.namespaces.example.tables.GateAccess,
    key: {
      smartObjectId: BigInt(smartAssembly?.id || 0),
    },
  });

  console.log("TWO")
  console.log(smartCharacter)

  if(smartCharacter){
    if(smartCharacter.corpId == allowedCorpValue.corp.toString()){
      return (
        <>   
          <h1>Access allowed ✅</h1>
        </>
      );
    } else{
      return (
        <>   
          <h1>Access not allowed ❌</h1>
        </>
      );
    }
  }
    
  return (
    <>   
      <h1>ALLOWED CORP ID: {allowedCorpValue.corp.toString()}</h1>
    </>
  );
});

export default React.memo(AllowedAccess);
