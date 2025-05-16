// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";

import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";

contract CanJump is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 playerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(playerPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);

    uint256 sourceGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationGateId = vm.envUint("DESTINATION_GATE_ID");

    console.log("-------------------\nTESTING CORRECT CORP");
    console.log("Can Jump:", smartGateSystem.canJump(100, sourceGateId, destinationGateId));

    console.log("-------------------\nTESTING INCORRECT CORP");
    console.log("Can Jump:", smartGateSystem.canJump(1234, sourceGateId, destinationGateId));

    vm.stopBroadcast();
  }
}
