import {
  ErrorNotice,
  ErrorNoticeTypes,
  EveButton,
} from "@eveworld/ui-components";
import { useAccount } from "wagmi";
import { abbreviateAddress, getDappUrl } from "@eveworld/utils";
import Toggle from "./Toggle";
import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly } from "../hooks/useSmartAssembly";
import CustomSmartAssemblyInfo from "./CustomSmartAssemblyInfo";
import EveLoadingAnimation from "@eveworld/ui-components/components/EveLoadingAnimation";
export default function EntityView() {
  const { chain } = useAccount();
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly } = useSmartAssembly();

  console.log(smartAssembly);

  if (!smartAssembly || smartAssembly == null) {
    return <ErrorNotice type={ErrorNoticeTypes.SMART_ASSEMBLY} />;
  }

  return (
    <EveLoadingAnimation position="diagonal">
    <div className="grid gap-4 grid-cols-1 mobile:px-5">
      <div>Welcome to EVE Dapp Scaffold!</div>
      <div>
        You are currently viewing information for{" "}
        <span className="underline font-bold">
          {smartAssembly?.name || abbreviateAddress(smartAssembly?.id)}
        </span>
      </div>

      <div className="text-center center">
        <div>
          Description:
          <div>{smartAssembly?.description || "No description set"}</div>
        </div>
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
    </EveLoadingAnimation>
  );
}
