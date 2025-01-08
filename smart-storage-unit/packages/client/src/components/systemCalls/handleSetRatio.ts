const setRatio = async ({
  worldContract,
  inputRatio,
  outputRatio
}: {
  worldContract: any;
  inputRatio: number;
  outputRatio: number;
}): Promise<string | undefined> => {
  let txHash;

  let ssuID = import.meta.env.VITE_SMARTASSEMBLY_ID;
  let itemID = "72303041834441799565597028082148290553073890313361053989246429514519533100781";
  let itemIDOut = "112603025077760770783264636189502217226733230421932850697496331082050661822826";
  
  txHash = await worldContract.write.example__setRatio([ssuID, itemID, itemIDOut, inputRatio, outputRatio]);
  
  return txHash;
};

export default setRatio;
