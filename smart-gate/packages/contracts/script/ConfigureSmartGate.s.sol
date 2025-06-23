// SPDX-License-Identifier: MIT
pragma solidity >=0.8.24;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";

import { Utils as SmartGateUtils } from "../src/systems/Utils.sol";
import { GateAccess } from "../src/codegen/tables/GateAccess.sol";
import { SmartGateSystem as CustomSmartGateSystem } from "../src/systems/SmartGateSystem.sol";

/**
 * @notice This script configures a smart gate to use your custom contract and set the allowed tribe
 * @dev This script can only be called by the owner of the smart gate
 */
contract ConfigureSmartGate is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 adminPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(adminPrivateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 sourceSmartGateId = vm.envUint("SOURCE_GATE_ID");
    uint256 destinationSmartGateId = vm.envUint("DESTINATION_GATE_ID");

    ResourceId systemId = SmartGateUtils.smartGateSystemId();

    //This function can only be called by the owner of the smart gate
    smartGateSystem.configureGate(sourceSmartGateId, systemId);
    smartGateSystem.configureGate(destinationSmartGateId, systemId);

    //Get the allowed tribe
    uint256 tribeID = vm.envUint("ALLOWED_TRIBE_ID");

    //Set the allowed tribe for the source gate
    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartGateSystem.setAllowedTribe,
        (sourceSmartGateId, tribeID)
      )
    );

    //Set the allowed tribe for the destination gate
    world.call(
      systemId,
      abi.encodeCall(
        CustomSmartGateSystem.setAllowedTribe,
        (destinationSmartGateId, tribeID)
      )
    );

    vm.stopBroadcast();
  }
}
