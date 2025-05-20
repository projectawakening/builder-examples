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
    txHash = await worldContract.write.exampleName__setTrue([smartObjectId]);
  } else {
    txHash = await worldContract.write.exampleName__setFalse([smartObjectId]);
  }

  return txHash;
};

export default setToggle;
