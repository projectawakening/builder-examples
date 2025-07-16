import { useSyncStatus } from "./mud/useSyncStatus";
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

// DApp Simple Customization
const DISPLAY_EXPLORER = true;
const DISPLAY_DOCS_BUTTON = false;
const CUSTOM_LOGO_URL = "";

export const App = () => {
  const { isLive, message, percentage } = useSyncStatus();
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

  if (!address || !isConnected) {
    return (
      <>
        <ConnectWallet
          displayDocsButton={DISPLAY_DOCS_BUTTON}
          logoUrl={CUSTOM_LOGO_URL}
        />
      </>
    );
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
