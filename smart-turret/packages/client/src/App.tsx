import { useMUD } from "./MUDContext";
import ManageErc20Token from "./components/manageErc20Token"
import React, { useEffect, useState } from "react";
import { EveButton, Header } from "@eveworld/ui-components";
import { abbreviateAddress } from "@eveworld/utils";
import { SmartCharacter } from "@eveworld/types";
import "./styles.css";
import BuyItem from "./components/buyItem"
import SellItem from "./components/sellItem";

export const App = () => {
	const [smartCharacter, setSmartCharacter] = useState<SmartCharacter>({
		address: `0x`,
		id: "",
		name: "",
		isSmartCharacter: false,
		eveBalanceWei: 0,
		gasBalanceWei: 0,
		image: "",
		smartAssemblies: []
	});

	const {
		network: { walletClient },
		systemCalls: {
			collectTokens,
		},
	} = useMUD();

	/**
	 * Initializes a SmartCharacter object with default values and sets it using the useState hook.
	 * @returns void
	 */
	useEffect(() => {
		const smartCharacter: SmartCharacter = {
			address: walletClient.account?.address as `0x${string}`,
			id: "",
			name: "",
			isSmartCharacter: false,
			eveBalanceWei: 0,
			gasBalanceWei: 0,
			image: "",
			smartAssemblies: [],
		};
		setSmartCharacter(smartCharacter);
	}, [walletClient.account?.address]);

	return (
		<>
    </>
	);
};
