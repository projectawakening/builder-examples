import { useRecord } from "../mud/useRecord";
import { useRecords } from "../mud/useRecords";

import { stash } from "../mud/stash";
import worldMudConfig from "contracts/eveworld/mud.config";

/**
 * `useEphemeralInventory` hook
 *
 * This hook is designed to fetch the ephemeral inventories of a smart assembly from MUD tables based on a given `smartObjectId`.
 *
 * @returns {Object} `ephemeralInventories` - The ephemeral inventories of the smart assembly.
 */

type ephemeralInventoryRecord = {
  ephemeralInvOwner: string;
  items: BigInt[];
  usedCapacity: BigInt;
}

export function useEphemeralInventory(smartObjectId = 0n) {
  if(smartObjectId == 0n){
    // Retrieve the Smart Assembly ID from environment variables
    smartObjectId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);
  }

  const ephemeralInventoryRecords = useRecords({
    stash,
    table: worldMudConfig.namespaces.eveworld.tables.EphemeralInvTable
  });  

  const ephemeralInventories = ephemeralInventoryRecords?.map((record: ephemeralInventoryRecord) => {
    const items = record.items.map((itemID: BigInt) => {      
      let itemRecord = useRecord({
        stash,
        table: worldMudConfig.namespaces.eveworld.tables.EphemeralInvItemTable,
        key: {
          "smartObjectId": smartObjectId,
          "inventoryItemId": itemID,
          "ephemeralInvOwner": record.ephemeralInvOwner
        }
      });  

      if(itemRecord == null) return null;

      return {
        "typeID": itemID,
        "smartObjectId": itemRecord.smartObjectId,
        "quantity": itemRecord.quantity,
        "lastUpdated": itemRecord.stateUpdate
      }
    }).filter(Boolean)

    if(items == null) return null;

    return {
      "ephemeralInvOwner": record.ephemeralInvOwner,
      "items": items,
      "usedCapacity": record.usedCapacity
    }
  })

  return { ephemeralInventories };
}