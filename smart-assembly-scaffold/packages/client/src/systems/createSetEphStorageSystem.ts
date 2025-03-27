import { setRecord } from "@latticexyz/stash/internal";
import { stash, localWorld } from "../mud/stash";

interface EphemeralInv {
  ephemeralInvOwner: string;
  items: bigint[];
  smartObjectId: bigint;
  usedCapacity: bigint;
}

interface EphInvItem {
  ephemeralInvOwner: string;
  index: bigint;
  inventoryItemId: bigint;
  quantity: bigint;
  smartObjectId: bigint;
  stateUpdate: bigint;
}

/**
 * The Ephemeral StorageSystem handles ephemeral inventories
 * based on values in parent tables
 */
export function createSetEphStorageSystem(
  smartObjectId: bigint,
  ephemeralInventoryList: any,
  ephInvItemTable: any
) {
  // Get all player eph inventories for a given smart storage unit
  const playerEphInventories = ephemeralInventoryList.filter(
    (x) => x.smartObjectId == smartObjectId
  );
  // For the given smart storage unit, iterate through items
  // to populate with inventory quantities
  // Then sets a record for a local table with the defined values

  for (let i = 0; i < playerEphInventories.length; i++) {
    const itemArray = [];
    const quantityArray = [];

    for (let j = 0; j < playerEphInventories[i].items.length; j++) {
      /** Get corresponding quantities for each item */
      const inventoryItem: EphInvItem = ephInvItemTable.find(
        (ephItem: EphInvItem) =>
          ephItem.inventoryItemId == playerEphInventories[i].items[j] &&
          ephItem.smartObjectId == smartObjectId
      );
      itemArray.push(inventoryItem.inventoryItemId);
      quantityArray.push(inventoryItem.quantity);
    }

    // Items and quantity are set in an array
    // The lengths of both must strictly match
    // itemArray[0] has quantity at quantityArray[0] etc
    if (itemArray.length == quantityArray.length) {
      setRecord({
        stash,
        table: localWorld.namespaces.storage.tables.EphemeralStorage,
        key: {
          smartObjectId,
          ephemeralInvOwner: playerEphInventories[i].ephemeralInvOwner,
        },
        value: {
          smartObjectId,
          ephemeralInvOwner: playerEphInventories[i].ephemeralInvOwner,
          usedCapacity: 2n,
          items: itemArray,
          quantity: quantityArray,
        },
      });
    }
  }
  return;
}
