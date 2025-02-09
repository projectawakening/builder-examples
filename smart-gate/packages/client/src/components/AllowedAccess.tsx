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
      <div className="text-center">    
        Gate Access permited ✅
      </div>
    );
  }
    
  return (
    <div className="text-center">    
      Gate Access not permited ❌<br/>
      (Not in allowed corporation)
    </div>
  );
});

export default React.memo(AllowedAccess);
