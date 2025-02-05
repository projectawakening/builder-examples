import {
  ErrorNotice,
  ErrorNoticeTypes,
  EveButton,
  SmartAssemblyInfo,
} from "@eveworld/ui-components";
import { useAccount } from "wagmi";
import { abbreviateAddress, getDappUrl } from "@eveworld/utils";
import Toggle from "./Toggle";
import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly } from "../hooks/useSmartAssembly";

export default function EntityView() {
  const { chain } = useAccount();
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly } = useSmartAssembly();

  if (!smartAssembly || smartAssembly == null) {
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
