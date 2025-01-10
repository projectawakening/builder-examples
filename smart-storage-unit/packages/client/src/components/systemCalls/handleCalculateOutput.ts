const calculateOutput = async ({
  worldContract,
  smartObjectId,
  inputAmount,
}: {
  worldContract: any;
  smartObjectId: string;
  inputAmount: number;
}): Promise<string | undefined> => {
  let txHash;

  let ssuID = import.meta.env.VITE_SMARTASSEMBLY_ID;
  let itemID = "72303041834441799565597028082148290553073890313361053989246429514519533100781";

  txHash = await worldContract.read.example2__readOutput([inputAmount, ssuID, itemID]);

  return txHash;
};

export default calculateOutput;
