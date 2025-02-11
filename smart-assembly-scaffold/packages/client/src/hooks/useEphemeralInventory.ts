import { useRecord } from "../mud/useRecord";
import { useRecords } from "../mud/useRecords";

import { stash } from "../mud/stash";
import worldMudConfig from "contracts/eveworld/mud.config";
import {
  SmartAssemblies,
  SmartAssembly,
  SmartAssemblyType,
  State,
} from "@eveworld/types";
import { useEffect, useState } from "react";
import { getWorldDeploy } from "../mud/getWorldDeploy";
import { mapApiResult } from "../utils/mapApiResult";
import { getAddress } from "viem";

/**
 * `useEphemeralInventory` hook
 *
 * This hook is designed to fetch and construct a `SmartAssembly` object based on a given `smartObjectId`.
 * The hook retrieves various properties of the assembly by querying multiple MUD tables, such as:
 * - Basic information (state, type, fuel, location).
 * - Ownership details (owner ID and name).
 * - Assembly-specific details (Smart Storage Unit, Smart Turret, Smart Gate).
 *
 * The resulting `smartAssembly` object is tailored based on the assembly type.
 *
 * @returns {Object} `smartAssembly` - The constructed SmartAssembly object, or `undefined` if the data is incomplete.
 */

type ephemeralInventoryRecord = {
  ephemeralInvOwner: string;
  items: BigInt[];
  smartObjectId: BigInt;
  usedCapacity: BigInt;
}

export function useEphemeralInventory() {
  // Retrieve the Smart Assembly ID from environment variables
  const smartObjectId = BigInt(import.meta.env.VITE_SMARTASSEMBLY_ID);

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