const setAllowedCorp = async ({
  worldContract,
  smartObjectId,
  corpID,
}: {
  worldContract: any;
  smartObjectId: string;
  corpID?: number;
}): Promise<string | undefined> => {
  let txHash;
  txHash = await worldContract.write.example__setAllowedCorp([smartObjectId, corpID]);

  return txHash;
};

export default setAllowedCorp;
