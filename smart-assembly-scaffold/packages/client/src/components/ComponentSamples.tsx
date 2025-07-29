import {
  ErrorNotice,
  ErrorNoticeTypes,
  EveButton,
  EveAlert,
  EveInput,
  EveLinearBar,
  EveLoadingAnimation
} from "@eveworld/ui-components";
import { useAccount } from "wagmi";
import { abbreviateAddress, getDappUrl } from "@eveworld/utils";
import { Severity, SmartAssemblyType } from "@eveworld/types";

import { useSmartCharacter } from "../hooks/useSmartCharacter";
import { useSmartAssembly } from "../hooks/useSmartAssembly";

import { ExternalIcon } from "@eveworld/ui-components/assets";

import CustomSmartAssemblyInfo from "./CustomSmartAssemblyInfo";

import Toggle from "./Toggle";

export default function ComponentSamples() {
  const { chain } = useAccount();
  const { smartCharacter } = useSmartCharacter();
  const { smartAssembly: assembly } = useSmartAssembly();

  const smartAssembly = assembly as SmartAssemblyType<"SmartStorageUnit">;

  if (!smartAssembly || smartAssembly == null) {
    return <ErrorNotice type={ErrorNoticeTypes.SMART_ASSEMBLY} />;
  }

  return (
    <div className="grid gap-4 grid-cols-1 mobile:px-5">
      <div>
        Below is a style + component kit for getting started with building DApps using this scaffold.
        <br /><br />
        Remember, this is just a starting point, you can build and customize your DApp however you want.
        <br /><br />

        <p className="text-4xl">Text Elements</p>
        <hr /><br />

        <p className="text-5xl">text-5xl</p>
        <p className="text-4xl">text-4xl</p>
        <p className="text-3xl">text-3xl</p>
        <p className="text-2xl">text-2xl</p>
        <p className="text-xl">text-xl</p>
        <p className="text-lg">text-lg</p>
        <p className="text-base">text-base</p>
        <p className="text-sm">text-sm</p>
        <p className="text-xs">text-xs</p>
        <i>Italic</i><br />
        <b>Bold</b><br />
        <u>Underline</u><br />
        <s>Strikethrough</s><br />
        <br />
        
        <br />
        <p className="text-4xl">Colors</p>
        <hr /><br />

        <div className="flex flex-row gap-2">
          <div className="w-20 h-20 color-guide" style={{ backgroundColor: "hsla(26, 85%, 58%, 1)" }}></div>
          <div className="w-20 h-20 color-guide" style={{ backgroundColor: "hsla(23, 95%, 40%, 0.8)" }}></div>
          <div className="w-20 h-20 color-guide" style={{ backgroundColor: "hsla(60, 100%, 92%, 0.2)" }}></div>
          <div className="w-20 h-20 color-guide" style={{ backgroundColor: "hsla(20, 65%, 5%, 0.5)" }}></div>
        </div>

        <br />
        <p className="text-4xl">Buttons</p>
        <hr /><br />

        <EveButton typeClass="primary">Button primary</EveButton>
        <EveButton typeClass="secondary">Button secondary</EveButton>
        <EveButton typeClass="tertiary">Button tertiary</EveButton>
        
        <br />
        <p className="text-4xl">Input</p>
        <hr /><br />

        <EveInput inputType="string" placeholder="Input" defaultValue={""} fieldName="string" onChange={() => {}} />
        <EveInput inputType="multiline" placeholder="Input" defaultValue={""} fieldName="multiline" onChange={() => {}} />
        <EveInput inputType="numerical" placeholder="Input" defaultValue={"10"} fieldName="numerical" onChange={() => {}} />


        <br />
        <p className="text-4xl">Utility</p>
        <hr /><br />

        <EveLinearBar nominator={10} denominator={100} label='EveLinearBar'/>
        
        <br />
        <EveLoadingAnimation position='vertical' children={<div className="center">
          <div className="h-20 center text-center align-vertical">EveLoadingAnimation Vertical</div>
        </div>} />
        <br />

      </div>
    </div>
  );
}
