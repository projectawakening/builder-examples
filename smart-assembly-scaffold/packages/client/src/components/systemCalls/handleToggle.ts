const setToggle = async ({
  worldContract,
  smartObjectId,
  currentValue,
  sync,
}: {
  worldContract: any;
  smartObjectId: string;
  currentValue?: boolean;
  sync: any;
}): Promise<string | undefined> => {
  let tx;

  console.log("SMART OBJECT ID", smartObjectId);
  console.log("CURRENT VALUE", currentValue);
  console.log("SYNC", sync);
  console.log("WORLD CONTRACT", worldContract);

  if (!currentValue) {
    tx = await worldContract.write.exampleName__setTrue([smartObjectId]);
    await sync.data.waitForTransaction(tx);
  } else {
    tx = await worldContract.write.exampleName__setFalse([smartObjectId]);
    await sync.data.waitForTransaction(tx);
  }

  return tx;
};

export default setToggle;
