// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { EphemeralInvItem, EphemeralInvItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EphemeralInvItem.sol";
import { InventoryItem, InventoryItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/InventoryItem.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { Tenant } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";

/**
 * @title Read
 * @notice This script is a example of how to read items from a SSU in a script
 */
contract Read is Script {
  function run(address worldAddress) external {
    StoreSwitch.setStoreAddress(worldAddress);
    bytes32 tenantId = Tenant.getTenantId();

    // Get SSU ID
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");

    // Get Player Address
    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    console.log("SSU ID:", vm.toString(smartStorageUnitId));

    // Get Item IDs
    uint256 itemIn = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_TYPE_ID");
    uint256 itemInSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemIn);
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemOut);

    // Get Player's Ephemeral Inventory
    EphemeralInvItemData memory ephInvInItem = EphemeralInvItem.get(smartStorageUnitId, player, itemInSmartObjectId);
    console.log("[EPHEMERAL] Player's Ephemeral Inventory [Item In]: ", vm.toString(ephInvInItem.quantity));

    EphemeralInvItemData memory ephInvOutItem = EphemeralInvItem.get(smartStorageUnitId, player, itemOutSmartObjectId);
    console.log("[EPHEMERAL] Player's Ephemeral Inventory [Item Out]: ", vm.toString(ephInvOutItem.quantity));

    // Get Owner's Inventory
    InventoryItemData memory invItemOut = InventoryItem.get(smartStorageUnitId, itemOutSmartObjectId);
    console.log("[INVENTORY] Admins Inventory [Item Out]: ", vm.toString(invItemOut.quantity));

    InventoryItemData memory invItemIn = InventoryItem.get(smartStorageUnitId, itemInSmartObjectId);
    console.log("[INVENTORY] Admins Inventory [Item In]: ", vm.toString(invItemIn.quantity));
  }
}
