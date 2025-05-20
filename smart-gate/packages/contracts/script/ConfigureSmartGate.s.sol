// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { ResourceId } from "@latticexyz/world/src/WorldResourceId.sol";
import { StoreSwitch } from "@latticexyz/store/src/StoreSwitch.sol";
import { IBaseWorld } from "@latticexyz/world/src/codegen/interfaces/IBaseWorld.sol";

import { SmartGateSystem, smartGateSystem } from "@eveworld/world-v2/src/namespaces/evefrontier/codegen/systems/SmartGateSystemLib.sol";
import { Utils as SmartGateUtils } from "../src/systems/Utils.sol";

import { GateAccess } from "../src/codegen/tables/GateAccess.sol";

contract ConfigureSmartGate is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 privateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(privateKey);

    StoreSwitch.setStoreAddress(worldAddress);
    IBaseWorld world = IBaseWorld(worldAddress);

    uint256 smartGateId = vm.envUint("SOURCE_GATE_ID");

    ResourceId systemId = SmartGateUtils.smartGateSystemId();

    //This function can only be called by the owner of the smart gate
    smartGateSystem.configureGate(smartGateId, systemId);

    //Get the allowed tribe
    uint256 tribeID = vm.envUint("ALLOWED_TRIBE_ID");

    //Set the MUD table for the tribe whitelist
    GateAccess.set(smartGateId, tribeID);

    vm.stopBroadcast();
  }
}
