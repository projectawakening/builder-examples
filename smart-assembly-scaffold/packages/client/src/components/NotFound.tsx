import { useEffect, useState } from "react";
import React from "react";

import { useSmartObject } from "@eveworld/contexts";
import { AlertIcon, Close } from "@eveworld/ui-components/assets";

import Allegrite from "../assets/allegrite.webp";
import { ReactComponent as CornerBlock } from "../assets/corner-block.svg";

const NotFound = ({
  typeName,
  message,
}: {
  typeName: string;
  message?: string;
}): JSX.Element => {
  const [smartAssemblyDefined, setSmartAssemblyDefined] =
    useState<boolean>(false);

  const { loading, smartAssembly } = useSmartObject();

  useEffect(() => {
    const smartAssemblyDefined = !loading && smartAssembly != null;
    setSmartAssemblyDefined(smartAssemblyDefined);
  }, [loading, smartAssembly]);

  return (
    <div className="flex flex-col align-center min-w-screen mx-auto items-center relative">
      <img src={Allegrite} className="absolute -top-[50%] -z-10" />
      <div className="max-w-[630px] min-w-[353px] m-28 flex-col justify-start items-start gap-4 inline-flex">
        <div className="self-stretch justify-between items-start inline-flex">
          <CornerBlock />
          <CornerBlock className="right-0 -scale-x-100" />
        </div>
        <section className="flex-col justify-start items-start flex w-full">
          <div className="self-stretch flex-col justify-start items-center flex">
            <div className="self-stretch pl-2 bg-crude-30 justify-between items-center inline-flex">
              <div className="justify-start items-center gap-2 flex text-header">
                <span className="text-header text-opacity-50">Status: </span>
                ERROR
              </div>
              <div className="w-6 p-1 border border-orange-100/50 justify-center items-center gap-2 flex">
                <Close />
              </div>
            </div>
            <div className="self-stretch p-1 border border-orange-100/30 flex-col justify-start items-start flex">
              <div className="self-stretch p-6 bg-blue-warn border border-orange-100/30 flex-col justify-start items-center gap-10 flex">
                <div className="justify-center items-center gap-2 inline-flex">
                  <div className="w-6 h-6 bg-crude-50 border border-blue-700 justify-center items-center gap-2 flex">
                    <div className="w-4 h-4 relative m-2 flex items-center">
                      <AlertIcon className="text-blue-warn" />
                    </div>
                  </div>
                  <div className="flex-col justify-start items-start gap-4 inline-flex">
                    <div className="text-center text-orange-100 text-lg font-semibold leading-snug">
                      {message
                        ? message
                        : !smartAssemblyDefined
                          ? "Please define a smart assembly to search for."
                          : `The ${typeName} you are looking for cannot be found.`}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <div className="self-stretch justify-between inline-flex">
          <CornerBlock className="right-0 -scale-y-100" />
          <CornerBlock className="left-0 rotate-180" />
        </div>
      </div>
    </div>
  );
};

export default NotFound;
