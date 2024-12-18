import React, { ReactNode, useEffect, useState } from "react";
import {
	Identicon1,
	Identicon10,
	Identicon11,
	Identicon12,
	Identicon13,
	Identicon14,
	Identicon15,
	Identicon16,
	Identicon2,
	Identicon3,
	Identicon4,
	Identicon5,
	Identicon6,
	Identicon7,
	Identicon8,
	Identicon9,
} from "@eveworld/ui-components/assets";

import { SmartCharacter } from "@eveworld/types";

import { ConnectButton } from "@rainbow-me/rainbowkit";

const Header = React.memo(function Header
	({
		smartCharacter,
	}: {
		smartCharacter: SmartCharacter;
	}) {
	const [identicon, setIdenticon] = useState<number>(1);

	useEffect(() => {
		// If wallet has been previously connected
		const identiconNumber = localStorage.getItem("eve-dapp-identicon");
		if (identiconNumber) {
			setIdenticon(Number(identiconNumber));
		} else {
			const randomNumber = Math.floor(Math.random() * 16) + 1;
			localStorage.setItem("eve-dapp-identicon", randomNumber.toString());
			setIdenticon(randomNumber);
		}
	}, []);

	// useEffect(() => {
	//   const assertChain = async () => {
	//     if (!walletClient?.chain) return;
	//     const currentChainId = await walletClient.getChainId();
	//     const targetChainId = walletClient.chain.id;

	//     if (currentChainId !== targetChainId) {
	//       await walletClient.addChain({ chain: walletClient.chain });
	//       await walletClient.switchChain({ id: walletClient.chain.id });
	//     }
	//   };

	//   if (!isCurrentChain) assertChain();
	// }, [connected, isCurrentChain]);

	const identiconStyles = "w-[30px] h-[30px] text-brightquantum";

	const identiconMap: Record<number, ReactNode> = {
		1: <Identicon1 className={identiconStyles} />,
		2: <Identicon2 className={identiconStyles} />,
		3: <Identicon3 className={identiconStyles} />,
		4: <Identicon4 className={identiconStyles} />,
		5: <Identicon5 className={identiconStyles} />,
		6: <Identicon6 className={identiconStyles} />,
		7: <Identicon7 className={identiconStyles} />,
		8: <Identicon8 className={identiconStyles} />,
		9: <Identicon9 className={identiconStyles} />,
		10: <Identicon10 className={identiconStyles} />,
		11: <Identicon11 className={identiconStyles} />,
		12: <Identicon12 className={identiconStyles} />,
		13: <Identicon13 className={identiconStyles} />,
		14: <Identicon14 className={identiconStyles} />,
		15: <Identicon15 className={identiconStyles} />,
		16: <Identicon16 className={identiconStyles} />,
	};

	// const renderMessage = (): string => {
	//   // If wallet client does not match provider network, render switch network message and request to switch networks
	//   if (!isCurrentChain) {
	//     return "Switch Network";
	//   } else if (walletClient?.chain?.name) {
	//     return walletClient?.chain?.name;
	//   } else {
	//     return "Chain connection not detected";
	//   }
	// };

	return (
		<header className="flex w-full items-center py-6" id="header">
			<div className="w-8 h-full !p-0">{identiconMap[identicon]}</div>
			{/* <div className="grow"> */}
			{/* <span c¸Click={handleDisconnect} id="char-name-addr"> */}
			<ConnectButton.Custom>
				{({
					account,
					chain,
					openAccountModal,
					openChainModal,
					mounted,
				}) => {
					const connected = mounted && account && chain;

					return (
						<div
							{...(!mounted && {
								"aria-hidden": true,
								style: {
									opacity: 0,
									pointerEvents: "none",
									userSelect: "none",
								},
							})}
							id="rainbowkit"
							className="grow justify-start items-start flex"
						>
							{(() => {
								if (!connected) return;

								if (chain.unsupported) {
									return (
										<button onClick={openChainModal} type="button">
											Wrong network
										</button>
									);
								}

								return (
									<>
										<div onClick={openAccountModal}>
											{smartCharacter?.name
												? smartCharacter?.name
												: account.displayName}
										</div>

										<div
											onClick={openChainModal}
											style={{ display: "flex", alignItems: "center" }}
										>
											{chain.name}
										</div>
									</>
								);
							})()}
						</div>
					);
				}}
			</ConnectButton.Custom>

			{/* </div> */}
			{/* <div id="chain-info">{renderMessage()}</div> */}
		</header>
	);
},
);

export default React.memo(Header);
