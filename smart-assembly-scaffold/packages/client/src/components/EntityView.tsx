import {
  ErrorNotice,
  ErrorNoticeTypes,
  EveButton,
} from "@eveworld/ui-components";
import { useAccount } from "wagmi";
import { abbreviateAddress, getDappUrl } from "@eveworld/utils";

import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly } from "../hooks/useSmartAssembly";

import { ExternalIcon } from "@eveworld/ui-components/assets";

import CustomSmartAssemblyInfo from "./CustomSmartAssemblyInfo";

import Toggle from "./Toggle";

export default function EntityView() {
  const { chain } = useAccount();
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly } = useSmartAssembly();

  if (!smartAssembly || smartAssembly == null) {
    return <ErrorNotice type={ErrorNoticeTypes.SMART_ASSEMBLY} />;
  }

  return (
    <div className="grid gap-4 grid-cols-1 mobile:px-5">
      <div>
        Welcome to the <b>EVE Dapp Scaffold</b>!
      </div>
      <div>
        You are currently viewing information for{" "}
        <span className="underline font-bold">
          {smartAssembly?.name || abbreviateAddress(smartAssembly?.id)}
        </span>
      </div>

      <div className="grid grid-cols-2">
        <div style={{ width: "150%", paddingRight: "10px" }}>
          Description:
          <div>{smartAssembly?.description || "No description set"}</div>
        </div>

        <EveButton
          typeClass="secondary"
          onClick={() => window.open(getDappUrl(smartAssembly))}
          disabled={!smartAssembly?.dappURL}
          style={{ width: "50%", justifySelf: "end" }}
        >
          <ExternalIcon
            style={{
              width: "15px",
              height: "15px",
            }}
          />
          <span style={{ marginLeft: "5px" }}>dApp link</span>
        </EveButton>
      </div>

      <Toggle />

      <div>
        <CustomSmartAssemblyInfo
          assembly={smartAssembly}
          character={smartCharacter}
          chainName={chain?.name || ""}
          inventory={smartAssembly?.storage?.mainInventory?.items}
        />
      </div>
    </div>
  );
}
