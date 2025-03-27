import { useStorage } from "../hooks/useStorage";

export default function StorageView() {
  const { smartStorageUnitInv, ssuEphemeralInv } = useStorage();
  console.log("ssu owner inv", smartStorageUnitInv);
  console.log("ssu ephemeral inv", ssuEphemeralInv);

  return <div />;
}
