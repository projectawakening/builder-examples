import {
  ErrorNotice,
  ErrorNoticeTypes,
  EveButton,
  SmartAssemblyInfo,
} from "@eveworld/ui-components";
import { useAccount } from "wagmi";

import AllowedAccess from "./AllowedAccess";
import AdminSettings from "./AdminSettings";

import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly } from "../hooks/useSmartAssembly";

export default function EntityView() {

  //const { smartAssembly, smartCharacter, loading } = useSmartObject();
  //const { notify, handleClose } = useNotification();
  const { chain } = useAccount();
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly } = useSmartAssembly();

  if (smartAssembly == null) {
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