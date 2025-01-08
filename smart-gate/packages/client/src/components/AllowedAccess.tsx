import React from "react";
import mudConfig from "contracts/mud.config";
import { stash } from "../mud/stash";
import { useRecord } from "../mud/useRecord";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { useSmartObject } from "@eveworld/contexts";

const AllowedAccess = React.memo(function AllowedAccess() {
  const { smartAssembly, smartCharacter } = useSmartObject();

  const allowedCorpValue = useRecord({
    stash,
    table: mudConfig.namespaces.example.tables.GateAccess,
    key: {
      smartObjectId: BigInt(smartAssembly?.id || 0),
    },
  });

  if(smartCharacter && smartCharacter.corpId == allowedCorpValue.corp.toString()){
    return (
      <center>   
        <h1>Gate Access permited ✅</h1>
      </center>
    );
  }
    
  return (
    <center>   
      <h1>Gate Access not permited ❌</h1>
      <h3>(Not in allowed corporation)</h3>
    </center>
  );
});

export default React.memo(AllowedAccess);
