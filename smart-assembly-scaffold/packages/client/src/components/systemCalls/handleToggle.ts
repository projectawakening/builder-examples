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
    txHash = await worldContract.write.eveworld__bringOnline([smartObjectId]);
  } else {
    console.log("OFFLINE")
    txHash = await worldContract.write.eveworld__bringOffline([smartObjectId]);
  }

  return txHash;
};

export default setToggle;
