import React, {useState, useEffect} from "react";
import mudConfig from "contracts/mud.config";
import { stash } from "../mud/stash";
import { useRecord } from "../mud/useRecord";
import { useWorldContract } from "../mud/useWorldContract";
import { Severity } from "@eveworld/types";
import setAllowedCorp from "./systemCalls/handleSetAllowedCorp";
import { EveButton, EveInput } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";

const AdminSettings = React.memo(function AllowedCorp() {
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
        <div>Admin Settings</div>
        <div className="text-center">    
          Admin Access not permitted ❌<br />(You are not the owner)
        </div>
      </>
    )
  }

  return (
    <>    
      <div>Admin Settings</div>
      <EveInput
        inputType="string"
        defaultValue={allowedCorpValue.corp.toString()}
        onChange={(str) => handleAllowedCorpInput(str)}
        fieldName="Allowed Corp ID"
      />

      <EveButton typeClass="primary" onClick={() => handleToggle()} disabled={allowedCorpValue.corp.toString()==allowedCorpInput}>
        Set Allowed Corp ID
      </EveButton>

      <div>ALLOWED CORP ID: {allowedCorpValue.corp.toString()}</div>
      <div>YOUR CORP ID: {smartCharacter.corpId.toString()}</div>
    </>
  );
});

export default React.memo(AdminSettings);
