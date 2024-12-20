import { useEffect } from "react";

import { useSmartObject, useNotification } from "@eveworld/contexts";
import { Severity } from "@eveworld/types";
import {
  ErrorNotice,
  ErrorNoticeTypes,
  EveButton,
  SmartAssemblyInfo,
} from "@eveworld/ui-components";
import { useAccount } from "wagmi";
import { abbreviateAddress, getDappUrl } from "@eveworld/utils";
import Toggle from "./Toggle";

export default function EntityView() {
  const { smartAssembly, smartCharacter, loading } = useSmartObject();
  const { notify, handleClose } = useNotification();
  const { chain } = useAccount();

  useEffect(() => {
    if (loading) {
      notify({ type: Severity.Info, message: "Loading..." });
    } else {
      handleClose();
    }
  }, [loading]);

  if ((!loading && !smartAssembly) || smartAssembly == null) {
    return <ErrorNotice type={ErrorNoticeTypes.SMART_ASSEMBLY} />;
  }

  return (
    <div className="grid gap-4 grid-cols-1 mobile:px-5">
      <div>Welcome to EVE Dapp Scaffold!</div>
      <div>
        You are currently viewing information for{" "}
        <span className="underline font-bold">
          {smartAssembly?.name || abbreviateAddress(smartAssembly?.id)}
        </span>
      </div>

      <div className="grid grid-cols-2">
        <div>
          Description:
          <div>{smartAssembly?.description || "No description set"}</div>
        </div>

        <EveButton
          typeClass="secondary"
          onClick={() => window.open(getDappUrl(smartAssembly))}
          disabled={!smartAssembly?.dappUrl}
        >
          dApp link
        </EveButton>
      </div>

      <Toggle />

      <div>
        <SmartAssemblyInfo
          smartAssembly={smartAssembly}
          smartCharacter={smartCharacter}
          chainName={chain?.name || ""}
        />
      </div>
    </div>
  );
}
