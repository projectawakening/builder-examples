import { useSyncProgress } from "./mud/useSyncProgress";
import { useAccount } from "wagmi";

import "./App.css";
import "@rainbow-me/rainbowkit/styles.css";

import { EveAlert, EveLayout } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";
import EntityView from "./components/EntityView";
import Header from "./components/Header";

export const App = () => {
	const { isLive, message, percentage } = useSyncProgress();
	const { smartAssembly, smartCharacter } = useSmartObject();
	const { chain } = useAccount();
	const { notification } = useNotification();

	return (
		<>
			<EveAlert
				message={notification.message}
				severity={notification.severity}
				handleClose={notification.handleClose}
				isOpen={notification.isOpen}
				isStyled={false}
				blockExplorer={chain?.blockExplorers?.default.url}
				txHash={notification.txHash}
			/>

			<Header smartCharacter={smartCharacter} />

{/* <EveLayout
        isCurrentChain={true}
        connected={connected}
        handleDisconnect={() => {}}
        walletClient={walletClient}
        smartCharacter={smartCharacter}
      > */}

{isLive ? (
					<div className="flex flex-col align-center max-w-[1250px] mx-auto px-4">
						<EntityView />
					</div>
				) : (
					<div className="tabular-nums">
						{message} ({percentage.toFixed(1)}%)…
					</div>
				)}
      {/* </EveLayout> */}
		</>
	);
};
