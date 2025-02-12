const calculateOutput = async ({
  worldContract,
  inputAmount,
  itemID
}: {
  worldContract: any;
  inputAmount: number;
  itemID: string;
}): Promise<string | undefined> => {
  let txHash;

  let ssuID = import.meta.env.VITE_SMARTASSEMBLY_ID;
  txHash = await worldContract.read.example__readOutput([inputAmount, ssuID, itemID]);

  return txHash;
};

export default calculateOutput;