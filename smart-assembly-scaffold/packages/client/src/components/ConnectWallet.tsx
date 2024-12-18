import { ConnectButton } from "@rainbow-me/rainbowkit";
import { ReactComponent as CornerBlock } from "../assets/corner-block.svg";
import Allegrite from "../assets/allegrite.webp";
import Footer from "./Footer";
import Header from "./Header";

const ConnectWallet = (): JSX.Element => {
	// const [isFrontierWallet, setIsFrontierWallet] = useState<boolean>(false);

	// const { handleConnect, availableWallets } = useConnection();
	// useEffect(() => {
	// 	if (availableWallets.includes(SupportedWallets.FRONTIER)) {
	// 		setIsFrontierWallet(true);
	// 	}
	// }, [availableWallets]);

	return (
		<div className="w-screen min-h-screen flex flex-col justify-between overflow-hidden">
			<Header />

			<div className="flex flex-col align-center min-w-screen mx-auto items-center relative">
				<img src={Allegrite} className="absolute -z-10" />
				<CornerBlock className="self-start tablet:hidden -mx-[300px]" />
				<div className="max-w-[630px] min-w-[353px] my-28 mx-auto flex-col justify-start items-start gap-4 inline-flex">
					<div className="self-stretch justify-between items-start inline-flex">
						<CornerBlock />
						<CornerBlock className="right-0 scale-x-flip" />
					</div>
					<div className="flex-col justify-start items-start flex">
						<div className="px-2 py-1 w-full bg-orange-100/10 justify-between items-center inline-flex">
							<div className="gap-2 flex text-header text-center text-opacity-50">
								<span className="text-orange-100/80 ">ALLEGRITE</span>
							</div>
							<div className="gap-2 flex">
								<div className="w-2.5 h-2.5 bg-orange-100/30"></div>
								<div className="w-2.5 h-2.5 bg-orange-100/30"></div>
							</div>
						</div>
						<div className="self-stretch flex-col justify-start items-start flex">
							<div className="self-stretch p-4 flex-col justify-start items-start gap-2 flex border border-orange-100/30">
								<div className="self-stretch px-10 pt-14 pb-10 bg-crude-50 border border-orange-100/30 flex-col justify-start items-start gap-10 flex">
									<div className="self-stretch flex-col justify-start items-start gap-4 flex">
										<div className="self-stretch text-center text-orange-100 text-[40px] font-semibold leading-[48px]">
											Welcome to Aperture
										</div>
										<div className="self-stretch text-center text-orange-100 text-lg font-normal leading-snug">
											Connect your Vault to access trading.
										</div>
									</div>

									<ConnectButton.Custom>
										{({
											account,
											chain,
											openAccountModal,
											openChainModal,
											openConnectModal,
											authenticationStatus,
											mounted,
										}) => {
											// Note: If your app doesn't use authentication, you
											// can remove all 'authenticationStatus' checks
											const ready =
												mounted && authenticationStatus !== "loading";
											const connected =
												ready &&
												account &&
												chain &&
												(!authenticationStatus ||
													authenticationStatus === "authenticated");

											return (
												<div
													{...(!ready && {
														"aria-hidden": true,
														style: {
															opacity: 0,
															pointerEvents: "none",
															userSelect: "none",
														},
													})}
													className="self-stretch h-[66px] justify-start items-center inline-flex relative"
												>
													{(() => {
														if (!connected) {
															return (
																<button
																	onClick={openConnectModal}
																	className="primary w-full uppercase"
																>
																	Connect
																</button>
															);
														}

														if (chain.unsupported) {
															return (
																<button onClick={openChainModal} type="button">
																	Wrong network
																</button>
															);
														}

														return (
															<div style={{ display: "flex", gap: 12 }}>
																<button
																	onClick={openChainModal}
																	style={{
																		display: "flex",
																		alignItems: "center",
																	}}
																	type="button"
																>
																	{chain.hasIcon && (
																		<div
																			style={{
																				background: chain.iconBackground,
																				width: 12,
																				height: 12,
																				borderRadius: 999,
																				overflow: "hidden",
																				marginRight: 4,
																			}}
																		>
																			{chain.iconUrl && (
																				<img
																					alt={chain.name ?? "Chain icon"}
																					src={chain.iconUrl}
																					style={{ width: 12, height: 12 }}
																				/>
																			)}
																		</div>
																	)}
																	{chain.name}
																</button>

																<button
																	onClick={openAccountModal}
																	type="button"
																>
																	{account.displayName}
																	{account.displayBalance
																		? ` (${account.displayBalance})`
																		: ""}
																</button>
															</div>
														);
													})()}
												</div>
											);
										}}
									</ConnectButton.Custom>
								</div>
							</div>
						</div>
					</div>

					<div className="self-stretch justify-between inline-flex">
						<CornerBlock className="right-0 scale-y-flip" />
						<CornerBlock className="left-0 rotate-180" />
					</div>
				</div>
				<CornerBlock className="-rotate-180 self-end tablet:hidden  -mx-[300px]" />
			</div>

			<div className="m-10 w-fit flex flex-col">
				<div className="relative my-2 w-fit">
					<button
						className="secondary"
						onClick={() =>
							window.open("https://docs.evefrontier.com/Dapp/quick-start")
						}
					>
						Documentation
					</button>
				</div>
				<div className="relative my-2 w-fit">
					<button
						className="secondary"
						onClick={() =>
							window.open("https://docs.evefrontier.com/EveVault/installation")
						}
					>
						Download Vault
					</button>
				</div>
			</div>

			<Footer />
		</div>
	);
};

export default ConnectWallet;
