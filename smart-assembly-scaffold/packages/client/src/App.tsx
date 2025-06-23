import { useSyncProgress } from "./mud/useSyncProgress";
import { useAccount } from "wagmi";

import "./App.css";
import "@rainbow-me/rainbowkit/styles.css";

import { ConnectWallet, EveAlert, EveLayout } from "@eveworld/ui-components";
import { useNotification } from "@eveworld/contexts";
import { Explorer } from "./Explorer";
import { useSmartCharacter } from "./hooks/useSmartCharacter";
import { useEffect } from "react";
import { Severity } from "@eveworld/types";
import { EveLinearBar } from "@eveworld/ui-components";

import EntityView from "./components/EntityView";

const DISPLAY_EXPLORER = true;

export const App = () => {
  const { isLive, message, percentage } = useSyncProgress();
  const { smartCharacter } = useSmartCharacter();
  const { address, isConnected } = useAccount();
  const { notification, notify, handleClose } = useNotification();

  useEffect(() => {
    if (!isLive) {
      notify({ type: Severity.Info, message: "Loading..." });
    } else {
      handleClose();
    }
  }, [handleClose, isLive, notify]);

  if (!address || !isConnected){ 
    return <ConnectWallet displayDocsButton={false} logoUrl={"https://evefrontier.com/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2Fnl199sv2jlik%2F1GcQ6Bm96b8S5aOXM6LeVX%2F5b384ffae8174e69c2952458b07cf232%2Fccp_logo.png&w=3840&q=75"} />;
  }

  return (
    <>
      <EveAlert
        message={notification.message}
        severity={notification.severity}
        handleClose={notification.handleClose}
        isOpen={notification.isOpen}
        isStyled={false}
        txHash={notification.txHash}
      />

      <EveLayout smartCharacter={smartCharacter}>
        {isLive ? (
          <div className="flex flex-col align-center max-w-[1250px] mx-auto px-4">
            <EntityView />
          </div>
        ) : (
          <div className="flex items-center justify-center min-h-screen">
            <div className="tabular-nums">
              <div className="align-center text-center center">
                <EveLinearBar nominator={percentage} denominator={100} />
                {message}…
              </div>
            </div>
          </div>
        )}
      </EveLayout>

      {DISPLAY_EXPLORER && <Explorer />}
    </>
  );
};
