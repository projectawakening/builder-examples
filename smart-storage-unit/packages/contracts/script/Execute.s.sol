// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { EphemeralInvItemTableData, EphemeralInvItemTable } from "@eveworld/world/src/codegen/tables/EphemeralInvItemTable.sol";
import { InventoryItemTableData, InventoryItemTable } from "@eveworld/world/src/codegen/tables/InventoryItemTable.sol";
import { Utils as InventoryUtils } from "@eveworld/world/src/modules/inventory/Utils.sol";
import { FRONTIER_WORLD_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";

import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { SmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";

contract Execute is Script {
  using InventoryUtils for bytes14;  

  //Player
  uint256 playerPrivateKey;
  address player;

  //SSU ID
  uint256 smartStorageUnitId;

  //Items
  uint256 itemIn; 
  uint256 itemOut;

  //Testing
  uint64 testQuantityIn;

  function displayInventory() public {    
    InventoryItemTableData memory invItem = InventoryItemTable.get(smartStorageUnitId, itemOut);
    console.log("[INVENTORY] Owner's Inventory [Item Out]: ", invItem.quantity);

    EphemeralInvItemTableData memory ephInvItem = EphemeralInvItemTable.get(smartStorageUnitId, itemIn, player);
    console.log("[EPHEMERAL] Other Player's Inventory [Item In]: ", ephInvItem.quantity);
  }

  function run(address worldAddress) external {
    playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    player = vm.addr(playerPrivateKey);

    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    //Read from .env
    smartStorageUnitId = vm.envUint("SSU_ID");
    itemIn = vm.envUint("ITEM_IN_ID");
    itemOut = vm.envUint("ITEM_OUT_ID");
    testQuantityIn = uint64(vm.envUint("EXECUTE_QUANTITY"));

    ResourceId systemId = Utils.smartStorageUnitSystemId();

    //Check Players ephemeral inventory before
    console.log("Inventories Before");
    displayInventory();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(systemId, abi.encodeCall(SmartStorageUnitSystem.execute, (smartStorageUnitId, testQuantityIn, itemIn)));

    //Check Players ephemeral inventory after
    console.log("\nInventories After");
    displayInventory();

    vm.stopBroadcast();
  }
}
