// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { Systems } from "@latticexyz/world/src/codegen/tables/Systems.sol";
import { IWorldWithContext } from "@eveworld/smart-object-framework-v2/src/IWorldWithContext.sol";

import { InventorySystem, inventorySystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/InventorySystemLib.sol";
import { EphemeralInteractSystem, ephemeralInteractSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/EphemeralInteractSystemLib.sol";
import { OwnershipSystem, ownershipSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/OwnershipSystemLib.sol";
import { InventoryItem, InventoryItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/InventoryItem.sol";
import { EphemeralInvItem, EphemeralInvItemData } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/tables/EphemeralInvItem.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { InventoryItemParams } from "@eveworld/world-v2/src/namespaces/evefrontier/systems/inventory/types.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";

import { SmartStorageUnitSystem, smartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";

import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { Utils } from "../src/systems/Utils.sol";
import { RatioConfigData } from "../src/codegen/tables/RatioConfig.sol";

contract Execute is Script {
  uint256 SSU_TYPE_ID = 77917;
  uint256 ssuItemId = 565656565;

  IWorldWithContext world;
  function run(address worldAddress) external {
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    address admin = vm.addr(adminPrivateKey);

    uint256 playerPrivateKey = vm.envUint("TEST_PLAYER_PRIVATE_KEY");
    address player = vm.addr(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    world = IWorldWithContext(worldAddress);

    ResourceId systemId = Utils.smartStorageUnitSystemId();
    // address contractAddress = smartStorageUnitSystem.getAddress();

    // console.log("Contract Address: ", contractAddress);

    bytes32 tenantId = Tenant.getTenantId();
    uint256 smartStorageUnitId = ObjectIdLib.calculateObjectId(tenantId, ssuItemId);

    vm.startBroadcast(adminPrivateKey);
    (address contractAddress, ) = Systems.get(systemId);
    console.log("System Address: ", contractAddress);
    ephemeralInteractSystem.setTransferFromEphemeralAccess(smartStorageUnitId, address(contractAddress), true);
    vm.stopBroadcast();

    vm.startBroadcast(adminPrivateKey);
    _execute(tenantId, smartStorageUnitId, player);
    vm.stopBroadcast();
  }

  function _execute(bytes32 tenantId, uint256 smartStorageUnitId, address player) private {
    uint256 itemIn = vm.envUint("ITEM_IN_TYPE_ID");
    uint64 testQuantityIn = uint64(vm.envUint("EXECUTE_QUANTITY"));

    uint256 itemInSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemIn);

    console.log("Item In Smart Object ID: ", itemInSmartObjectId);

    ResourceId systemId = Utils.smartStorageUnitSystemId();

    world.callFrom(
      player,
      systemId,
      abi.encodeCall(SmartStorageUnitSystem.execute, (smartStorageUnitId, testQuantityIn, itemInSmartObjectId))
    );
  }
}