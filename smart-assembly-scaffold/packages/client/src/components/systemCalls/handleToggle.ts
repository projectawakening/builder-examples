import { parseGwei } from "viem";

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

  if (!worldContract) {
    throw new Error(
      "World contract not available. Please wait for connection."
    );
  }

  try {
    // Estimate gas for the transaction to avoid failures
    const gasEstimate = !currentValue
      ? await worldContract.estimateGas.exampleName__setTrue([smartObjectId])
      : await worldContract.estimateGas.exampleName__setFalse([smartObjectId]);

    // Add 20% buffer to gas estimate for safety
    const gasLimit = (gasEstimate * 120n) / 100n;

    // Transaction options with proper gas configuration
    const txOptions = {
      gas: gasLimit,
      gasPrice: parseGwei("20"),
    };

    if (!currentValue) {
      tx = await worldContract.write.exampleName__setTrue(
        [smartObjectId],
        txOptions
      );
    } else {
      tx = await worldContract.write.exampleName__setFalse(
        [smartObjectId],
        txOptions
      );
    }

    // MUD sync happens in background (no waiting)
    sync.data.waitForTransaction(tx).catch(() => console.warn("Sync delayed"));
  } catch (error: any) {
    console.error("Transaction failed:", error);

    // Handle specific error types
    if (error.message?.includes("timeout")) {
      throw new Error("Transaction timed out. Please try again.");
    } else if (error.message?.includes("rejected")) {
      throw new Error("Transaction was rejected by user.");
    } else if (error.message?.includes("insufficient funds")) {
      throw new Error("Insufficient funds for gas.");
    } else if (error.message?.includes("reverted")) {
      throw new Error("Transaction reverted. Check contract conditions.");
    } else {
      throw error;
    }
  }

  return tx;
};

export default setToggle;
