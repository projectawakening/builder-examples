import React, {useState, useEffect} from "react";
import mudConfig from "contracts/mud.config";
import { stash } from "../mud/stash";
import { useRecord } from "../mud/useRecord";
import { useWorldContract } from "../mud/useWorldContract";
import { Severity } from "@eveworld/types";
import setAllowedCorp from "./systemCalls/handleSetAllowedCorp";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";

const AllowedCorp = React.memo(function AllowedCorp() {
  const { smartAssembly, smartCharacter } = useSmartObject();
  const { worldContract } = useWorldContract();
  const { notify } = useNotification();

  const [ allowedCorpInput, setAllowedCorpInput ] = useState<string>();

  const allowedCorpValue = useRecord({
    stash,
    table: mudConfig.namespaces.example.tables.GateAccess,
    key: {
      smartObjectId: BigInt(smartAssembly?.id || 0),
    },
  });

  useEffect(() => {
    setAllowedCorpInput(allowedCorpValue.corp.toString())
  }, [allowedCorpValue])

  const handleAllowedCorpInput = (val) => {
    setAllowedCorpInput(val)
  }

  const handleToggle = async () => {
    const txHash = await setAllowedCorp({
      worldContract,
      smartObjectId: smartAssembly?.id || import.meta.env.VITE_SMARTASSEMBLY_ID,
      corpID: Number(allowedCorpInput),
    });
    if (txHash) {
      notify({ type: Severity.Success, txHash });
    } else {
      notify({
        type: Severity.Error,
        message: "Transaction failed to execute",
      });
    }
  };

  return (
    <>    
    <EveInput
      inputType="string"
      defaultValue={allowedCorpValue.corp.toString()}
      onChange={(str) => handleAllowedCorpInput(str)}
      fieldName="Allowed Corp ID"
    />

    <EveButton typeClass="primary" onClick={() => handleToggle()}>
      Set Allowed Corp ID
    </EveButton>

    <h1>ALLOWED CORP ID: {allowedCorpValue.corp.toString()}</h1>
    </>
  );
});

export default React.memo(AllowedCorp);
