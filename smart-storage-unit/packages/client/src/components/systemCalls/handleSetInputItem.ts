import SSUConfigData from "../dataTypes";

const setInputItem = async ({
  worldContract,
  currentConfig,
  inputItem
}: {
  worldContract: any;
  currentConfig: SSUConfigData;
  inputItem: string;
}): Promise<string | undefined> => {
  let txHash;

  txHash = await worldContract.write.example__setPromotedItemAndRatio([currentConfig.smartObjectId, inputItem, currentConfig.itemOut, currentConfig.ratioIn, currentConfig.ratioOut]);

  return txHash;
};

export default setInputItem;
