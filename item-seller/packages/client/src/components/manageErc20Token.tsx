import { useComponentValue } from "@latticexyz/react";
import { useMUD } from "../MUDContext";
import { singletonEntity } from "@latticexyz/store-sync/recs";
import React, { useRef } from "react";
import { EveButton, TextEdit } from "@eveworld/ui-components";

const ManageErc20Token = React.memo(function ManageErc20Token({
	smartAssemblyId,
}: {
	smartAssemblyId: bigint;
}) {

	const {
		network: { walletClient },
		components: { ItemSellerERC20 },
		systemCalls: { registerERC20Token, updateERC20Receiver, getERC20Data },
	} = useMUD();

	const erc20Data = useComponentValue(ItemSellerERC20, singletonEntity);
	const erc20TokenAddressValueRef = useRef((erc20Data?.tokenAddress as string) ?? "");
	const erc20TokenReceiverValueRef = useRef((erc20Data?.receiver as string) ?? "");

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
						const erc20TokenData = await getERC20Data(smartAssemblyId)
						if (erc20TokenData) {
							erc20TokenAddressValueRef.current = erc20TokenData.tokenAddress
						}
					}}
				>
					Fetch
				</EveButton>{" "}
				<span className="text-xs">{erc20TokenAddressValueRef.current ? erc20TokenAddressValueRef.current : "No token data set"}</span>
			</div>

			<TextEdit
				isMultiline={false}
				defaultValue={erc20Data?.tokenAddress as string}
				fieldType={"ERC20 token"}
				onChange={(str) => handleEdit(erc20TokenAddressValueRef, str)}
			/>
			<EveButton
				typeClass="secondary"
				onClick={async (event) => {
					event.preventDefault();
					console.log(
						"new erc20 token:",
						await registerERC20Token(
							smartAssemblyId,
							erc20TokenAddressValueRef.current,
							walletClient.account?.address
						)
					);
				}}
			>
				Set ERC-20 Token
			</EveButton>

			<div className="mt-6">STEP 1.1: Update token receiver</div>
			<TextEdit
				isMultiline={false}
				defaultValue={undefined}
				fieldType={"Token receiver"}
				onChange={(str) => handleEdit(erc20TokenReceiverValueRef, str)}
			/>
			<EveButton
				typeClass="tertiary"
				onClick={async (event) => {
					event.preventDefault();
					console.log(
						"token receiver:",
						await updateERC20Receiver(
							smartAssemblyId,
							erc20TokenReceiverValueRef.current
						)
					);
				}}
			>
				Update ERC-20 Token Receiver
			</EveButton>
		</div>
	);
});

export default ManageErc20Token;
