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

  const [ adminAccess, setAdminAccess ] = useState<boolean>(false);
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

  useEffect(() => {
    if(smartCharacter != null){
      var assemblies = smartCharacter.smartAssemblies.filter(assembly => assembly.id == smartAssembly.id)

      if(assemblies.length != 0){
        setAdminAccess(true);
      } else{
        setAdminAccess(false);
      }
    }
  }, [smartCharacter])

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

  if(adminAccess == false){
    return (
      <>        
        <h1>Admin Settings</h1>
        <center>   
          <h1>Admin Access not permited ❌<br />(You are not the owner)</h1>
        </center>
      </>
    )
  }

  return (
    <>    
      <h1>Admin Settings</h1>
      <EveInput
        inputType="string"
        defaultValue={allowedCorpValue.corp.toString()}
        onChange={(str) => handleAllowedCorpInput(str)}
        fieldName="Allowed Corp ID"
      />

      <EveButton typeClass="primary" onClick={() => handleToggle()} disabled={allowedCorpValue.corp.toString()==allowedCorpInput}>
        Set Allowed Corp ID
      </EveButton>

      <h1>ALLOWED CORP ID: {allowedCorpValue.corp.toString()}</h1>
      <h1>YOUR CORP ID: {smartCharacter.corpId.toString()}</h1>
    </>
  );
});

export default React.memo(AllowedCorp);
