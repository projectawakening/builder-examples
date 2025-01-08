import SSUConfigData from "../dataTypes";

const setOutputItem = async ({
  worldContract,
  currentConfig,
  outputItem
}: {
  worldContract: any;
  currentConfig: SSUConfigData;
  outputItem: string;
}): Promise<string | undefined> => {
  let txHash;

  txHash = await worldContract.write.example__setRatio([currentConfig.smartObjectId, currentConfig.itemIn, outputItem, currentConfig.ratioIn, currentConfig.ratioOut]);

  return txHash;
};

export default setOutputItem;
