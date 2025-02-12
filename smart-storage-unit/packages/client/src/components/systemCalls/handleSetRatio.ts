const setRatio = async ({
  worldContract,
  inputRatio,
  outputRatio,
  itemIDIn,
  itemIDOut
}: {
  worldContract: any;
  inputRatio: number;
  outputRatio: number;
  itemIDIn: string;
  itemIDOut: string;
}): Promise<string | undefined> => {
  let txHash;

  let ssuID = import.meta.env.VITE_SMARTASSEMBLY_ID;
  txHash = await worldContract.write.example__setRatio([ssuID, itemIDIn, itemIDOut, inputRatio, outputRatio]);
  
  return txHash;
};

export default setRatio;