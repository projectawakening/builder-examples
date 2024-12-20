const setToggle = async ({
	worldContract,
	smartObjectId,
	currentValue,
}: {
	worldContract: any;
	smartObjectId: string;
	currentValue?: boolean;
}): Promise<string | undefined> => {
	let txHash;

	if (!currentValue) {
		txHash = await worldContract.write.example__setTrue([smartObjectId]);
	} else {
		txHash = await worldContract.write.example__setFalse([smartObjectId]);
	}

	return txHash;
};

export default setToggle;
