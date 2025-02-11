import React from "react";
import mudConfig from "contracts/mud.config";
import worldMudConfig from "contracts/eveworld/mud.config";
import { stash } from "../mud/stash";
import { useRecord } from "../mud/useRecord";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { useSmartObject } from "@eveworld/contexts";

import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly } from "../hooks/useSmartAssembly";

const AllowedAccess = React.memo(function AllowedAccess() {
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly } = useSmartAssembly();

  const allowedCorpValue = useRecord({
    stash,
    table: mudConfig.namespaces.example.tables.GateAccess,
    key: {
      smartObjectId: BigInt(smartAssembly?.id || 0),
    },
  });  

  const characterRecord = useRecord({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.CharactersTable,
    key: {
      characterId: smartCharacter?.id,
    },
  });

  if(smartCharacter && allowedCorpValue && characterRecord.corpId == allowedCorpValue.corp.toString()){
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
