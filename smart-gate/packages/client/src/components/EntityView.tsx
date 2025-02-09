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

import AllowedAccess from "./AllowedAccess";
import AdminSettings from "./AdminSettings";

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
      <div>{smartAssembly?.name} Smart Gate Allow List</div>
      
      <div className="grid grid-cols-2">
        <div>
          <div>{smartAssembly?.description || "No description set"}</div>
        </div>
      </div>
      
      <br />
      <AllowedAccess />
      
      <br /><br />
      <AdminSettings />
    </div>
  );
}