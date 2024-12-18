import React, { useEffect, useState } from "react";

import { useSmartObject, useNotification } from "@eveworld/contexts";
import { Severity, SmartAssemblyType } from "@eveworld/types";

import BuyLensView from "./BuyLensView";
import NotFound from "./NotFound";
import { TYPEIDS } from "@eveworld/utils";

const Depot = () => {
	const [txType, setTxType] = useState<"buy" | "sell">("buy");

	const { smartAssembly, loading } = useSmartObject() as {
		smartAssembly: SmartAssemblyType<"SmartStorageUnit">;
		loading: boolean;
	};

	const { notify, handleClose } = useNotification();

	useEffect(() => {
		if (loading) {
			notify({ type: Severity.Info, message: "Loading..." });
		} else {
			handleClose();
		}
	}, [handleClose, loading, notify]);

	// Show if smart assembly not found
	if (!smartAssembly) {
		return <NotFound typeName="Extraction Protocol Depot" />;
	}
	if (
		(!loading && smartAssembly?.typeId !== TYPEIDS.SMART_STORAGE_UNIT) ||
		(!loading && !smartAssembly?.isValid)
	) {
		return (
			<NotFound
				typeName="Extraction Protocol Depot"
				message="This isn't the Extraction Protocol Depot you're looking for"
			/>
		);
	}

	if (!smartAssembly?.isOnline) {
		notify({
			type: Severity.Warning,
			message: "Extraction Protocol Depot is not online",
		});
	}

	return (
		<div>
			<div className="flex my-4 gap-2">
				<button
					onClick={() => setTxType("buy")}
					className={`secondary w-full ${txType == "buy" ? "active" : null}`}
				>
					Buy lenses
				</button>
				<button
					onClick={() => setTxType("sell")}
					className={`secondary w-full ${txType == "sell" ? "active" : null}`}
				>
					Sell salt
				</button>
			</div>
			<BuyLensView smartAssembly={smartAssembly} />
		</div>
	);
};

export default Depot;
