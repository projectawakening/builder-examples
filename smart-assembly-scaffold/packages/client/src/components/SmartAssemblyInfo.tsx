import React, { useEffect, useMemo, useState } from "react";

import { abbreviateAddress, isOwner } from "@eveworld/utils";
import {
  SmartCharacter,
  State,
  SmartAssemblyType,
  SmartAssemblies,
} from "@eveworld/types";
import {SmartAssemblyFuel, ClickToCopy, EveScroll} from "@eveworld/ui-components";

/**
 * Component that displays information about a smart assembly, including owner, solar system, asset ID, type ID, state, and chain.
 * Calculates and displays the fuel amount in m3 using the provided fuel amount, fuel max capacity, and fuel unit volume.
 *
 * @returns JSX.Element representing the smart assembly information UI.
 */
const SmartAssemblyInfo = React.memo(function SmartAssemblyInfo
  ({
    smartAssembly,
    smartCharacter,
    chainName
  }: {
    smartAssembly: SmartAssemblyType<SmartAssemblies> | null;
    smartCharacter: SmartCharacter;
    chainName: string;
  }): JSX.Element {
    const [characterName, setCharacterName] = useState<string>("");

    useEffect(() => {
      if (!smartAssembly || !smartAssembly.ownerId) return;

      const getSmartCharacter = async () => {
        try {
          const smartCharacter: SmartCharacter = await fetch(
            `${import.meta.env.VITE_GATEWAY_WS}/smartcharacters/${smartAssembly.ownerId}`,
          ).then((x) => x.json());

          setCharacterName(smartCharacter.name);
        } catch (e) {
          console.error("Error:", e);
        }
      };

      getSmartCharacter();
    }, []);


    const isAssemblyOwner = useMemo((): boolean => {
      return isOwner(smartAssembly, smartCharacter?.address);
    }, [smartAssembly, smartCharacter]);

    if (!smartAssembly) return <></>;

    return (
      <>
        <div className="Quantum-Container Title row-start-1">About</div>
        <div
          className="Entity-About Quantum-Container row-start-2 !py-4 !px-2"
          id="entity-about"
        >
          <EveScroll
            maxHeight="250px"
            classStyles="grid grid-cols-[2fr_3fr] gap-2 text-xs w-full h-full"
          >
            <SmartAssemblyInfoLine
              title="Owner"
              value={smartAssembly.ownerId}
              additionalInfo={`${
                isAssemblyOwner ? "(You)" : ""
              } ${characterName ? characterName : ""}`}
              clickToExpand={true}
            />
            <SmartAssemblyInfoLine
              title="Solar System"
              value={smartAssembly.solarSystem.solarSystemName}
            />
            <SmartAssemblyInfoLine
              title="Asset ID"
              value={smartAssembly.id}
              clickToExpand={true}
            />
            <SmartAssemblyInfoLine
              title="Assembly Type"
              value={smartAssembly.assemblyType.toString()}
            />
            <SmartAssemblyInfoLine
              title="Type ID"
              value={smartAssembly.typeId.toString()}
            />
            <SmartAssemblyInfoLine
              title="State"
              value={State[smartAssembly.stateId]}
            />
            <SmartAssemblyInfoLine
              title="Chain"
              value={`${chainName} (${smartAssembly.chainId})`}
            />
          </EveScroll>
        </div>
        <SmartAssemblyFuel smartAssembly={smartAssembly} className="row-start-3" />
      </>
    );
  },
);

const SmartAssemblyInfoLine = React.memo(function SmartAssemblyInfoLine
  ({
    title,
    value,
    additionalInfo,
    clickToExpand,
  }: {
    title: string;
    value: string;
    additionalInfo?: string;
    clickToExpand?: boolean;
  }) {
    return (
      <>
        <span className="self-center">{title}</span>
        <span className="capitalize flex flex-col justify-center overflow-hidden text-right w-full items-end">
          <span className="flex">
            {clickToExpand ? abbreviateAddress(value, 7) : value}{" "}
            {clickToExpand && <ClickToCopy text={value} />}
          </span>
          {additionalInfo}
        </span>
      </>
    );
  },
);

export default React.memo(SmartAssemblyInfo);
