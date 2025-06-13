// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { SmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";
import { Utils } from "../src/systems/Utils.sol";

contract ConfigureRatio is Script {
  uint256 SSU_TYPE_ID = 77917;
  uint256 ssuItemId = 565656565;
  function run(address worldAddress) external {
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);
    bytes32 tenantId = Tenant.getTenantId();

    //Read from .env
    uint256 itemIn = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_TYPE_ID");
    uint64 inRatio = uint64(vm.envUint("IN_RATIO"));
    uint64 outRatio = uint64(vm.envUint("OUT_RATIO"));

    uint256 itemInSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemIn);
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateObjectId(tenantId, itemOut);

    //Configure the vending machine
    uint256 smartStorageUnitId = ObjectIdLib.calculateObjectId(tenantId, ssuItemId);
    console.log("Smart Storage Unit ID: ", vm.toString(smartStorageUnitId));
    console.log("Item In Smart Object ID: ", vm.toString(itemInSmartObjectId));
    ResourceId systemId = Utils.smartStorageUnitSystemId();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    vm.startBroadcast(adminPrivateKey);
    world.call(
      systemId,
      abi.encodeCall(
        SmartStorageUnitSystem.setRatio,
        (smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, inRatio, outRatio)
      )
    );
    vm.stopBroadcast();
  }
}
