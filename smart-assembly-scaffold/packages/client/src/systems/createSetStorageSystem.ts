import { setRecord } from "@latticexyz/stash/internal";
import { stash, localWorld } from "../mud/stash";

interface SmartStorageUnitInv {
  smartObjectId: bigint;
  capacity: bigint;
  usedCapacity: bigint;
  items: bigint[];
}

interface InvItem {
  index: bigint;
  inventoryItemId: bigint;
  quantity: bigint;
  smartObjectId: bigint;
  stateUpdate: bigint;
}

/**
 * The Storage system handles storage based on values in smartStorageUnitInv and InventoryItemTable
 */
export function createSetStorageSystem(
  smartStorageUnitInv: any,
  invItemTable: any
) {
  const { smartObjectId, items } = smartStorageUnitInv as SmartStorageUnitInv;

  // Conditionally listens for changes in the specified snart storage unit
  // Then sets a record for a local table with the defined values

  const itemArray: bigint[] = [];
  const quantityArray: bigint[] = [];

  for (let i = 0; i < items.length; i++) {
    /* For each inventory item, search InventoryItemTable
    to find the quantity of each item at the respec   tive smart object Id
    */
    const inventoryItem = invItemTable.find(
      (invItem: InvItem) =>
        invItem.smartObjectId == smartObjectId &&
        invItem.inventoryItemId == items[i]
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
      table: localWorld.namespaces.storage.tables.OwnerStorage,
      key: {
        smartObjectId,
      },
      value: {
        smartObjectId,
        typeIds: [2468n], // TODO: Get correct typeIds
        inventoryItemIds: itemArray,
        quantities: quantityArray,
      },
    });
  }

  return;
}
