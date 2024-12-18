import { useSyncProgress } from "./mud/useSyncProgress";
import { useAccount } from "wagmi";

import Footer from "./components/Footer";
import Header from "./components/Header";
import Depot from "./components/Depot";

import "./App.css";
import "@rainbow-me/rainbowkit/styles.css";
import { Explorer } from "./Explorer";

import { EveAlert } from "@eveworld/ui-components";
import { useNotification, useSmartObject } from "@eveworld/contexts";

export const App = () => {
	const { isLive, message, percentage } = useSyncProgress();
	const { smartAssembly } = useSmartObject();
	const { chain } = useAccount();
	const { notification } = useNotification();

	return (
		<>
			<EveAlert
				message={notification.message}
				severity={notification.severity}
				handleClose={notification.handleClose}
				isOpen={notification.isOpen}
				isStyled={true}
				blockExplorer={chain?.blockExplorers?.default.url}
				txHash={notification.txHash}
			/>

			<div
				className={`w-screen min-h-screen flex flex-col justify-between overflow-hidden ${
					!smartAssembly ? "" : "bg-crude-50"
				}`}
			>
				<Header />

				{isLive ? (
					<div className="flex flex-col align-center max-w-[1250px] mx-auto px-4">
						<Depot />
					</div>
				) : (
					<div className="tabular-nums">
						{message} ({percentage.toFixed(1)}%)…
					</div>
				)}
				<Footer />

				<Explorer />
			</div>
		</>
	);
};
