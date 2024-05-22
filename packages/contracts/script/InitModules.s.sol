// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

// World imports
import { World } from "@latticexyz/world/src/World.sol";
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { ModulesInitializationLibrary } from "../src/utils/ModulesInitializationLibrary.sol";
import { SOFInitializationLibrary } from "../src/utils/SOFInitializationLibrary.sol";


// only needs to be run once
contract InitModules is Script {
  using ModulesInitializationLibrary for IBaseWorld;
  using SOFInitializationLibrary for IBaseWorld;

  IBaseWorld world;
  function run(address worldAddress) external {
    
    // Specify a store so that you can use tables directly in PostDeploy
    StoreSwitch.setStoreAddress(worldAddress);
    world = IBaseWorld(worldAddress);

    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.addr(deployerPrivateKey);
    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    world.initSOF();
    world.initStaticData();
    world.initEntityRecord();
    world.initLocation();
    world.initSmartCharacter();
    world.initSmartDeployable();
    world.initInventory();
    world.initSSU();

    vm.stopBroadcast();
  }
}
