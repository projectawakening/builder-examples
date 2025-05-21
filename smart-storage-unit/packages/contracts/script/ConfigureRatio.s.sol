// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { ResourceId, WorldResourceIdLib } from "@latticexyz/world/src/WorldResourceId.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { Utils } from "../src/systems/Utils.sol";
import { SmartStorageUnitSystem } from "../src/systems/SmartStorageUnitSystem.sol";
import { Tenant, Characters, CharactersByAccount, EntityRecord } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/index.sol";
import { ObjectIdLib } from "@eveworld/world-v2/src/namespaces/evefrontier/libraries/ObjectIdLib.sol";

contract ConfigureRatio is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(adminPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    bytes32 tenantId = Tenant.getTenantId();

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    
    uint256 itemIn = vm.envUint("ITEM_IN_TYPE_ID");
    uint256 itemInSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, itemIn);

    uint256 itemOut = vm.envUint("ITEM_OUT_TYPE_ID");
    uint256 itemOutSmartObjectId = ObjectIdLib.calculateNonSingletonId(tenantId, itemOut);

    uint64 inRatio = uint64(vm.envUint("IN_RATIO"));
    uint64 outRatio = uint64(vm.envUint("OUT_RATIO"));

    //Debug logging
    console.log("Raw environment variables:");
    console.log("IN_RATIO env value:", vm.toString(vm.envUint("IN_RATIO")));
    console.log("OUT_RATIO env value:", vm.toString(vm.envUint("OUT_RATIO")));
    console.log("ITEM_OUT_TYPE_ID env value:", vm.toString(vm.envUint("ITEM_OUT_TYPE_ID")));

    //Configure the vending machine
    console.log("Smart Storage Unit ID: ", vm.toString(smartStorageUnitId));
    console.log("Item In Smart Object ID: ", vm.toString(itemInSmartObjectId));
    console.log("Ratio In: ", vm.toString(inRatio));
    console.log("Ratio Out: ", vm.toString(outRatio));
    console.log("Item Out: ", vm.toString(itemOutSmartObjectId));

    ResourceId systemId = Utils.smartStorageUnitSystemId();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(
      systemId,
      abi.encodeCall(SmartStorageUnitSystem.setRatio, (smartStorageUnitId, itemInSmartObjectId, itemOutSmartObjectId, inRatio, outRatio))
    );

    vm.stopBroadcast();
  }
}
