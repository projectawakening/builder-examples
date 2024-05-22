// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";

import { EntityMap } from "@eveworld/smart-object-framework/src/codegen/tables/EntityMap.sol";
import { SMART_OBJECT_DEPLOYMENT_NAMESPACE } from "@eveworld/common-constants/src/constants.sol";
import { Utils as CoreUtils } from "@eveworld/smart-object-framework/src/utils.sol";
import { WarEffortLib } from "../src/war-effort/WarEffortLib.sol";
import { WAR_EFFORT_DEPLOYMENT_NAMESPACE, WAR_EFFORT_CLASS_ID } from "../src/war-effort/constants.sol";

contract ConfigureWarEffort is Script {
  using CoreUtils for bytes14;
  using WarEffortLib for WarEffortLib.World;

  IBaseWorld world;
  WarEffortLib.World warEffort;

  function run(address worldAddress) external {

    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    world = IBaseWorld(worldAddress);
    warEffort = WarEffortLib.World({iface: world, namespace: WAR_EFFORT_DEPLOYMENT_NAMESPACE});

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Read from .env
    uint256 ssuId = vm.envUint("SSU_ID");
    uint256 acceptedItemTypeId = vm.envUint("TYPE_ID");
    uint256 warEffortGoal = vm.envUint("GOAL_QUANTITY");

    vm.startBroadcast(playerPrivateKey);

    // if the SSU is not already, tag it as an Item Seller
    uint256[] memory classArray = EntityMap.getTaggedEntityIds(SMART_OBJECT_DEPLOYMENT_NAMESPACE.entityMapTableId(), ssuId);
    bool found = false;
    for(uint i=0; i < classArray.length; i++){
      if(classArray[i] == WAR_EFFORT_CLASS_ID) {
        found = true;
        break;
      }
    }
    if(!found) warEffort.associateSSUToWarEffort(ssuId);

    // set up SSU
    warEffort.setAcceptedItemTypeId(ssuId, acceptedItemTypeId);
    warEffort.setTargetQuantity(ssuId, warEffortGoal);

    vm.stopBroadcast();
  }
}
