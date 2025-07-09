// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { Inventory, InventoryData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/Inventory.sol";
import { EntityRecord, EntityRecordData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EntityRecord.sol";

contract Read is Script {
  function run(address worldAddress) external {
    StoreSwitch.setStoreAddress(worldAddress);

    uint256 ssuId = vm.envUint("SSU_ID");

    InventoryData memory inventory = Inventory.get(ssuId);

    uint256 inventoryItemSmartObjectId = inventory.items[0];

    EntityRecordData memory itemData = EntityRecord.get(inventoryItemSmartObjectId);

    console.log("Item Type ID:", vm.toString(itemData.typeId));
    console.log("Item Volume:", vm.toString(itemData.volume));
  }
}
