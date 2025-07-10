// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";

/**
 * @notice This script links two smart gates together
 * @dev This script can only be called by the owner of the smart gate
 */
contract LinkGates is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(adminPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 sourceGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationGateId = vm.envUint("DESTINATION_GATE_ID");

    smartGateSystem.linkGates(sourceGateId, destinationGateId);

    vm.stopBroadcast();
  }
}
