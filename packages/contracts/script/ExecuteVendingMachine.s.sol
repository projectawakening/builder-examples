// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";

import { IVendingMachine } from "../src/codegen/world/IVendingMachine.sol";
import { RatioConfig } from "../src/codegen/tables/RatioConfig.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

contract ExecuteVendingMachine is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    // uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");

    uint256 ephemeralPrivateKey = uint256(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);
    address ephemeralOwner = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
    vm.startBroadcast(ephemeralPrivateKey);

    //Read from .env
    uint256 smartStorageUnitId = vm.envUint("SSU_ID");
    uint256 itemIn = vm.envUint("ITEM_IN_ID");

    //The method below will change based on the namespace you have configurd. If the namespace is changed, make sure to update the method name
    IVendingMachine(worldAddress).test__executeVendingMachine(smartStorageUnitId, 1, itemIn);

    vm.stopBroadcast();
  }
}
