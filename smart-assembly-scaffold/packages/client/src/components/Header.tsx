import { ReactNode, useEffect, useState } from "react";
import { formatEther } from "viem";

import {
	Identicon1,
	Identicon2,
	Identicon3,
	Identicon4,
	Identicon5,
	Identicon6,
	Identicon7,
	Identicon8,
	Identicon9,
	Identicon10,
	Identicon11,
	Identicon12,
	Identicon13,
	Identicon14,
	Identicon15,
	Identicon16,
} from "@eveworld/ui-components/assets";

import { ReactComponent as Allegrite } from "../assets/allegrite_logo.svg";
import { ReactComponent as Eve } from "../assets/eve.svg";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useSmartObject } from "@eveworld/contexts";

export default function Header() {
	const [identicon, setIdenticon] = useState<number>(1);

	const {smartCharacter} = useSmartObject()

	useEffect(() => {
		// If wallet has been previously connected
		const identiconNumber = localStorage.getItem("eve-allegrite-identicon");
		if (identiconNumber) {
			setIdenticon(Number(identiconNumber));
		} else {
			const randomNumber = Math.floor(Math.random() * 16) + 1;
			localStorage.setItem("eve-allegrite-identicon", randomNumber.toString());
			setIdenticon(randomNumber);
		}
	}, []);

	const identiconMap: Record<number, ReactNode> = {
		1: <Identicon1 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		2: <Identicon2 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		3: <Identicon3 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		4: <Identicon4 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		5: <Identicon5 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		6: <Identicon6 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		7: <Identicon7 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		8: <Identicon8 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		9: <Identicon9 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		10: <Identicon10 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		11: <Identicon11 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		12: <Identicon12 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		13: <Identicon13 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		14: <Identicon14 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		15: <Identicon15 className="w-[30px] h-[30px] mobile:h-[22px]" />,
		16: <Identicon16 className="w-[30px] h-[30px] mobile:h-[22px]" />,
	};

	// Read balance of wallet's EVE
	const eveBalanceWei = BigInt(smartCharacter?.eveBalanceWei ?? 0);

	return (
		<header
			className="flex justify-between items-center p-10 mobile:mt-20"
			id="header"
		>
			<div className="w-8 h-14">
				<Allegrite />
			</div>
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
							className="justify-start items-start flex"
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
									<div className="flex">
										<div className="w-10 mobile:w-8 h-full !p-[5.25px]">
											{identiconMap[identicon]}
										</div>
										<button onClick={openAccountModal} type="button">
											{smartCharacter?.name
												? smartCharacter?.name
												: account.displayName}
										</button>

										<button className="mobile:!hidden">
											{formatEther(eveBalanceWei)} EVE
										</button>

										<button
											onClick={openChainModal}
											style={{ display: "flex", alignItems: "center" }}
											type="button"
										>
											<Eve />
											{chain.name}
										</button>
									</div>
								);
							})()}
						</div>
					);
				}}
			</ConnectButton.Custom>
		</header>
	);
}
