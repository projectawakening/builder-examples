// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";

import { InventoryItem, InventoryItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/InventoryItem.sol";
import { EphemeralInvItem, EphemeralInvItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EphemeralInvItem.sol";
import { Tenant } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";

import { SmartStorageUnitSystem, smartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { Utils } from "../src/systems/Utils.sol";

/**
 * @title Execute
 * @notice This script is used to execute the trade for the custom SSU contract in systems/SmartStorageUnitSystem.sol
 */
contract Execute is Script {
  address admin;
  address player;

  uint256 SSU_TYPE_ID = 77917;
  uint256 ssuItemId = 565656565;

  uint256 smartStorageUnitId;

  IWorldWithContext world;
  function run(address worldAddress) external {
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(adminPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    player = vm.addr(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    world = IWorldWithContext(worldAddress);

    bytes32 tenantId = Tenant.getTenantId();

    smartStorageUnitId = vm.envUint("SSU_ID");

    vm.startBroadcast(adminPrivateKey);

    _execute(tenantId, smartStorageUnitId, player);

    vm.stopBroadcast();
  }

  function _execute(bytes32 tenantId, uint256 smartStorageUnitId, address player) private {
    uint256 itemIn = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_TYPE_ID");
    uint64 testQuantityIn = uint64(vm.envUint("EXECUTE_QUANTITY"));

    uint256 itemInSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemIn);
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateSingletonId(tenantId, itemOut);

    console.log("BEFORE EXECUTE -----");
    _consoleLogInventories(itemInSmartObjectId, itemOutSmartObjectId);

    ResourceId systemId = Utils.smartStorageUnitSystemId();

    world.callFrom(
      player,
      systemId,
      abi.encodeCall(SmartStorageUnitSystem.execute, (smartStorageUnitId, testQuantityIn, itemInSmartObjectId))
    );

    console.log("AFTER EXECUTE -----");
    _consoleLogInventories(itemInSmartObjectId, itemOutSmartObjectId);
  }

  function _consoleLogInventories(uint256 itemInSmartObjectId, uint256 itemOutSmartObjectId) view internal {
    EphemeralInvItemData memory ephInvInItem = EphemeralInvItem.get(smartStorageUnitId, player, itemInSmartObjectId);
    console.log("[EPHEMERAL] Player's Ephemeral Inventory [Item In]: ", vm.toString(ephInvInItem.quantity));

    EphemeralInvItemData memory ephInvOutItem = EphemeralInvItem.get(smartStorageUnitId, player, itemOutSmartObjectId);
    console.log("[EPHEMERAL] Player's Ephemeral Inventory [Item Out]: ", vm.toString(ephInvOutItem.quantity));

    InventoryItemData memory invItemOut = InventoryItem.get(smartStorageUnitId, itemOutSmartObjectId);
    console.log("[INVENTORY] Admins Inventory [Item Out]: ", vm.toString(invItemOut.quantity));

    InventoryItemData memory invItemIn = InventoryItem.get(smartStorageUnitId, itemInSmartObjectId);
    console.log("[INVENTORY] Admins Inventory [Item In]: ", vm.toString(invItemIn.quantity));
  }
}