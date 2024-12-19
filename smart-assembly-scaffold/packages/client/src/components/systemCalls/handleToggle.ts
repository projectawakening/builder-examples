const setToggle = async ({
  worldContract,
  currentValue,
}: {
  worldContract: any;
  currentValue?: boolean;
}): Promise<string | undefined> => {
  let txHash;

  if (!currentValue) {
    txHash = await worldContract.write.example__setTrue([
      import.meta.env.VITE_SMARTASSEMBLY_ID,
    ]);
  } else {
    txHash = await worldContract.write.example__setFalse([
      import.meta.env.VITE_SMARTASSEMBLY_ID,
    ]);
  }

  return txHash;
};

export default setToggle;
