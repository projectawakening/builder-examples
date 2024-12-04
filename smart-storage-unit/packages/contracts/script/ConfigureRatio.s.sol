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

contract ConfigureRatio is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PLAYER_PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 itemIn = vm.envUint("ITEM_IN_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_ID");
    uint64 inRatio = uint64(vm.envUint("IN_RATIO"));
    uint64 outRatio = uint64(vm.envUint("OUT_RATIO"));

    //Configure the vending machine
    console.log("itemIn", itemIn);
    console.log("itemOut", itemOut);

    ResourceId systemId = Utils.smartStorageUnitSystemId();

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    world.call(
      systemId,
      abi.encodeCall(SmartStorageUnitSystem.setRatio, (smartStorageUnitId, itemIn, itemOut, inRatio, outRatio))
    );

    vm.stopBroadcast();
  }
}
