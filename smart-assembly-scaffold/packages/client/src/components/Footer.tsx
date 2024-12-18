import React from "react";

import { useSmartObject } from "@eveworld/contexts";
import { ClickToCopy } from "@eveworld/ui-components";
import { abbreviateAddress } from "@eveworld/utils";

import { ReactComponent as NetworkIcon } from "../assets/network.svg";

const Footer = React.memo(function Footer(){
  const { smartAssembly } = useSmartObject();

  return (
    <div
      className={`w-screen bottom-0 px-4 py-2 mt-4 bg-crude-50 justify-between items-center inline-flex ${
        !smartAssembly ? "" : "mobile:flex-col self-center"
      }`}
      id="footer"
    >
      <div className="gap-4 tablet:gap-2 flex info tablet:self-start mobile:mt-2">
        <NetworkIcon className="w-4 h-4 relative" />
        NETWORK INFO:
      </div>
      <div
        className={`justify-center gap-4 tablet:gap-2 flex info text-right tablet:flex-col ${
          !smartAssembly ? "" : "tablet:self-end"
        }`}
      >
        {!smartAssembly ? (
          <div className="col-span-full">
            State:
            <span>WAITING</span>
          </div>
        ) : (
          <>
            <div>
              Owner:
              <span className="cursor-pointer">
                {abbreviateAddress(smartAssembly.ownerId, 4)}
              </span>
              <ClickToCopy text={smartAssembly.ownerId} />
            </div>
            <div>
              Asset ID:
              <span className="cursor-pointer">
                {abbreviateAddress(smartAssembly.id, 4)}
              </span>
              <ClickToCopy text={smartAssembly.id} />
            </div>
            <div>
              State:
              <span>{smartAssembly.state}</span>
            </div>
            <div>
              Chain:
              <span>
                {/* {publicClient?.chain?.name} ({smartAssembly.chainId}) */}
              </span>
            </div>
            <div>
              Location:
              <span>{smartAssembly.solarSystem.solarSystemName}</span>
            </div>
            <div>
              Type:
              <span>{smartAssembly?.typeId}</span>
            </div>
          </>
        )}
      </div>
    </div>
  );
});

export default Footer;
