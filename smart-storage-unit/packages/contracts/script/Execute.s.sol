// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { SmartStorageUnitSystem, smartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { EphemeralInteractSystem, ephemeralInteractSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInteractSystemLib.sol";
import { OwnershipSystem, ownershipSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/OwnershipSystemLib.sol";

import { InventoryItem, InventoryItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/InventoryItem.sol";
import { EphemeralInvItem, EphemeralInvItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EphemeralInvItem.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { RatioConfigData } from "../src/codegen/tables/RatioConfig.sol";

import { InventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";

contract Execute is Script {
  //Player
  uint256 playerPrivateKey;
  address player;

  //Admin
  uint256 adminPrivateKey;
  address admin;

  //SSU ID
  uint256 smartStorageUnitId;

  //Items
  uint256 itemIn; 
  uint256 itemOut;

  //Testing
  uint64 testQuantityIn;

  function run(address worldAddress) external {
    adminPrivateKey = vm.envUint("PRIVATE_KEY");
    admin = vm.addr(adminPrivateKey);


    playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    player = vm.addr(playerPrivateKey);

    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    bytes32 tenantId = Tenant.getTenantId();

    //Read from .env
    smartStorageUnitId = vm.envUint("SSU_ID");
    itemIn = vm.envUint("ITEM_IN_TYPE_ID");
    itemOut = vm.envUint("ITEM_OUT_TYPE_ID");
    testQuantityIn = uint64(vm.envUint("EXECUTE_QUANTITY"));

    uint256 itemInSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, itemIn);
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, itemOut);

    EphemeralInvItemData memory ephInvItem = EphemeralInvItem.get(smartStorageUnitId, player, itemInSmartObjectId);
    console.log("[EPHEMERAL] Player's Ephemeral Inventory [Item In]: ", vm.toString(ephInvItem.quantity));

    InventoryItemData memory invItem = InventoryItem.get(smartStorageUnitId, itemOutSmartObjectId);
    console.log("[INVENTORY] Admins Inventory [Item Out]: ", vm.toString(invItem.quantity));

    ResourceId systemId = Utils.smartStorageUnitSystemId();

    RatioConfigData memory ratioConfigData = RatioConfig.get(smartStorageUnitId, itemInSmartObjectId);
    console.log("Ratio In:", vm.toString(ratioConfigData.ratioIn));
    console.log("Ratio Out:", vm.toString(ratioConfigData.ratioOut));
    console.log("Item Out:", vm.toString(ratioConfigData.itemOut));

    console.log("Item In:", vm.toString(itemInSmartObjectId));
    console.log("SSU ID: ", vm.toString(smartStorageUnitId));
    console.log("Sender: ", vm.toString(admin));

    address contractAddress = smartStorageUnitSystem.getAddress();

    console.log("Contract Address: ", vm.toString(contractAddress));

    vm.stopBroadcast();

    vm.startBroadcast(adminPrivateKey);

    console.log("Setting transfer from ephemeral access");
    ephemeralInteractSystem.setTransferFromEphemeralAccess(smartStorageUnitId, contractAddress, true);
    console.log("Transfer from ephemeral access set");

    vm.stopBroadcast();

    vm.startBroadcast(playerPrivateKey);

    // Use the item that's already in the ephemeral inventory
    InventoryItemParams[] memory inItems = new InventoryItemParams[](1);
    inItems[0] = InventoryItemParams(32405186305713341162402166909623213452806236265591347791747984352594936240888, 1);

    console.log("Transferring from ephemeral");
    ephemeralInteractSystem.transferFromEphemeral(107917160961269205918737706720208697708623178898411038747739517574974176991232, player, inItems);
    console.log("Transferred from ephemeral 12");
    world.call(systemId, 
      abi.encodeCall(
        SmartStorageUnitSystem.execute, 
        (smartStorageUnitId, testQuantityIn, itemInSmartObjectId)
      )
    );

    vm.stopBroadcast();
  }
}
