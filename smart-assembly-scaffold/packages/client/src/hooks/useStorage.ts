import { useRecord, useRecords } from "@latticexyz/stash/react";
import { stash, localWorld } from "../mud/stash";
import { useSmartAssembly } from "./useSmartAssembly";

export function useStorage() {
  const { smartAssembly } = useSmartAssembly();

  const smartStorageUnitInv = useRecord({
    stash,
    table: localWorld.namespaces.storage.tables.OwnerStorage,
    key: {
      smartObjectId: smartAssembly?.id || 0,
    },
  });

  const allEphemeralInv = useRecords({
    stash,
    table: localWorld.namespaces.storage.tables.EphemeralStorage,
  });
  return {
    smartStorageUnitInv,
    ssuEphemeralInv: allEphemeralInv.filter(
      (x) => x.smartObjectId == smartAssembly?.id
    ),
  };
}
