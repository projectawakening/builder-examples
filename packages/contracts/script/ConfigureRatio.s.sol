// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IVendingMachine } from "../src/codegen/world/IVendingMachine.sol";
import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract ConfigureRatio is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 itemIn = vm.envUint("ITEM_IN_ID");
    uint256 itemOut = vm.envUint("ITEM_OUT_ID");
    uint256 inRatio = vm.envUint("IN_RATIO");
    uint256 outRatio = vm.envUint("OUT_RATIO");

    //Configure the vending machine
    console.log("itemIn", itemIn);
    console.log("itemOut", itemOut);

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    IVendingMachine(worldAddress).test__setVendingMachineRatio(smartStorageUnitId, itemIn, itemOut, inRatio, outRatio);
    // console.log("ratioIn:", RatioConfig.getRatioIn(smartStorageUnitId, itemIn));
    // console.log("ratioOut:", RatioConfig.getRatioOut(smartStorageUnitId, itemIn));

    vm.stopBroadcast();
  }
}
