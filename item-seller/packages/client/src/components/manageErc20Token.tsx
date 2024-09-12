import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "../MUDContext";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import React, { useEffect, useRef, useState } from "react";
import { EveButton, TextEdit } from "@eveworld/ui-components";

const ManageErc20Token = React.memo(function ManageErc20Token({
	smartAssemblyId,
}: {
	smartAssemblyId: bigint;
}) {
	const [erc20TokenAddress, setErc20TokenAddress] = useState<
		string | undefined
	>();
	const [erc20Receiver, setErc20Receiver] = useState<string | undefined>();

	const {
		network: { walletClient },
		systemCalls: { registerERC20Token, updateERC20Receiver, getERC20Data },
	} = useMUD();

	const fetchErc20Data = async () => {
		const erc20TokenData = await getERC20Data(smartAssemblyId);
		setErc20TokenAddress(erc20TokenData?.tokenAddress as string);
		setErc20Receiver(erc20TokenData?.receiver as string);
	};

	const erc20TokenAddressValueRef = useRef("");
	const erc20ReceiverValueRef = useRef("");

	const handleEdit = (
		refString: React.MutableRefObject<string>,
		eventString: string
	): void => {
		refString.current = eventString;
	};

	return (
		<div className="Quantum-Container my-4">
			<div>STEP 1: Register ERC20 Token</div>
			<div className="flex items-center">
				<EveButton
					className="mr-2"
					typeClass="tertiary"
					onClick={async (event) => {
						event.preventDefault();
						fetchErc20Data();
					}}
				>
					Fetch
				</EveButton>{" "}
				<div className="flex flex-col">
					<span className="text-xs">
						Token contract address: {erc20TokenAddress ?? "No token data set"}
					</span>
					<span className="text-xs">
						Receiver address: {erc20Receiver ?? "No token data set"}
					</span>
				</div>
			</div>

			<TextEdit
				isMultiline={false}
				defaultValue={erc20TokenAddress}
				fieldType={"ERC20 token"}
				onChange={(str) => handleEdit(erc20TokenAddressValueRef, str)}
			/>
			<EveButton
				typeClass="secondary"
				onClick={async (event) => {
					event.preventDefault();
					await registerERC20Token(
						smartAssemblyId,
						erc20TokenAddressValueRef.current,
						walletClient.account?.address
					);
					fetchErc20Data();
				}}
			>
				Set ERC-20 Token
			</EveButton>

			<div className="mt-6">STEP 1.1: Update token receiver</div>
			<TextEdit
				isMultiline={false}
				defaultValue={erc20Receiver}
				fieldType={"Token receiver"}
				onChange={(str) => handleEdit(erc20ReceiverValueRef, str)}
			/>
			<EveButton
				typeClass="tertiary"
				onClick={async (event) => {
					event.preventDefault();
					const erc20Receiver = await updateERC20Receiver(
						smartAssemblyId,
						erc20ReceiverValueRef.current
					);
					if (erc20Receiver) {
						console.log("receiver", erc20Receiver);
					}
				}}
			>
				Update ERC-20 Token Receiver
			</EveButton>
		</div>
	);
});

export default ManageErc20Token;
