import { useEffect, useState } from "react";
import { twMerge } from "tailwind-merge";
import { useAccount } from "wagmi";
import { getWorldDeploy } from "./mud/getWorldDeploy";
import { EveButton } from "@eveworld/ui-components";

export function Explorer() {
  const [open, setOpen] = useState(false);
  const [worldAddress, setWorldAddress] = useState<string>("");
  const { chain } = useAccount();

  useEffect(() => {
    const getWorldAddress = async () => {
      const { address: worldAddress } = await getWorldDeploy(chain?.id ?? 31337);
      setWorldAddress(worldAddress);
    };

    getWorldAddress();
  }, []);

  const explorerUrl = chain?.blockExplorers?.worldsExplorer?.url;

  if (!explorerUrl) return null;

  return (
    <div className="fixed bottom-0 inset-x-0 flex flex-col opacity-80 transition hover:opacity-100">
      <div>
        <EveButton onClick={() => setOpen(!open)} typeClass="primary">
          {open ? "Close" : "World Explorer"}
        </EveButton>
      </div>

      <iframe
        src={`${explorerUrl}/${worldAddress}`}
        className={twMerge("transition-all", open ? "h-[50vh]" : "h-0")}
      />
    </div>
  );
}
