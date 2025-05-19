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
    console.log("Setting true");
    txHash = await worldContract.write.exampleName__setTrue([smartObjectId]);
  } else {
    console.log("Setting false");
    txHash = await worldContract.write.exampleName__setFalse([smartObjectId]);
  }

  return txHash;
};

export default setToggle;
