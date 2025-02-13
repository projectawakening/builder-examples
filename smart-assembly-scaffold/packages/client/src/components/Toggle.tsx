import React from "react";
import mudConfig from "contracts/mud.config";
import { stash } from "../mud/stash";
import { useRecord } from "../mud/useRecord";
import { useWorldContract } from "../mud/useWorldContract";
import { Severity } from "@eveworld/types";
import setToggle from "./systemCalls/handleToggle";
import { EveButton } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";

const Toggle = React.memo(function Toggle() {
  const { smartAssembly } = useSmartObject();
  const { worldContract } = useWorldContract();
  const { notify } = useNotification();

  const toggleValue = useRecord({
    stash,
    table: mudConfig.namespaces.example.tables.ToggleTable,
    key: {
      smartObjectId: BigInt(smartAssembly?.id || 0),
    },
  });

  const handleToggle = async () => {
    const txHash = await setToggle({
      worldContract,
      smartObjectId: smartAssembly?.id || import.meta.env.VITE_SMARTASSEMBLY_ID,
      currentValue: toggleValue?.isSet,
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
    <EveButton typeClass="primary" onClick={() => handleToggle()}>
      {toggleValue !== undefined
        ? `currently set to: ${toggleValue.isSet}`
        : "Click here to set toggle"}
    </EveButton>
  );
});

export default React.memo(Toggle);
