import SSUConfigData from "../dataTypes";

const execute = async ({
  worldContract,
  currentConfig,
  quantity
}: {
  worldContract: any;
  currentConfig: SSUConfigData;
  quantity: number;
}): Promise<string | undefined> => {
  let txHash;

  txHash = await worldContract.write.example__execute([currentConfig.smartObjectId.toString(), quantity, currentConfig.itemIn.toString()]);

  return txHash;
};

export default execute;